import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:steps/components/dashboard/dashboard.component.dart';
import 'package:steps/components/history/history.component.dart';
import 'package:steps/components/landing/landing.component.dart';
import 'package:steps/components/settings/settings.component.dart';
import 'package:steps/components/shared/localizer.dart';
import 'package:steps/components/shared/route.transition.dart';
import 'package:steps/model/preferences.dart';

class Tabs extends StatefulWidget {
  ///
  final String title;

  ///
  Tabs({Key key, this.title}) : super(key: key);

  @override
  _TabsState createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  ///
  String _userName;

  ///
  String _teamName;

  ///
  int _tabIndex;

  ///
  final List<Widget> _tabWidgets = [];

  @override
  void initState() {
    super.initState();

    _tabIndex = 0;

    Preferences.getUserKey().then((userValue) {
      if (!mounted) return;

      if (userValue != null) {
        setState(() {
          _userName = userValue.split('@').first?.replaceAll('.', '_');
          print('Init data for kUser=$_userName');
          _userName = _md5(_userName);
          _teamName = 'Team mediaBEAM';
        });

        _load();
      } else {
        _land();
      }
    });
  }

  String _md5(String value) {
    return md5.convert(utf8.encode(value)).toString();
  }

  void _land() {
    Navigator.pushReplacement(
      context,
      RouteTransition(page: Landing()),
    );
  }

  void _load() {
    _tabWidgets.clear();
    _tabWidgets.add(
      DashboardComponent(title: 'Home'),
    );
    _tabWidgets.add(HistoryComponent());
    _tabWidgets.add(SettingsComponent());
    setState(() {
      _tabIndex = 0;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _tabIndex = index;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.yellow
          : Colors.black,
      body: SafeArea(
        child: _userName == null || _teamName == null
            ? Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: _tabWidgets[_tabIndex],
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            title: Text(
              Localizer.translate(context, 'lblHistory'),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text(
              Localizer.translate(context, 'lblSettings'),
            ),
          ),
        ],
        currentIndex: _tabIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
    );
  }
}
