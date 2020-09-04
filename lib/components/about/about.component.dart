import 'package:flutter/material.dart';
import 'package:steps/components/about/about.item.howto.dart';
import 'package:steps/components/about/about.item.privacy.dart';
import 'package:steps/components/shared/localizer.dart';
import 'package:steps/components/shared/page.default.dart';

class About extends StatefulWidget {
  ///
  About({Key key}) : super(key: key);

  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultPage(
      child: ListView.builder(
        itemCount: 2,
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return AboutHowtoItem(
                title:
                    Localizer.translate(context, 'lblAboutHowTo').replaceFirst(
                  '%1',
                  Localizer.translate(context, 'appName').toUpperCase(),
                ),
              );
            case 1:
              return AboutPrivacyItem(
                title: Localizer.translate(context, 'lblAboutPrivacy'),
              );
            default:
              return Container();
          }
        },
      ),
      title: Localizer.translate(context, 'lblAbout').replaceFirst(
        '%1',
        Localizer.translate(context, 'appName').toUpperCase(),
      ),
    );
  }
}
