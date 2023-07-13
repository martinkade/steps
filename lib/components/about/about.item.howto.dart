import 'package:flutter/material.dart';
import 'package:wandr/components/about/about.item.dart';

import 'package:wandr/components/shared/localizer.dart';

class AboutHowtoItem extends AboutItem {
  ///
  AboutHowtoItem({Key? key, required String title})
      : super(key: key, title: title);

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
    /*
Localizer.translate(context, 'lblAboutHowTo').replaceFirst(
                  '%1',
                  Localizer.translate(context, 'appName').toUpperCase();
                  */

    final Widget contentWidget = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(32.0, 0.0, 16.0, 8.0),
                child: SizedBox(
                  child: Image.asset('assets/images/faq.png',
                      color: Theme.of(context).textTheme.bodyText1?.color),
                  width: 72.0,
                  height: 72.0,
                ),
              ),
            ],
          ),
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

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 8.0,
        shadowColor: Colors.grey.withAlpha(50),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: contentWidget,
      ),
    );
  }
}
