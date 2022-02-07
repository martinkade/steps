import 'package:flutter/material.dart';
import 'package:wandr/components/history/history.item.dart';
import 'package:wandr/components/shared/localizer.dart';
import 'package:wandr/model/calendar.dart';
import 'package:wandr/model/fit.record.dart';

class HistoryRecordSummaryItem extends HistoryItem {
  ///
  final FitRecord record;

  ///
  final bool isLastItem;

  ///
  final int goal;

  ///
  final int trend;

  ///
  final bool unitKilometersEnabled;

  ///
  HistoryRecordSummaryItem({
    Key key,
    this.record,
    this.isLastItem,
    this.goal,
    this.trend,
    this.unitKilometersEnabled,
  }) : super(key: key);

  @override
  _HistoryRecordSummaryItemState createState() =>
      _HistoryRecordSummaryItemState();
}

class _HistoryRecordSummaryItemState extends State<HistoryRecordSummaryItem> {
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
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 8.0),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: widget.record.value >= widget.goal
                ? Icon(
                    Icons.check_circle_outline,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : Icon(
                    Icons.check_circle_outline,
                    color: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .color
                        .withAlpha(32),
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
                        widget.record.relativeDate(context,
                            calendar: _calendar, now: _now),
                      ),
                    ),
                    Text(
                      widget.unitKilometersEnabled
                          ? Localizer.translate(context, 'lblUnitKilometer')
                          : Localizer.translate(context, 'lblUnitPoints'),
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
                      widget.record.valueString(
                          displayKilometers: widget.unitKilometersEnabled),
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: widget.trend < 0
                ? Icon(
                    Icons.arrow_downward_rounded,
                    color: Colors.red,
                  )
                : Icon(
                    Icons.arrow_upward_rounded,
                    color: Colors.green,
                  ),
          ),
          Icon(Icons.navigate_next),
        ],
      ),
    );
  }
}
