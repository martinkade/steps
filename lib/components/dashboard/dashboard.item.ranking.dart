import 'package:flutter/material.dart';
import 'package:wandr/components/dashboard/dashboard.item.dart';
import 'package:wandr/components/shared/localizer.dart';
import 'package:wandr/components/shared/segmented.control.dart';
import 'package:wandr/model/fit.ranking.dart';
import 'package:wandr/model/preferences.dart';

class DashboardRankingItem extends DashboardItem {
  ///
  final String userKey;

  ///
  final String teamName;

  ///
  final FitRanking ranking;

  ///
  DashboardRankingItem({
    Key key,
    String title,
    this.ranking,
    this.userKey,
    this.teamName,
  }) : super(key: key, title: title);

  @override
  DashboardRankingItemState createState() => DashboardRankingItemState();
}

class DashboardRankingItemState extends State<DashboardRankingItem>
    with AutomaticKeepAliveClientMixin<DashboardRankingItem> {
  ///
  Map<String, List<FitRankingEntry>> _boards;

  ///
  int _selectedModeIndex;

  ///
  bool _unitKilometersEnabled;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _selectedModeIndex = 0;
    _boards = widget.ranking?.entries ?? Map();
    _unitKilometersEnabled = false;
    Preferences().isFlagSet(kFlagUnitKilometers).then((enabled) {
      setState(() {
        _unitKilometersEnabled = enabled;
      });
    });
  }

  void reload(bool unitKilometersEnabled) {
    setState(() {
      _unitKilometersEnabled = unitKilometersEnabled;
    });
  }

  @override
  void didUpdateWidget(DashboardRankingItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    setState(() {
      _boards = widget.ranking?.entries ?? Map();
      print('Update team ranking with ${_boards.length} boards: $_boards');
    });
  }

  List<OptionModel> _displayOptions(BuildContext context) {
    int index = 0;
    String title;
    final List<OptionModel> options = <OptionModel>[];
    _boards.forEach((optionKey, value) {
      if (optionKey == 'today') {
        title = Localizer.translate(context, 'lblToday');
      } else if (optionKey == 'yesterday') {
        title = Localizer.translate(context, 'lblYesterday');
      } else if (optionKey == 'week') {
        title = Localizer.translate(context, 'lblWeek');
      } else if (optionKey == 'lastWeek') {
        title = Localizer.translate(context, 'lblLastWeek');
      } else {
        title = Localizer.translate(context, 'lblOverall');
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
        '${widget.ranking.totalUsers} ${Localizer.translate(context, 'lblActiveUsers')}',
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
                        child: Container(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withAlpha(50),
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
                              itemKey: widget.userKey,
                              unitKilometersEnabled: _unitKilometersEnabled,
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
  final String itemKey;

  ///
  final bool unitKilometersEnabled;

  ///
  DashboardRankingList({
    Key key,
    this.list,
    this.itemKey,
    this.unitKilometersEnabled,
  }) : super(key: key);

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
                  color: item.key == itemKey
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
                              item.value > 0 ? '${index + 1}' : '',
                              style: TextStyle(
                                fontWeight: item.name == itemKey
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
                            border: item.value > 0
                                ? Border.all(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .color,
                                  )
                                : null,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: item.key == itemKey
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 16.0,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              Text(
                                'Sync: ${item.timestamp}',
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 16.0, 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              unitKilometersEnabled
                                  ? (item.value / 12.0).toStringAsFixed(1)
                                  : item.value.toStringAsFixed(0),
                              style: TextStyle(
                                fontWeight: item.key == itemKey
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 16.0,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            Text(
                              unitKilometersEnabled
                                  ? Localizer.translate(
                                      context, 'lblUnitKilometer')
                                  : Localizer.translate(
                                      context, 'lblUnitPoints'),
                            ),
                          ],
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
