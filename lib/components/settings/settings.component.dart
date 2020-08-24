import 'package:flutter/material.dart';
import 'package:steps/components/settings/settings.item.sync.dart';
import 'package:steps/components/shared/localizer.dart';

class Settings extends StatefulWidget {
  ///
  Settings({Key key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 215, 0),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    child: Icon(
                      Icons.arrow_back,
                      size: 32.0,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        Localizer.translate(context, 'lblSettings'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: ListView.builder(
                  itemCount: 1,
                  itemBuilder: (context, index) {
                    switch (index) {
                      case 0:
                        return SettingsSyncItem(
                          title: Localizer.translate(
                              context, 'lblSettingsDataSource'),
                        );
                      default:
                        return Container();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
