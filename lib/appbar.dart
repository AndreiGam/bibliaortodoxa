import 'package:flutter/material.dart';
import 'settings.dart';
import 'despre.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'carte.dart';
import 'semnecarte.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'search.dart';

class SearchResult {
  String bookAbr;
  String chapterNumber;
  String verseNumber;
  String verseText;
  String bookTitle;

  SearchResult(this.bookTitle, this.bookAbr, this.chapterNumber, this.verseNumber, this.verseText);

  @override
  String toString() {
    return 'SearchResult{bookTitle: $bookTitle, bookAbr: $bookAbr, chapter: $chapterNumber, verse: $verseNumber, text: $verseText}';
  }
}

class ThemeNotifier {
  static final ThemeNotifier _singleton = ThemeNotifier._internal();
  final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier<bool>(false);

  final ValueNotifier<double> fontSize = ValueNotifier<double>(0.0);

  ThemeNotifier._internal();

  factory ThemeNotifier() {
    return _singleton;
  }

  void loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isDarkModeNotifier.value = prefs.getBool('isDarkMode') ?? false;
    fontSize.value = (prefs.getInt('fontSize') ?? 20).toDouble();
  }

  void toggleTheme() async {
    isDarkModeNotifier.value = !isDarkModeNotifier.value;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkModeNotifier.value);
  }
}

final themeNotifier = ThemeNotifier();
Map<String, Map<int, Map<String, dynamic>>> cuprins = {};

@immutable
class CustomScaffold extends StatelessWidget {
  final Widget body;
  final String title;

  const CustomScaffold({
    Key? key,
    required this.body,
    required this.title,
  }) : super(key: key);

  void _toggleTheme() {
    themeNotifier.toggleTheme();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier.isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return Theme(
          data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                title,
                style: TextStyle(
                  fontSize: themeNotifier.fontSize.value,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.brown[700],
              leading: Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: Icon(Icons.menu, color: Colors.white), // Ensuring the icon is white
                    onPressed: () {
                      Scaffold.of(context).openDrawer(); // Opens the drawer
                    },
                  );
                },
              ),
              actions: [
                IconButton(
                  icon: isDarkMode
                      ? Icon(Icons.lightbulb, color: Colors.white)
                      : Icon(Icons.lightbulb_outline, color: Colors.white),
                  onPressed: _toggleTheme,
                ),
              ],
            ),
            drawer: MyDrawer(),
            body: body,
          ),
        );
      },
    );
  }
}

class MyDrawer extends StatefulWidget {
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

int globalShowSubDrawer = 0;
bool globalShowingChapters = false;

class _MyDrawerState extends State<MyDrawer> {
  int showSubDrawer = 0;
  bool showingChapters = false;
  String selectedBookName = '';
  String selectedBookAbr = '';
  int selectedChapter = 0;
  int loadedSelectedChapter = 0;

  //search

  TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, Map<int, Map<String, dynamic>>> cuprins = {};
  List<SearchResult> _searchResults = [];

  Future<String> loadBookContent(String abr) async {
    final String jsonString = await rootBundle.loadString('assets/books/$abr.json');
    // Parse jsonString as per your JSON structure
    return jsonString; // Return content or relevant data
  }

  void performSearch(String query) async {
    if (query.isEmpty) {
      print('Nu ai cautat!');
      return;
    }

    const int maxResults = 154; // Set the maximum number of results you want
    String normalizedQuery = RegExp.escape(query.trim());
    RegExp regexQuery = RegExp(fuzzQuery(normalizedQuery), caseSensitive: false);

    List<SearchResult> results = [];
    print('Cautare dupa: $normalizedQuery');

    outerLoop: // Label for the outermost loop
    for (var testament in cuprins.keys) {
      for (var bookDetails in cuprins[testament]!.values) {
        String abr = bookDetails['abr'];
        String bookTitle = bookDetails['titlu'];
        var bookJson = await loadBookContent(abr);
        Map<String, dynamic> bookData = jsonDecode(bookJson);

        for (var chapter in bookData['capitole']) {
          String chapterNum = chapter['n'].toString();
          Map<String, dynamic> verses = chapter['versuri'];

          for (var verseEntry in verses.entries) {
            String verseNum = verseEntry.key;
            String verseText = verseEntry.value;
            //if (RegExp(normalizedQuery, caseSensitive: false, unicode: true).hasMatch(verseText)) {
            if (regexQuery.hasMatch(verseText)) {
              results.add(SearchResult(bookTitle, abr, chapterNum, verseNum, verseText));

              if (results.length >= maxResults) {
                break outerLoop; // Break out of all loops
              }
            }
          }
        }
      }
    }

    setState(() {
      _searchResults = results;
    });

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => SearchPage(searchResults: results),
    ));
  }

  String fuzzQuery(String str) {
    str = str.replaceAll('a', '[aăâĂÂ]');
    str = str.replaceAll('A', '[AĂÂăâ]');
    str = str.replaceAll('i', '[iîÎ]');
    str = str.replaceAll('I', '[IÎî]');
    str = str.replaceAll('s', '[sșşŞȘ]');
    str = str.replaceAll('S', '[SŞȘșş]');
    str = str.replaceAll('t', '[tţțȚ]');
    str = str.replaceAll('T', '[TȚţț]');
    str = str.replaceAll(RegExp(r' +'), '.*?');
    return str;
  }

  void loadCuprins() async {
    final String jsonString = await rootBundle.loadString('assets/books/cuprins.json');
    final Map<String, dynamic> jsonData = jsonDecode(jsonString);

    jsonData.forEach((key, value) {
      cuprins[key] = (value as Map).map((k, v) {
        return MapEntry(int.parse(k), v as Map<String, dynamic>);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    loadDrawerState();
    loadCuprins();
  }

  Future<void> saveDrawerState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('showSubDrawer', showSubDrawer);
    await prefs.setBool('showingChapters', showingChapters);
    await prefs.setString('selectedBookAbr', selectedBookAbr);
    await prefs.setString('selectedBookName', selectedBookName);
  }

  Future<void> saveChapter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedChapter', selectedChapter);
  }

  Future<void> loadDrawerState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? loadedShowSubDrawer = prefs.getInt('showSubDrawer');
    bool? loadedShowingChapters = prefs.getBool('showingChapters');
    String? loadedSelectedBookAbr = prefs.getString('selectedBookAbr');
    String? loadedSelectedBookName = prefs.getString('selectedBookName');

    setState(() {
      showSubDrawer = loadedShowSubDrawer ?? 0;
      showingChapters = loadedShowingChapters ?? false;
      selectedBookAbr = loadedSelectedBookAbr ?? 'Fc';
      selectedBookName = loadedSelectedBookName ?? '';
    });
  }

  Widget drawerContent() {
    if (showSubDrawer == 0) {
      return Column(
        children: [
          buildMainListTile('Vechiul Testament', 1),
          buildMainListTile('Noul Testament', 2),
          ListTile(
            title: Text(
              'Despre',
              style: TextStyle(fontSize: themeNotifier.fontSize.value),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DesprePage()),
              );
            },
          ),
          ListTile(
            title: Text(
              'Setari',
              style: TextStyle(fontSize: themeNotifier.fontSize.value),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
          ListTile(
            title: Text(
              'Favorite',
              style: TextStyle(fontSize: themeNotifier.fontSize.value),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SemneCartePage()),
              );
            },
          ),
        ],
      );
    } else if (showingChapters) {
      // Chapters Drawer
      return buildChaptersDrawer();
    } else {
      // Sub Drawer for Vechiul or Noul
      final testament = showSubDrawer == 1 ? 'Vechiul Testament' : 'Noul Testament';
      return Column(
        children: cuprins[testament]!.entries.map<Widget>(buildListTile).toList(),
      );
    }
  }

  ListTile buildMainListTile(String title, int nextDrawer) {
    return ListTile(
      title: Text(title, style: TextStyle(fontSize: themeNotifier.fontSize.value)),
      onTap: () {
        setState(() {
          showSubDrawer = nextDrawer;
        });
      },
    );
  }

  ListTile buildListTile(MapEntry<int, Map<String, dynamic>> entry) {
    return ListTile(
      title: Text(
        entry.value['titlu'],
        style: TextStyle(fontSize: themeNotifier.fontSize.value),
      ),
      subtitle: entry.value['nume'].isNotEmpty
          ? Text(
              entry.value['nume'],
              style: TextStyle(fontSize: themeNotifier.fontSize.value * 0.75),
            )
          : null,
      onTap: () {
        setState(() {
          selectedBookAbr = entry.value['abr'];
          showingChapters = true;
          saveDrawerState();
          selectedBookName = entry.value['titlu'];
        });
      },
    );
  }

  ScrollController bookScrollController = ScrollController();
  ScrollController chapterScrollController = ScrollController();

  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () {
                      performSearch(_searchController.text);
                    },
                    icon: Icon(Icons.search),
                  ),
                ),
                onSubmitted: (String text) {
                  performSearch(text);
                },
              ),
            ),
            if (showSubDrawer != 0)
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                ),
                child: ListTile(
                  leading: Icon(Icons.arrow_back),
                  title: Text(
                    'Inapoi',
                    style: TextStyle(fontSize: themeNotifier.fontSize.value * 0.75),
                  ),
                  onTap: () {
                    setState(() {
                      if (showingChapters) {
                        showingChapters = false;
                      } else {
                        showSubDrawer = 0;
                      }
                      saveDrawerState();
                    });
                  },
                ),
              ),
            if (showingChapters)
              ListTile(
                title: Text(
                  selectedBookName,
                  style: TextStyle(
                    fontSize: themeNotifier.fontSize.value,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Expanded(
              child: ListView(
                controller:
                    showSubDrawer == 1 ? bookScrollController : (showingChapters ? chapterScrollController : null),
                children: [drawerContent()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<int> fetchBook(String abr) async {
    final String jsonString = await rootBundle.loadString('assets/books/$abr.json');
    final Map jsonData = jsonDecode(jsonString);

    // Get the last chapter from the 'capitole' array
    var lastChapter = jsonData['capitole'].last;

    // Fetch the 'n' value from the last chapter
    int lastChapterNumber = lastChapter['n'];

    return lastChapterNumber;
  }

  Widget buildChaptersDrawer() {
    return FutureBuilder<int>(
      future: fetchBook(selectedBookAbr),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("Error");
        } else {
          return Column(
            children: [
              ...List.generate(snapshot.data!, (index) {
                return ListTile(
                  title: Text(
                    "Capitolul ${index + 1}",
                    style: TextStyle(fontSize: themeNotifier.fontSize.value),
                  ),
                  onTap: () {
                    selectedChapter = index + 1;
                    saveChapter();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CartePage(
                          titlu: selectedBookName,
                          bookAbr: selectedBookAbr,
                          chapterId: index + 1,
                        ),
                      ),
                    ).then((_) {
                      setState(() {});
                    });
                  },
                );
              })
            ],
          );
        }
      },
    );
  }
}
