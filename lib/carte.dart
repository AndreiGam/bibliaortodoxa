import 'package:flutter/material.dart';
import 'appbar.dart';
import 'bookmark.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartePage extends StatefulWidget {
  final String titlu;
  final String bookAbr;
  final int chapterId;
  final bool shouldScrollToBookmark;
  final int verseIndex;

  CartePage({
    required this.titlu,
    required this.bookAbr,
    required this.chapterId,
    this.shouldScrollToBookmark = false,
    this.verseIndex = 0,
  });

  @override
  _CartePageState createState() => _CartePageState();
}

class _CartePageState extends State<CartePage> {
  int? totalChapters;
  List<Bookmark> bookmarks = [];
  ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> verseKeys = {};
  Bookmark bookmark = Bookmark.empty();

  @override
  void initState() {
    super.initState();
    _loadContent();
    getTotalChapters();
    loadBookmarks();
    _scrollController = ScrollController();

    if (widget.shouldScrollToBookmark) {
      double itemHeight = 50.0;
      double offset = calculateOffsetForVerse(widget.verseIndex, itemHeight);
      Future.delayed(Duration(milliseconds: 50), () {
        _scrollController.jumpTo(offset);
      });
    }
  }

  double calculateOffsetForVerse(int verseIndex, double itemHeight) {
    return verseIndex * itemHeight;
  }

  bool isVerseBookmarked(Bookmark bookmark) {
    return bookmarks
        .any((b) => b.bookAbr == bookmark.bookAbr && b.chapterId == bookmark.chapterId && b.verse == bookmark.verse);
  }

  void loadBookmarks() async {
    String bookAbr = widget.bookAbr;
    int chapterId = widget.chapterId;

    List<Bookmark> loadedBookmarks = await bookmark.loadBookmarksForChapter(bookAbr, chapterId);

    setState(() {
      bookmarks = loadedBookmarks;
    });
  }

  Future<void> getTotalChapters() async {
    final String jsonString = await rootBundle.loadString('assets/books/${widget.bookAbr}.json');
    final Map jsonData = jsonDecode(jsonString);
    setState(() {
      totalChapters = jsonData['capitole'].length;
    });
  }

  Future<void> saveChapter(chapter) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedChapter', chapter);
  }

  void _goToNextChapter() {
    int total = totalChapters ?? 0;
    saveChapter(widget.chapterId + 1);
    if (widget.chapterId < total) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => CartePage(
            titlu: widget.titlu,
            bookAbr: widget.bookAbr,
            chapterId: widget.chapterId + 1,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  void _goToPreviousChapter() {
    saveChapter(widget.chapterId - 1);
    if (widget.chapterId > 1) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => CartePage(
            titlu: widget.titlu,
            bookAbr: widget.bookAbr,
            chapterId: widget.chapterId - 1,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  Future<void> _loadContent() async {
    await getContent(widget.bookAbr, widget.chapterId);
  }

  Future<List<Map>> getContent(String abr, int chapterId) async {
    final String jsonString = await rootBundle.loadString('assets/books/$abr.json');
    final Map jsonData = jsonDecode(jsonString);
    final chapter = jsonData['capitole'][chapterId - 1];
    final versuri = chapter['versuri'] as Map;

    List<Map> result = versuri.entries.map((entry) {
      return {
        'vers': int.parse(entry.key),
        'text': entry.value,
        'nume_carte': jsonData['n'],
        'titlu': jsonData['titlu']
      };
    }).toList();

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: widget.titlu,
      body: FutureBuilder<List<Map>>(
        future: getContent(widget.bookAbr, widget.chapterId),
        builder: (
          context,
          snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasData) {
            List<Map> data = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(height: 5),
                  Center(
                    child: ValueListenableBuilder<bool>(
                      valueListenable: themeNotifier.isDarkModeNotifier,
                      builder: (context, bool isDarkMode, _) {
                        return Column(
                          children: [
                            Text(
                              '${data[0]['titlu']}',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: themeNotifier.fontSize.value),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.arrow_back_ios),
                                  color: isDarkMode ? Colors.brown[300] : Colors.brown[700],
                                  onPressed: _goToPreviousChapter,
                                ),
                                Spacer(),
                                Text(
                                  'Capitolul ${widget.chapterId}',
                                  style: TextStyle(fontSize: themeNotifier.fontSize.value * 0.75),
                                ),
                                Spacer(),
                                IconButton(
                                  icon: Icon(Icons.arrow_forward_ios),
                                  color: isDarkMode ? Colors.brown[300] : Colors.brown[700],
                                  onPressed: _goToNextChapter,
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView.separated(
                      controller: _scrollController,
                      itemCount: data.length,
                      separatorBuilder: (context, index) => SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        int verseIndex = data[index]['vers'];
                        Bookmark bookmark = Bookmark(widget.bookAbr, widget.chapterId, verseIndex);

                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                          leading: IconButton(
                            icon: Icon(isVerseBookmarked(bookmark) ? Icons.bookmark : Icons.bookmark_border),
                            onPressed: () async {
                              double lastPosition = _scrollController.offset;

                              if (!isVerseBookmarked(bookmark)) {
                                await bookmark.saveBookmark(bookmark);
                                setState(() {
                                  bookmarks.add(bookmark);
                                });
                              } else {
                                await Bookmark.removeBookmark(bookmark);
                                setState(() {
                                  bookmarks.removeWhere((b) =>
                                      b.bookAbr == bookmark.bookAbr &&
                                      b.chapterId == bookmark.chapterId &&
                                      b.verse == bookmark.verse);
                                });
                              }
                              Future.delayed(Duration(milliseconds: 50), () {
                                _scrollController.jumpTo(lastPosition);
                              });
                            },
                          ),
                          title: ValueListenableBuilder<bool>(
                            valueListenable: themeNotifier.isDarkModeNotifier,
                            builder: (context, bool isDarkMode, _) {
                              return RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${data[index]['vers']}. ',
                                      style: TextStyle(
                                        fontSize: themeNotifier.fontSize.value,
                                        color: isDarkMode ? Colors.brown[300] : Colors.brown[700],
                                      ),
                                    ),
                                    TextSpan(
                                      text: '${data[index]['text']}',
                                      style: TextStyle(
                                        fontSize: themeNotifier.fontSize.value,
                                        color: isDarkMode ? Colors.grey[100] : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            );
          } else {
            return Text('Error');
          }
        },
      ),
    );
  }
}
