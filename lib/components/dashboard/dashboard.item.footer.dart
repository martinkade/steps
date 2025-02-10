import 'package:flutter/material.dart';
import 'package:wandr/components/dashboard/dashboard.item.dart';
import 'package:wandr/components/dashboard/dashboard.item.debug.dialog.dart';
import 'package:wandr/model/fit.plugin.dart';
import 'package:wandr/model/preferences.dart';
import 'package:wandr/util/AprilJokes.dart';

class DashboardFooterItem extends DashboardItem {
  ///
  DashboardFooterItem({Key? key, required String title})
      : super(key: key, title: title);

  @override
  _DashboardFooterItemState createState() => _DashboardFooterItemState();
}

class _DashboardFooterItemState extends State<DashboardFooterItem> {
  ///
  late String _appVersion;

  int touchCount = 0;

  @override
  void initState() {
    super.initState();

    _appVersion = "unknown";
    FitPlugin.getAppInfo().then((version) {
      if (!mounted) return;
      setState(() {
        _appVersion = version;
      });
    });
  }

  void showDebugMenu(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: DashboardDebugDialog(
              setJokeActive: (jokeIndex) {
                Navigator.of(context).pop();
              },
            ),
          );
        }).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget madeWithLove = GestureDetector(
        onTap: () {
          touchCount += 1;
          if (touchCount >= 3) {
            touchCount = 0;
            showDebugMenu(context);
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Made with'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Icon(Icons.favorite),
            ),
            Text('in Ahaus')
          ],
        ));

    return Container(
      height: 128.0,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            madeWithLove,
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                  TextSpan(
                    text: widget.title.toUpperCase(),
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' v$_appVersion',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
