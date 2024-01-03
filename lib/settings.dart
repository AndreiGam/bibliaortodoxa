import 'package:flutter/material.dart';
import 'appbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: themeNotifier.fontSize,
      builder: (context, value, child) {
        return CustomScaffold(
          title: "Setari",
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Marime Text',
                  style: TextStyle(fontSize: value),
                ),
                Slider(
                  value: value,
                  min: 12,
                  max: 32,
                  divisions: 5,
                  label: value.round().toString(),
                  activeColor: Colors.brown,
                  onChanged: (double newValue) async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setInt('fontSize', newValue.toInt());
                    themeNotifier.fontSize.value = newValue;
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
