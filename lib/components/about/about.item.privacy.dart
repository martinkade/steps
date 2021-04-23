import 'package:flutter/material.dart';
import 'package:wandr/components/about/about.item.dart';

import 'package:wandr/components/shared/localizer.dart';

class AboutPrivacyItem extends AboutItem {
  ///
  AboutPrivacyItem({Key key, String title}) : super(key: key, title: title);

  @override
  _AboutPrivacyItemState createState() => _AboutPrivacyItemState();
}

class _AboutPrivacyItemState extends State<AboutPrivacyItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Widget titleWidget = Padding(
      padding: const EdgeInsets.fromLTRB(22.0, 22.0, 22.0, 4.0),
      child: Text(
        widget.title,
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    final Widget contentWidget = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            Localizer.translate(context, 'lblAboutPrivacyInfo').replaceFirst(
              '%1',
              Localizer.translate(context, 'appName').toUpperCase(),
            ),
            style: TextStyle(fontSize: 16.0),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        titleWidget,
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
          child: Card(
            elevation: 8.0,
            shadowColor: Colors.grey.withAlpha(50),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: contentWidget,
          ),
        ),
      ],
    );
  }
}
