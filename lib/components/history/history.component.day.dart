import 'package:flutter/material.dart';
import 'package:steps/components/history/history.component.add.dart';
import 'package:steps/components/history/history.item.record.dart';
import 'package:steps/components/shared/localizer.dart';
import 'package:steps/components/shared/page.default.dart';
import 'package:steps/components/shared/route.transition.dart';
import 'package:steps/model/calendar.dart';
import 'package:steps/model/fit.record.dart';
import 'package:steps/model/repositories/fitness.repository.dart';

class HistoryDay extends StatefulWidget {
  ///
  final FitRecord summary;

  ///
  final int goal;

  ///
  HistoryDay({Key key, this.summary, this.goal}) : super(key: key);

  @override
  _HistoryDayState createState() => _HistoryDayState();
}

class _HistoryDayState extends State<HistoryDay> {
  ///
  final DateTime _now = DateTime.now();

  ///
  final Calendar _calendar = Calendar();

  ///
  final List<FitRecord> _records = List();

  ///
  final FitnessRepository _repository = FitnessRepository();

  @override
  void initState() {
    super.initState();

    _load();
  }

  void _load() {
    _repository.fetchHistory(day: widget.summary.dateString).then((records) {
      if (!mounted) return;
      _records.clear();
      setState(() {
        _records.addAll(records);
      });
    });
  }

  void _editRecord(FitRecord record) {
    if (record.source != FitRecord.SOURCE_MANUAL) return;

    Navigator.push(
      context,
      RouteTransition(
        page: HistoryAdd(
          oldRecord: record,
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
              itemCount: _records.length + 1,
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
                            widget.summary.value >= widget.goal
                                ? Localizer.translate(
                                        context, 'lblHistorySummaryDayPositive')
                                    .replaceFirst(
                                        '%1', '${widget.summary.value}')
                                : Localizer.translate(
                                        context, 'lblHistorySummaryDayNegative')
                                    .replaceFirst(
                                        '%1', '${widget.summary.value}'),
                            style: TextStyle(fontSize: 16.0),
                          ),
                          padding: const EdgeInsets.all(16.0),
                        ),
                      ),
                    ),
                  );
                }
                final FitRecord record = _records[index - 1];
                return GestureDetector(
                  child: HistoryRecordItem(
                    record: record,
                    isLastItem: index + 1 == _records.length,
                    calendar: _calendar,
                    now: _now,
                  ),
                  onTap: () {
                    _editRecord(record);
                  },
                );
              },
            ),
      title:
          widget.summary.relativeDate(context, calendar: _calendar, now: _now),
    );
  }
}
