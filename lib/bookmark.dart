import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class Bookmark {
  final String bookAbr;
  final int chapterId;
  final int verse;

  // Default constructor with no arguments
  Bookmark.empty()
      : bookAbr = '',
        chapterId = 0,
        verse = 0;

  Bookmark(this.bookAbr, this.chapterId, this.verse);

  Map<String, dynamic> toJson() {
    return {
      'bookAbr': bookAbr,
      'chapterId': chapterId,
      'verse': verse,
    };
  }

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      json['bookAbr'] as String,
      json['chapterId'] as int,
      json['verse'] as int,
    );
  }

  static List<Bookmark> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Bookmark.fromJson(json)).toList();
  }

  static List<Map<String, dynamic>> toJsonList(List<Bookmark> bookmarks) {
    return bookmarks.map((bookmark) => bookmark.toJson()).toList();
  }

// Load bookmarks from SharedPreferences
  static Future<List<Bookmark>> loadBookmarks() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? bookmarksJson = prefs.getString('bookmarks');
    List<Bookmark> bookmarks = [];

    if (bookmarksJson != null) {
      final List<dynamic> bookmarkList = json.decode(bookmarksJson);
      bookmarks = Bookmark.fromJsonList(bookmarkList);
    }

    return bookmarks;
  }

  static Future<List<Map<String, dynamic>>> getBookmarksWithText() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? bookmarksJson = prefs.getString('bookmarks');
    List<Map<String, dynamic>> bookmarksWithText = [];

    if (bookmarksJson != null) {
      List<Bookmark> bookmarks = Bookmark.fromJsonList(json.decode(bookmarksJson));

      for (Bookmark bookmark in bookmarks) {
        // Assuming you have a way to fetch the text for each bookmark
        // For example, you might have a method to get text from a book chapter and verse
        String text = await fetchTextForBookmark(bookmark);

        bookmarksWithText.add({
          'bookAbr': bookmark.bookAbr,
          'chapterId': bookmark.chapterId,
          'verse': bookmark.verse,
          'text': text, // The associated text for each bookmark
        });
      }
    }

    return bookmarksWithText;
  }

  static Future<String> fetchTextForBookmark(Bookmark bookmark) async {
    try {
      // Load the book content from a JSON file
      final String jsonString = await rootBundle.loadString('assets/books/${bookmark.bookAbr}.json');
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);

      // Access the specific chapter and verse
      if (jsonData.containsKey('capitole') && jsonData['capitole'] is List) {
        List<dynamic> chapters = jsonData['capitole'];
        if (bookmark.chapterId - 1 < chapters.length) {
          Map<String, dynamic> chapter = chapters[bookmark.chapterId - 1];
          if (chapter.containsKey('versuri') && chapter['versuri'] is Map) {
            Map<String, dynamic> versuri = chapter['versuri'];
            String verseKey = bookmark.verse.toString();
            if (versuri.containsKey(verseKey)) {
              return versuri[verseKey];
            }
          }
        }
      }
      return "Text not found for ${bookmark.bookAbr} ${bookmark.chapterId}:${bookmark.verse}";
    } catch (e) {
      // Handle any errors, such as file not found
      return "Error fetching text: $e";
    }
  }

// Load bookmarks from SharedPreferences for a specific bookAbr and chapterId
  Future<List<Bookmark>> loadBookmarksForChapter(String bookAbr, int chapterId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? bookmarksJson = prefs.getString('bookmarks');
    List<Bookmark> bookmarks = [];

    if (bookmarksJson != null) {
      final List<dynamic> bookmarkList = json.decode(bookmarksJson);
      bookmarks = Bookmark.fromJsonList(bookmarkList);

      // Filter bookmarks based on bookAbr and chapterId
      bookmarks =
          bookmarks.where((bookmark) => bookmark.bookAbr == bookAbr && bookmark.chapterId == chapterId).toList();
    }

    return bookmarks;
  }

  Future<void> saveBookmark(Bookmark bookmark) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load existing bookmarks
    final String? existingBookmarksJson = prefs.getString('bookmarks');
    List<Bookmark> existingBookmarks = [];

    if (existingBookmarksJson != null) {
      final List<dynamic> existingBookmarkList = json.decode(existingBookmarksJson);
      existingBookmarks = Bookmark.fromJsonList(existingBookmarkList);
    }

    // Add the new bookmark to the existing list
    existingBookmarks.add(bookmark);

    // Convert the updated list to JSON
    final List<Map<String, dynamic>> updatedBookmarkList = Bookmark.toJsonList(existingBookmarks);
    final String updatedBookmarksJson = json.encode(updatedBookmarkList);

    // Save the updated bookmarks JSON
    await prefs.setString('bookmarks', updatedBookmarksJson);
  }

  Future<void> saveBookmarks(List<Bookmark> bookmarks) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load existing bookmarks
    final String? existingBookmarksJson = prefs.getString('bookmarks');
    List<Bookmark> existingBookmarks = [];

    if (existingBookmarksJson != null) {
      final List<dynamic> existingBookmarkList = json.decode(existingBookmarksJson);
      existingBookmarks = Bookmark.fromJsonList(existingBookmarkList);
    }

    // Append the new bookmarks to the existing list
    existingBookmarks.addAll(bookmarks);

    // Convert the updated list to JSON
    final List<Map<String, dynamic>> updatedBookmarkList = Bookmark.toJsonList(existingBookmarks);
    final String updatedBookmarksJson = json.encode(updatedBookmarkList);

    // Save the updated bookmarks JSON
    await prefs.setString('bookmarks', updatedBookmarksJson);
  }

  static Future<void> removeBookmark(Bookmark bookmark) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load existing bookmarks
    final String? existingBookmarksJson = prefs.getString('bookmarks');
    List<Bookmark> existingBookmarks = [];

    if (existingBookmarksJson != null) {
      final List<dynamic> existingBookmarkList = json.decode(existingBookmarksJson);
      existingBookmarks = Bookmark.fromJsonList(existingBookmarkList);
    }

    // Remove the specified bookmark from the list based on its attributes
    existingBookmarks.removeWhere(
        (b) => b.bookAbr == bookmark.bookAbr && b.chapterId == bookmark.chapterId && b.verse == bookmark.verse);

    // Convert the updated list to JSON
    final List<Map<String, dynamic>> updatedBookmarkList = Bookmark.toJsonList(existingBookmarks);
    final String updatedBookmarksJson = json.encode(updatedBookmarkList);

    // Save the updated bookmarks JSON
    await prefs.setString('bookmarks', updatedBookmarksJson);
  }
}
