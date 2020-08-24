import 'package:flutter/material.dart';
import 'package:steps/components/shared/localizer.dart';

abstract class DashboardInfoItemDelegate {
  void onSettingsRequested();
  void onHistoryRequested();
  void onNewRecordRequested();
  void onInfoRequested();
}

class DashboardInfoItem extends StatelessWidget {
  ///
  final DashboardInfoItemDelegate delegate;

  ///
  DashboardInfoItem({Key key, this.delegate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
      child: Card(
        elevation: 8.0,
        shadowColor: Colors.grey.withAlpha(50),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Container(
          color: Colors.blue.withAlpha(50),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    DashboardAction(
                      title: Localizer.translate(
                          context, 'lblDashboardActionHistory'),
                      icon: Icons.history,
                      onTap: () {
                        delegate?.onHistoryRequested();
                      },
                    ),
                    DashboardAction(
                      title: Localizer.translate(
                          context, 'lblDashboardActionNewRecord'),
                      icon: Icons.add_circle_outline,
                      onTap: () {
                        delegate?.onNewRecordRequested();
                      },
                    ),
                    DashboardAction(
                      title: Localizer.translate(
                          context, 'lblDashboardActionSettings'),
                      icon: Icons.settings,
                      onTap: () {
                        delegate?.onSettingsRequested();
                      },
                    ),
                  ],
                ),
                Divider(),
                GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
                    child: Center(
                      child: Text(
                        Localizer.translate(context, 'lblDashboardInfo')
                            .replaceFirst(
                          '%1',
                          Localizer.translate(context, 'appName').toUpperCase(),
                        ),
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    delegate?.onInfoRequested();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardAction extends StatelessWidget {
  ///
  final String title;

  ///
  final IconData icon;

  ///
  final Function onTap;

  ///
  DashboardAction({Key key, this.title, this.icon, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width / 3.0 - 32.0;
    return GestureDetector(
      child: SizedBox(
        width: width,
        child: Column(
          children: [
            Icon(
              icon,
              size: 32.0,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                title,
              ),
            ),
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}
