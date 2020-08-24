import 'package:flutter/material.dart';
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

    _repository.fetchHistory().then((records) {
      if (!mounted) return;
      _records.clear();
      setState(() {
        _records.addAll(records);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultPage(
      child: ListView.builder(
        itemCount: _records.length,
        itemBuilder: (context, index) {
          final FitRecord record = _records[index];
          return HistoryRecordItem(
            record: record,
            isLastItem: index + 1 == _records.length,
          );
        },
      ),
      title: Localizer.translate(context, 'lblHistory'),
    );
  }
}
