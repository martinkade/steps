import 'dart:math';

import 'package:flutter/material.dart';
import 'package:steps/components/dashboard/dashboard.component.dart';
import 'package:steps/components/landing/landing.item.dart';
import 'package:steps/components/landing/landing.item.identity.dart';
import 'package:steps/components/landing/landing.item.fitaccess.dart';
import 'package:steps/components/landing/landing.item.welcome.dart';
import 'package:steps/components/shared/bezier.clipper.dart';
import 'package:steps/components/shared/localizer.dart';

class Landing extends StatefulWidget {
  ///
  final String title;

  ///
  Landing({Key key, this.title}) : super(key: key);

  @override
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> implements LandingDelegate {
  ///
  ScrollController _scrollController;

  ///
  int _cardIndex = 0;

  ///
  String _title;

  ///
  String _subtitle;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _title = _titleForIndex(_cardIndex);
    _subtitle = _subtitleForIndex(_cardIndex);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _titleForIndex(int index) {
    switch (index) {
      case 1:
        return Localizer.translate(context, 'lblLandingTitle2');
      case 2:
        return Localizer.translate(context, 'lblLandingTitle3');
      default:
        return Localizer.translate(context, 'appName').toUpperCase();
    }
  }

  String _subtitleForIndex(int index) {
    switch (index) {
      case 1:
        return Localizer.translate(context, 'appName').toUpperCase();
      case 2:
        return Localizer.translate(context, 'appName').toUpperCase();
      default:
        return Localizer.translate(context, 'lblLandingTitle1');
    }
  }

  Widget _cardAtIndex(int index, BuildContext context) {
    switch (index) {
      case 1:
        return LandingIdentityItem(index: index, delegate: this);
      case 2:
        return LandingFitAccessItem(index: index, delegate: this);
      default:
        return LandingWelcomeItem(index: index, delegate: this);
    }
  }

  @override
  void nextItem(LandingItem item) {
    if (item.index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Dashboard()),
      );
    } else {
      _cardIndex = min(2, _cardIndex + 1);
      final double cardWidth = MediaQuery.of(context).size.width - 24.0;
      if (item is LandingIdentityItem) {
        final FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      }
      setState(() {
        _title = _titleForIndex(_cardIndex);
        _subtitle = _subtitleForIndex(_cardIndex);
        _scrollController.animateTo(
          _cardIndex * cardWidth + _cardIndex * 16.0,
          duration: Duration(milliseconds: 200),
          curve: Curves.fastOutSlowIn,
        );
      });
    }
  }

  @override
  void previousItem(LandingItem item) {
    _cardIndex = max(0, _cardIndex - 1);
    final double cardWidth = MediaQuery.of(context).size.width - 24.0;
    if (item is LandingIdentityItem) {
      final FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
    }
    setState(() {
      _title = _titleForIndex(_cardIndex);
      _subtitle = _subtitleForIndex(_cardIndex);
      _scrollController.animateTo(
        _cardIndex * cardWidth + _cardIndex * 16.0,
        duration: Duration(milliseconds: 200),
        curve: Curves.fastOutSlowIn,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth = MediaQuery.of(context).size.width - 24.0;
    final double cardHeight = max(cardWidth * 0.75, 256.0);

    final Widget madeWithLove = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Made with'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Icon(Icons.favorite),
        ),
        Text('in Ahaus')
      ],
    );

    final Widget contentWidget = Container(
      height: cardHeight + 16.0,
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemCount: 3,
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(0.0),
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.fromLTRB(8.0, 0.0, index < 2 ? 0.0 : 8.0, 8.0),
            child: Card(
              elevation: 8.0,
              shadowColor: Colors.grey.withAlpha(50),
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Container(
                height: cardHeight,
                width: cardWidth,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _cardAtIndex(index, context),
                ),
              ),
            ),
          );
        },
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ClipPath(
              clipper: BezierClipper(leftHeight: 0.9, rightHeight: 0.67),
              child: Container(
                height: 312.0,
                color: Color.fromARGB(255, 255, 215, 0),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22.0, 64.0, 22.0, 0.0),
                      child: Text(
                        _subtitle,
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22.0, 0.0, 22.0, 24.0),
                      child: Text(
                        _title,
                        style: TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    contentWidget,
                    Container(
                      child: Center(child: madeWithLove),
                      height: 128.0,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
