import 'package:flutter/material.dart';
import 'package:steps/components/dashboard/dashboard.item.dart';

abstract class DashboardTitleDelegate {
  void onSettingsRequested();
}

class DashboardTitleItem extends DashboardItem {
  ///
  final DashboardTitleDelegate delegate;

  ///
  DashboardTitleItem({Key key, String title, this.delegate})
      : super(key: key, title: title);

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
      padding: const EdgeInsets.fromLTRB(24.0, 44.0, 24.0, 36.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            child: Image.asset('assets/images/logo.png'),
            width: 192.0,
            height: 36.0,
          ),
          GestureDetector(
            child: Icon(Icons.settings),
            onTap: () {
              widget.delegate?.onSettingsRequested();
            },
          ),
        ],
      ),
    );

    return Container(child: titleWidget);
  }
}
