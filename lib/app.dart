import 'package:flutter/material.dart';
import 'package:flutter\_localizations/flutter\_localizations.dart';
import 'package:wandr/components/dashboard/dashboard.component.dart';
import 'package:wandr/components/shared/localizer.dart';

/// This widget is the root of your application.
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData(
      fontFamily: 'Calibri',
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
    final ThemeData darkTheme = ThemeData(
      fontFamily: 'Calibri',
      brightness: Brightness.dark,
      primarySwatch: Colors.yellow,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );

    return MaterialApp(
        title: 'WANDR',
        debugShowCheckedModeBanner: false,
        theme: theme.copyWith(
          colorScheme: theme.colorScheme.copyWith(secondary: Colors.blue),
        ),
        darkTheme: darkTheme.copyWith(
          colorScheme: darkTheme.colorScheme.copyWith(secondary: Colors.yellow),
        ),
        home: DashboardComponent(
          title: Localizer.translate(context, 'appName'),
        ),
        supportedLocales: [
          const Locale('en', 'US'),
          const Locale('en', 'GB'),
          const Locale('de', 'DE'),
          const Locale('de', 'AT'),
          const Locale('de', 'CH')
        ],
        localizationsDelegates: [
          const LocalizerDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GermanCupertinoLocalizations.delegate
        ],
        localeResolutionCallback:
            (Locale? locale, Iterable<Locale> supportedLocales) {
          if (locale == null) {
            LOCALE = supportedLocales.first.scriptCode ?? 'de_DE';
            print('Cound not detect language, using \'$LOCALE\'');
            return supportedLocales.first;
          }

          for (Locale supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode ||
                supportedLocale.countryCode == locale.countryCode) {
              LOCALE = supportedLocale.scriptCode ?? 'de_DE';
              print('Detected language code \'$LOCALE\'');
              return supportedLocale;
            }
          }

          LOCALE = supportedLocales.first.scriptCode ?? 'de_DE';
          print('Use language fallback \'$LOCALE\'');
          return supportedLocales.first;
        });
  }
}
