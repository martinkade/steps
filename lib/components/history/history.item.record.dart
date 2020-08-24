import 'package:flutter/material.dart';
import 'package:steps/components/history/history.item.dart';
import 'package:steps/model/calendar.dart';
import 'package:steps/model/fit.record.dart';

abstract class HistoryRecordDelegate {
  // void onSettingsRequested();
}

class HistoryRecordItem extends HistoryItem {
  ///
  final FitRecord record;

  ///
  final HistoryRecordDelegate delegate;

  ///
  final bool isLastItem;

  ///
  HistoryRecordItem({Key key, this.record, this.isLastItem, this.delegate})
      : super(key: key);

  @override
  _HistoryRecordItemState createState() => _HistoryRecordItemState();
}

class _HistoryRecordItemState extends State<HistoryRecordItem> {
  ///
  final DateTime _now = DateTime.now();

  ///
  final Calendar _calendar = Calendar();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Text(
                  widget.record
                      .relativeDate(context, calendar: _calendar, now: _now),
                ),
              ),
              Text(
                widget.record.typeString(context),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Text(
                  widget.record.title(context),
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${widget.record.value}',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
