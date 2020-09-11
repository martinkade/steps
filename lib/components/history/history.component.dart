import 'package:flutter/material.dart';
import 'package:steps/components/history/history.chart.dart';
import 'package:steps/components/history/history.component.day.dart';
import 'package:steps/components/history/history.item.record.summary.dart';
import 'package:steps/components/shared/localizer.dart';
import 'package:steps/components/shared/page.default.dart';
import 'package:steps/model/fit.record.dart';
import 'package:steps/model/preferences.dart';
import 'package:steps/model/repositories/fitness.repository.dart';

class History extends StatefulWidget {
  ///
  History({Key key}) : super(key: key);

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  ///
  final List<FitRecord> _records = List();

  ///
  final FitnessRepository _repository = FitnessRepository();

  ///
  int _points;

  ///
  int _goalDaily;

  @override
  void initState() {
    super.initState();

    _points = 0;
    _goalDaily = 0;
    _load();
  }

  void _load() {
    Preferences().getDailyGoal().then((value) {
      if (!mounted) return;
      _goalDaily = value;
    });
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
  }

  void _displayRecord(FitRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryDay(
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
            Localizer.translate(context, 'lblNoRecordsAfter'),
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
                                .replaceFirst('%2', '${_points ~/ 12}'),
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
                            .color
                            .withAlpha(50),
                        child: Padding(
                          child: HistoryChart.withData(
                            _records,
                            theme: Theme.of(context),
                          ),
                          padding: const EdgeInsets.all(16.0),
                        ),
                      ),
                    ),
                  );
                }
                final FitRecord record = _records[index - 2];
                return GestureDetector(
                  child: HistoryRecordSummaryItem(
                    record: record,
                    isLastItem: index + 1 == _records.length,
                    goal: _goalDaily,
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
