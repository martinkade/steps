import 'package:flutter/material.dart';
import 'package:steps/components/dashboard/dashboard.item.dart';
import 'package:steps/components/shared/localizer.dart';
import 'package:steps/components/shared/segmented.control.dart';
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
  ///
  Map<String, List<FitRankingEntry>> _boards;

  ///
  int _selectedModeIndex;

  @override
  void initState() {
    super.initState();

    _selectedModeIndex = 0;
    _boards = widget.ranking?.entries ?? Map();
  }

  @override
  void didUpdateWidget(DashboardRankingItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    setState(() {
      _boards = widget.ranking?.entries ?? Map();
      print('Update team ranking: $_boards');
    });
  }

  List<OptionModel> _displayOptions(BuildContext context) {
    int index = 0;
    String title;
    final List<OptionModel> options = List();
    _boards.forEach((optionKey, value) {
      if (optionKey == 'today') {
        title = Localizer.translate(context, 'lblToday');
      } else if (optionKey == 'yesterday') {
        title = Localizer.translate(context, 'lblYesterday');
      } else if (optionKey == 'week') {
        title = Localizer.translate(context, 'lblWeek');
      } else {
        title = Localizer.translate(context, 'lblLastWeek');
      }
      options.add(
        OptionModel(
          index: index,
          isSelected: _selectedModeIndex == index,
          title: title,
        ),
      );
      index++;
    });
    return options;
  }

  @override
  Widget build(BuildContext context) {
    final Widget loadingWidget = Container(
      child: Center(
        child: CircularProgressIndicator(),
      ),
      height: 192.0,
    );

    final Widget placeholderWidget = Container(
      child: Center(
        child: Text(
          Localizer.translate(context, 'lblNotAvailable'),
        ),
      ),
      height: 196.0,
    );

    final Widget titleWidget = Padding(
      padding: const EdgeInsets.fromLTRB(22.0, 22.0, 22.0, 4.0),
      child: Text(
        widget.title,
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    final List<OptionModel> displayOptions = _displayOptions(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        titleWidget,
        Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                displayOptions.length == 0
                    ? Container()
                    : Card(
                        elevation: 8.0,
                        shadowColor: Colors.grey.withAlpha(50),
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: SegmentedControl(
                          elevation: 0.0,
                          onChange: (model) {
                            setState(() {
                              _selectedModeIndex = model.index;
                            });
                          },
                          options: displayOptions,
                        ),
                      ),
                Card(
                  elevation: 8.0,
                  shadowColor: Colors.grey.withAlpha(50),
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: widget.ranking == null
                      ? loadingWidget
                      : displayOptions.length == 0
                          ? placeholderWidget
                          : DashboardRankingList(
                              list: _boards[
                                  _boards.keys.toList()[_selectedModeIndex]],
                              teamName: widget.teamName,
                            ),
                ),
              ],
            ))
      ],
    );
  }
}

class DashboardRankingList extends StatelessWidget {
  ///
  final List<FitRankingEntry> list;

  ///
  final String teamName;

  ///
  DashboardRankingList({Key key, this.list, this.teamName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget placeholderWidget = Container(
      child: Center(
        child: Text(
          Localizer.translate(context, 'lblNotAvailable'),
        ),
      ),
      height: 164.0,
    );

    return list.length == 0
        ? placeholderWidget
        : Container(
            constraints: BoxConstraints(
              minHeight: 164.0,
            ),
            child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: list.length,
              itemBuilder: (context, index) {
                final FitRankingEntry item = list[index];
                return Container(
                  color: item.name == teamName
                      ? Theme.of(context).colorScheme.primary.withAlpha(50)
                      : Colors.transparent,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 8.0),
                        child: Container(
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontWeight: item.name == teamName
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
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                          child: Text(
                            item.name,
                            style: TextStyle(
                              fontWeight: item.name == teamName
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 16.0,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 16.0, 8.0),
                        child: Text(
                          item.value,
                          style: TextStyle(
                            fontWeight: item.name == teamName
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
          );
  }
}
