import 'package:flutter/material.dart';
import 'package:steps/components/dashboard/dashboard.item.dart';
import 'package:steps/model/fit.ranking.dart';

class DashboardRankingItem extends DashboardItem {
  ///
  final String userKey;

  ///
  final String teamName;

  ///
  final FitRanking ranking;

  ///
  DashboardRankingItem(
      {Key key, String title, this.ranking, this.userKey, this.teamName})
      : super(key: key, title: title);

  @override
  _DashboardRankingItemState createState() => _DashboardRankingItemState();
}

class _DashboardRankingItemState extends State<DashboardRankingItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Widget loadingWidget = Container(
      child: Center(
        child: CircularProgressIndicator(),
      ),
      height: 96.0,
    );

    final Widget titleWidget = Padding(
      padding: const EdgeInsets.fromLTRB(18.0, 22.0, 20, 4.0),
      child: Text(
        widget.title,
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleWidget,
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
          child: Card(
            elevation: 8.0,
            shadowColor: Colors.grey.withAlpha(50),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: widget.ranking == null
                ? loadingWidget
                : ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: widget.ranking?.entries?.length ?? 0,
                    itemBuilder: (context, index) {
                      final item = widget.ranking?.entries[index];
                      Color color;
                      switch (index) {
                        case 0:
                          color = Color.fromARGB(255, 255, 215, 0);
                          break;
                        case 1:
                          color = Color.fromARGB(255, 192, 192, 192);
                          break;
                        case 2:
                          color = Color.fromARGB(255, 205, 127, 50);
                          break;
                        default:
                          color = Color.fromARGB(255, 235, 235, 235);
                          break;
                      }
                      return Container(
                        color: item.name == widget.teamName
                            ? Colors.blue.withAlpha(50)
                            : Colors.transparent,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  16.0, 8.0, 8.0, 8.0),
                              child: Container(
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontWeight: item.name == widget.teamName
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 16.0,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                width: 32.0,
                                height: 32.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(16.0),
                                  ),
                                  color: color,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    8.0, 8.0, 8.0, 8.0),
                                child: Text(
                                  item.name,
                                  style: TextStyle(
                                    fontWeight: item.name == widget.teamName
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 16.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  8.0, 8.0, 16.0, 8.0),
                              child: Text(
                                item.value,
                                style: TextStyle(
                                  fontWeight: item.name == widget.teamName
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 16.0,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        )
      ],
    );
  }
}
