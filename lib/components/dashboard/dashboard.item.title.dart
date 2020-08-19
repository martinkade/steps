import 'package:flutter/material.dart';
import 'package:steps/components/dashboard/dashboard.item.dart';

class DashboardTitleItem extends DashboardItem {
  ///
  DashboardTitleItem({Key key, String title}) : super(key: key, title: title);

  @override
  _DashboardTitleItemState createState() => _DashboardTitleItemState();
}

class _DashboardTitleItemState extends State<DashboardTitleItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Widget titleWidget = Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 36.0, 16.0, 32.0),
      child: Text(
        widget.title.toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    return Container(child: titleWidget);
  }
}
