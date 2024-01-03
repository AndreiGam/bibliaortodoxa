import 'package:flutter/material.dart';
import 'despre.dart';
import "appbar.dart";
import 'package:shared_preferences/shared_preferences.dart';
import 'carte.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  themeNotifier.loadTheme();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: _prefs,
      builder: (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final loadedSelectedBookAbr = snapshot.data?.getString('selectedBookAbr');
          final loadedSelectedBookName = snapshot.data?.getString('selectedBookName');
          final loadedSelectedChapterId = snapshot.data?.getInt('selectedChapter');

          return MaterialApp(
            home: loadedSelectedBookAbr != null
                ? CartePage(
                    titlu: loadedSelectedBookName ?? 'Biblia',
                    bookAbr: loadedSelectedBookAbr,
                    chapterId: loadedSelectedChapterId ?? 1,
                  )
                : DesprePage(),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
