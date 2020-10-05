import 'package:flutter/material.dart';
import 'package:steps/components/history/history.item.dart';
import 'package:steps/model/calendar.dart';
import 'package:steps/model/fit.record.dart';

class HistoryRecordItem extends HistoryItem {
  ///
  final FitRecord record;

  ///
  final bool isLastItem;

  ///
  final Calendar calendar;

  ///
  final DateTime now;

  ///
  HistoryRecordItem({
    Key key,
    this.record,
    this.isLastItem,
    this.calendar,
    this.now,
  }) : super(key: key);

  @override
  _HistoryRecordItemState createState() => _HistoryRecordItemState();
}

class _HistoryRecordItemState extends State<HistoryRecordItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(
              Icons.edit,
              color: widget.record.source == FitRecord.SOURCE_MANUAL
                  ? Theme.of(context).textTheme.bodyText1.color
                  : Theme.of(context).textTheme.bodyText1.color.withAlpha(32),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Text(
                        widget.record.relativeDateTime(context,
                            calendar: widget.calendar, now: widget.now),
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
                      widget.record.valueString(),
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
