import 'package:flutter/material.dart';
import 'package:flutter\_localizations/flutter\_localizations.dart';
import 'package:steps/components/dashboard/dashboard.component.dart';
import 'package:steps/components/shared/localizer.dart';

/// This widget is the root of your application.
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: Localizer.translate(context, 'appName'),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          // This makes the visual density adapt to the platform that you run
          // the app on. For desktop platforms, the controls will be smaller and
          // closer together (more dense) than on mobile platforms.
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Dashboard(
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
            (Locale locale, Iterable<Locale> supportedLocales) {
          if (locale == null) {
            print('Cound not detect language');
            return supportedLocales.first;
          }

          for (Locale supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode ||
                supportedLocale.countryCode == locale.countryCode) {
              print('Detected language code \'$supportedLocale\'');
              return supportedLocale;
            }
          }

          print('Use language fallback \'${supportedLocales.first}\'');
          return supportedLocales.first;
        });
  }
}
