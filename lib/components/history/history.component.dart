import 'package:flutter/material.dart';
import 'package:wandr/components/history/history.chart.dart';
import 'package:wandr/components/history/history.component.day.dart';
import 'package:wandr/components/history/history.item.record.summary.dart';
import 'package:wandr/components/shared/localizer.dart';
import 'package:wandr/components/shared/page.default.dart';
import 'package:wandr/components/shared/route.transition.dart';
import 'package:wandr/model/cache/fit.record.dao.dart';
import 'package:wandr/model/fit.record.dart';
import 'package:wandr/model/preferences.dart';
import 'package:wandr/model/repositories/fitness.repository.dart';

class HistoryComponent extends StatefulWidget {
  ///
  HistoryComponent({Key? key}) : super(key: key);

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<HistoryComponent> {
  ///
  final List<FitRecord> _records = <FitRecord>[];

  ///
  final List<AverageRecord> _averageList = <AverageRecord>[];

  ///
  final FitnessRepository _repository = FitnessRepository();

  ///
  int _points = 0;

  ///
  int _goalDaily = 0;

  ///
  bool _unitKilometersEnabled = false;

  @override
  void initState() {
    super.initState();

    _points = 0;
    _goalDaily = 0;
    _unitKilometersEnabled = false;
    _load();
  }

  void _load() {
    FitRecordDao().fetchAverageByDayOfWeek().then((averageList) {
      if (!mounted) return;
      _averageList.clear();
      setState(() {
        _averageList.addAll(averageList);
      });
    }).catchError((_) {});

    Preferences().getDailyGoal().then((value) {
      if (!mounted) return;
      _goalDaily = value;
      Preferences().isFlagSet(kFlagUnitKilometers).then((enabled) {
        if (!mounted) return;
        _unitKilometersEnabled = enabled;
        _repository.fetchHistory().then((records) {
          if (!mounted) return;
          _points = 0;
          records.forEach((record) {
            _points += record.value;
          });
          _records.clear();
          setState(() {
            _records.addAll(records);
          });
        });
      });
    });
  }

  void _displayRecord(FitRecord record) {
    Navigator.push(
      context,
      RouteTransition(
        page: HistoryDay(
          summary: record,
          goal: _goalDaily,
        ),
      ),
    ).then((_) {
      _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget placeholderWidget = Container(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            Localizer.translate(context, 'lblNoRecords'),
          ),
        ),
      ),
    );

    return DefaultPage(
      child: _records.length == 0
          ? placeholderWidget
          : ListView.builder(
              itemCount: _records.length + 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
                    child: Card(
                      elevation: 8.0,
                      shadowColor: Colors.grey.withAlpha(50),
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Container(
                        color:
                            Theme.of(context).colorScheme.primary.withAlpha(50),
                        child: Padding(
                          child: Text(
                            Localizer.translate(context, 'lblHistorySummary')
                                .replaceFirst('%1', '$_points')
                                .replaceFirst('%2',
                                    '${(_points / 12.0).toStringAsFixed(1)}'),
                            style: TextStyle(fontSize: 16.0),
                          ),
                          padding: const EdgeInsets.all(16.0),
                        ),
                      ),
                    ),
                  );
                } else if (index == 1) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                    child: Card(
                      elevation: 8.0,
                      shadowColor: Colors.grey.withAlpha(32),
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Container(
                        color: Theme.of(context)
                            .textTheme
                            .bodyText1
                            ?.color
                            ?.withAlpha(50),
                        child: Padding(
                          child: HistoryChart.withData(
                            _records,
                            target: _goalDaily,
                            unitKilometersEnabled: _unitKilometersEnabled,
                            theme: Theme.of(context),
                            animate: false,
                          ),
                          padding: const EdgeInsets.all(16.0),
                        ),
                      ),
                    ),
                  );
                }
                final FitRecord record = _records[index - 2];
                final AverageRecord averageRecord = _averageList.firstWhere(
                    (e) => e.isSameDay(record.dateTime),
                    orElse: () => AverageRecord());
                return GestureDetector(
                  child: HistoryRecordSummaryItem(
                    record: record,
                    isLastItem: index + 1 == _records.length,
                    goal: _goalDaily,
                    trend: averageRecord.value <= record.value ? 1 : -1,
                    unitKilometersEnabled: _unitKilometersEnabled,
                  ),
                  onTap: () {
                    _displayRecord(record);
                  },
                );
              },
            ),
      title: Localizer.translate(context, 'lblHistory'),
    );
  }
}
