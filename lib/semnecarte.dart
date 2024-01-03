import 'package:flutter/material.dart';
import 'appbar.dart';
import 'bookmark.dart';
import 'cuprins.dart';
import 'carte.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SemneCartePage extends StatefulWidget {
  @override
  _SemneCartePageState createState() => _SemneCartePageState();
}

class _SemneCartePageState extends State<SemneCartePage> {
  List<Bookmark> bookmarks = [];
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadBookmarks();
  }

  void loadBookmarks() async {
    List<Bookmark> bookmarks = await Bookmark.loadBookmarks();
    setState(() {
      this.bookmarks = bookmarks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: "Favorite",
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: Bookmark.getBookmarksWithText(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    List<Map<String, dynamic>> bookmarksWithText = snapshot.data ?? [];
                    return ListView.separated(
                      controller: _scrollController,
                      itemCount: bookmarksWithText.length,
                      separatorBuilder: (context, index) => SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        Map<String, dynamic> bookmark = bookmarksWithText[index];
                        return ListTile(
                          onTap: () async {
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            await prefs.setInt('selectedChapter', bookmark['chapterId']);

                            WidgetsBinding.instance!.addPostFrameCallback((_) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CartePage(
                                    shouldScrollToBookmark: true,
                                    verseIndex: bookmark['verse'],
                                    titlu: getBookTitle(bookmark['bookAbr']),
                                    bookAbr: bookmark['bookAbr'],
                                    chapterId: bookmark['chapterId'],
                                  ),
                                ),
                              ).then((_) {
                                setState(() {});
                              });
                            });
                          },
                          contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                          leading: IconButton(
                            icon: Icon(Icons.bookmark),
                            onPressed: () async {
                              Bookmark toRemove =
                                  Bookmark(bookmark['bookAbr'], bookmark['chapterId'], bookmark['verse']);
                              await Bookmark.removeBookmark(toRemove); // Pass the bookmark instance as an argument
                              setState(() {
                                // Refresh the state to reflect the removed bookmark
                                loadBookmarks(); // Reload bookmarks to update the UI
                              });
                            },
                          ),
                          title: ValueListenableBuilder<bool>(
                            valueListenable: themeNotifier.isDarkModeNotifier,
                            builder: (context, bool isDarkMode, _) {
                              final fontSize = themeNotifier.fontSize.value ?? 16;
                              return RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          '${getBookTitle(bookmark['bookAbr'])} ${bookmark['chapterId']?.toString() ?? '0'}:${bookmark['verse']?.toString() ?? '0'} \n',
                                      style: TextStyle(
                                        fontSize: fontSize, // Default value if null
                                        color: isDarkMode ? Colors.brown[300] : Colors.brown[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '${bookmark['text']}',
                                      style: TextStyle(
                                        fontSize: fontSize, // Default value if null
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
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
