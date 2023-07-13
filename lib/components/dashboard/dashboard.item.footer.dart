import 'package:flutter/material.dart';
import 'package:wandr/components/dashboard/dashboard.item.dart';
import 'package:wandr/model/fit.plugin.dart';

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

  @override
  Widget build(BuildContext context) {
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
