import 'package:flutter/material.dart';
import 'appbar.dart';
import 'carte.dart';

class SearchPage extends StatefulWidget {
  final List<SearchResult> searchResults;

  SearchPage({Key? key, required this.searchResults}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: "Cauta",
      body: widget.searchResults.isEmpty
          ? Center(child: Text("No results found."))
          : ListView.builder(
              itemCount: widget.searchResults.length,
              itemBuilder: (context, index) {
                var result = widget.searchResults[index];
                return ListTile(
                  title: Text("${result.bookTitle} ${result.chapterNumber}:${result.verseNumber}"),
                  subtitle: Text(result.verseText),
                  onTap: () {
                    navigateToCartePage(result);
                  },
                );
              },
            ),
    );
  }

  void navigateToCartePage(SearchResult result) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CartePage(
        titlu: result.bookTitle, // Assuming SearchResult contains a title or similar field
        bookAbr: result.bookAbr,
        chapterId: int.parse(result.chapterNumber),
        shouldScrollToBookmark: true,
        verseIndex: int.parse(result.verseNumber),
      ),
    ));
  }
}
