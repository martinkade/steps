import 'package:flutter/material.dart';
import 'package:wandr/components/dashboard/dashboard.item.dart';
import 'package:wandr/components/settings/settings.item.difficulty.dart';
import 'package:wandr/components/shared/localizer.dart';
import 'package:wandr/components/shared/segmented.control.dart';
import 'package:wandr/model/fit.ranking.dart';
import 'package:wandr/model/preferences.dart';
import 'package:wandr/util/AprilJokes.dart';

class DashboardRankingItem extends DashboardItem {
  ///
  final String? userKey;

  ///
  final String? teamName;

  ///
  final String? organizationName;

  ///
  final FitRanking? ranking;

  ///
  DashboardRankingItem({
    Key? key,
    required String title,
    this.ranking,
    this.userKey,
    this.teamName,
    this.organizationName,
  }) : super(key: key, title: title);

  @override
  DashboardRankingItemState createState() => DashboardRankingItemState();
}

class DashboardRankingItemState extends State<DashboardRankingItem>
    with AutomaticKeepAliveClientMixin<DashboardRankingItem> {
  ///
  Map<String, List<FitRankingEntry>> _boards = Map();

  ///
  int _selectedTimeModeIndex = 0;

  ///
  int _selectedGroupModeIndex = 0;

  ///
  bool _unitKilometersEnabled = false;

  ///
  int _difficultyLevel = Difficulties.hard.index;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _selectedTimeModeIndex = 0;
    _selectedGroupModeIndex = 0;
    _boards = widget.ranking?.entries ?? Map();
    _unitKilometersEnabled = false;
    _difficultyLevel = Difficulties.hard.index;
    Preferences().isFlagSet(kFlagUnitKilometers).then((enabled) {
      setState(() {
        _unitKilometersEnabled = enabled;
      });
    });
    Preferences().getDifficultyLevel().then((value) {
      setState(() {
        _difficultyLevel = value;
      });
    });
  }

  void reload(bool unitKilometersEnabled, int difficultyLevel) {
    setState(() {
      _unitKilometersEnabled = unitKilometersEnabled;
      _difficultyLevel = difficultyLevel;
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
          isSelected: _selectedTimeModeIndex == index,
          title: title,
        ),
      );
      index++;
    });
    return options;
  }

  List<OptionModel> _displayGroupOptions(BuildContext context) {
    final List<OptionModel> options = <OptionModel>[];

    options.add(OptionModel(
      index: 0,
      isSelected: _selectedGroupModeIndex == FitRanking.fitRankingTypeSingle,
      title: Localizer.translate(context, 'lblSingle'),
    ));
    options.add(OptionModel(
      index: 1,
      isSelected: _selectedGroupModeIndex == FitRanking.fitRankingTypeTeam,
      title: Localizer.translate(context, 'lblTeam'),
    ));
    options.add(OptionModel(
      index: 2,
      isSelected:
          _selectedGroupModeIndex == FitRanking.fitRankingTypeOrganization,
      title: Localizer.translate(context, 'lblOrganization'),
    ));
    return options;
  }

  @override
  Widget build(BuildContext context) {
    final Widget titleWidget = Padding(
      padding: const EdgeInsets.fromLTRB(22.0, 22.0, 22.0, 4.0),
      child: Text(
        '${widget.ranking?.totalUsers ?? 0} ${Localizer.translate(context, 'lblActiveUsers')}',
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    final List<OptionModel> displayOptions = _displayOptions(context);
    final List<OptionModel> displayGroupOptions = _displayGroupOptions(context);

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
                displayGroupOptions.length == 0
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
                                _selectedGroupModeIndex = model.index;
                              });
                            },
                            options: displayGroupOptions,
                            scrollable: false,
                          ),
                        ),
                      ),
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
                                _selectedTimeModeIndex = model.index;
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
                    child: getList(displayOptions: displayOptions)),
              ],
            ))
      ],
    );
  }

  Widget getList({required List<OptionModel> displayOptions}) {
    if (widget.ranking == null) {
      return Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
        height: 192.0,
      );
    } else if (displayOptions.length == 0) {
      return Container(
        child: Center(
          child: Text(
            Localizer.translate(context, 'lblNotAvailable'),
          ),
        ),
        height: 196.0,
      );
    } else {
      final List<FitRankingEntry> list =
          _boards[_boards.keys.toList()[_selectedTimeModeIndex]] ?? [];
      return DashboardRankingList(
          list: list
              .where((element) => element.type == _selectedGroupModeIndex)
              .toList(),
          itemKey: widget.userKey!,
          unitKilometersEnabled: _unitKilometersEnabled,
          difficultyLevel: _difficultyLevel,
          groupType: _selectedGroupModeIndex);
    }
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
  final int difficultyLevel;

  ///
  final int groupType;

  ///
  DashboardRankingList(
      {Key? key,
      required this.list,
      required this.itemKey,
      required this.unitKilometersEnabled,
      required this.difficultyLevel,
      required this.groupType})
      : super(key: key);

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
    if (list.isEmpty) {
      return placeholderWidget;
    } else {
      final jokes = AprilJokes();
      final int extraValue = jokes.isJokeActive(Jokes.rankingLast)
          ? jokes.getRankingLastExtraValue(list, itemKey)
          : 0;

      if (jokes.isJokeActive(Jokes.botDifficulty)) {
        jokes.updateList(list, difficultyLevel);
      }

      return Container(
        constraints: BoxConstraints(
          minHeight: 164.0,
        ),
        child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: list.length,
          itemBuilder: (context, index) {
            final FitRankingEntry item = list[index];
            final int value =
                (item.key == itemKey ? item.value : item.value + extraValue)
                    .toInt();
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
                          value > 0 ? '${index + 1}' : '',
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
                        border: value > 0
                            ? Border.all(
                                color: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        ?.color ??
                                    Color.fromARGB(50, 50, 50, 50),
                              )
                            : null,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
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
                            groupType == FitRanking.fitRankingTypeSingle
                                ? ''
                                    '${Localizer.translate(context, 'lblSingleSync')}: ${item.timestamp}'
                                : '${Localizer.translate(context, 'lblTeamUserCount')}: ${item.userCount}',
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
                              ? (value / 12.0).toStringAsFixed(1)
                              : value.toStringAsFixed(0),
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
                              ? Localizer.translate(context, 'lblUnitKilometer')
                              : Localizer.translate(context, 'lblUnitPoints'),
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
}
