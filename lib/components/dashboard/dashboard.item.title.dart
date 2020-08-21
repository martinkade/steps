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
      padding: const EdgeInsets.fromLTRB(16.0, 44.0, 16.0, 36.0),
      child: SizedBox(
        child: Image.asset('assets/images/logo.png'),
        width: 256.0,
        height: 48.0,
      ),
    );

    return Container(child: titleWidget);
  }
}
