import 'package:flutter/material.dart';
import 'package:steps/components/about/about.item.dart';

import 'package:steps/components/shared/localizer.dart';

class AboutHowtoItem extends AboutItem {
  ///
  AboutHowtoItem({Key key, String title}) : super(key: key, title: title);

  @override
  _AboutHowtoItemState createState() => _AboutHowtoItemState();
}

class _AboutHowtoItemState extends State<AboutHowtoItem> {
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
            Localizer.translate(context, 'lblUnitPoints'),
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            Localizer.translate(context, 'lblAboutHowToInfoPoints')
                .replaceFirst(
              '%1',
              Localizer.translate(context, 'appName').toUpperCase(),
            ),
            style: TextStyle(fontSize: 16.0),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              Localizer.translate(context, 'lblUnitKilometer'),
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            Localizer.translate(context, 'lblAboutHowToInfoKilometer')
                .replaceFirst(
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
