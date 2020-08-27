import 'package:flutter/material.dart';
import 'package:steps/components/history/history.component.add.dart';
import 'package:steps/components/history/history.item.record.dart';
import 'package:steps/components/shared/localizer.dart';
import 'package:steps/components/shared/page.default.dart';
import 'package:steps/model/fit.record.dart';
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

  @override
  void initState() {
    super.initState();

    _load();
  }

  void _load() {
    _repository.fetchHistory().then((records) {
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
        child: Text(
          Localizer.translate(context, 'lblNotAvailable'),
        ),
      ),
    );

    return DefaultPage(
      child: _records.length == 0
          ? placeholderWidget
          : ListView.builder(
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final FitRecord record = _records[index];
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
