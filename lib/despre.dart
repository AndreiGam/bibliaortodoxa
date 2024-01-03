import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'appbar.dart';

class DesprePage extends StatelessWidget {
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ThemeNotifier(); // Assuming this is your theme notifier instance

    return CustomScaffold(
      title: "Despre",
      body: ValueListenableBuilder<bool>(
        valueListenable: themeNotifier.isDarkModeNotifier,
        builder: (context, isDarkMode, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: themeNotifier.fontSize.value,
                    color: isDarkMode ? Colors.white : Colors.black, // Dynamic text color based on theme
                    height: 1.5,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text:
                          'Această aplicație a apărut ca urmare a lipsei Bibliei Ortodoxe în limba română, textul bibliei în format digital este preluat de pe doxologia.ro și corespunde ediției 2018 tiparită cu Binecuvântarea Preafericitului Părinte DANIEL, Patriarhul Bisericii Ortodoxe Române, cu aprobarea Sfântului Sinod.\n\n\n\n',
                    ),
                    TextSpan(
                      text:
                          'Pentru BIBLIA în format tipărit adresați-vă parohiei locale sau online pe situl tipografiei patriarhiei: ',
                    ),
                    TextSpan(
                      text: 'www.cartibisericesti.ro',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          _launchURL('http://www.cartibisericesti.ro');
                        },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
