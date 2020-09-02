import 'package:flutter/material.dart';
import 'package:steps/components/history/history.component.add.dart';
import 'package:steps/components/history/history.item.record.dart';
import 'package:steps/components/shared/localizer.dart';
import 'package:steps/components/shared/page.default.dart';
import 'package:steps/model/fit.challenge.dart';
import 'package:steps/model/fit.record.dart';
import 'package:intl/intl.dart';
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

  @override
  void initState() {
    super.initState();

    _points = 0;
    _load();
  }

  void _load() {
    _repository.fetchHistory().then((records) {
      if (!mounted) return;
      _points = 0;
      records.forEach((record) {
        if (record.type == FitRecord.TYPE_STEPS) {
          _points += record.value ~/ 80;
        } else {
          _points += record.value;
        }
      });
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
      MaterialPageRoute(
        builder: (context) => HistoryAdd(
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
            Localizer.translate(context, 'lblNoRecordsAfter'),
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
                }
                final FitRecord record = _records[index - 1];
                return GestureDetector(
                  child: HistoryRecordItem(
                    record: record,
                    isLastItem: index + 1 == _records.length,
                  ),
                  onTap: () {
                    _editRecord(record);
                  },
                );
              },
            ),
      title: Localizer.translate(context, 'lblHistory'),
    );
  }
}
