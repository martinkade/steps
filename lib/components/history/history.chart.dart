import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:steps/components/shared/localizer.dart';
import 'package:steps/model/calendar.dart';
import 'package:steps/model/fit.record.dart';

class HistoryChart extends StatefulWidget {
  ///
  final List<charts.Series> series;

  ///
  final bool animate;

  ///
  final ThemeData theme;

  ///
  HistoryChart({
    Key key,
    @required this.series,
    @required this.theme,
    this.animate,
  }) : super(key: key);

  @override
  _HistoryChartState createState() => _HistoryChartState();

  ///
  factory HistoryChart.withData(List<FitRecord> data,
      {Color color, @required ThemeData theme, bool animate}) {
    return HistoryChart(
      series: _createData(data, theme: theme),
      theme: theme,
      animate: animate,
    );
  }

  ///
  static charts.Color colorFrom(Color color) {
    return charts.Color(
      r: color.red,
      g: color.green,
      b: color.blue,
    );
  }

  ///
  static List<charts.Series<FitRecord, DateTime>> _createData(
      List<FitRecord> data,
      {ThemeData theme}) {
    final charts.Color seriesColor = colorFrom(theme.colorScheme.primary);
    return [
      charts.Series<FitRecord, DateTime>(
        id: 'Punkte',
        colorFn: (_, __) => seriesColor,
        domainFn: (FitRecord record, _) => record.dateTime,
        measureFn: (FitRecord record, _) => record.value,
        data: data,
      )
    ];
  }
}

class _HistoryChartState extends State<HistoryChart> {
  ///
  FitRecord _record;

  @override
  void initState() {
    super.initState();
  }

  ///
  void _infoSelectionModelUpdated(charts.SelectionModel<DateTime> model) {
    FitRecord record;
    if (model.selectedDatum.isNotEmpty) {
      record = model.selectedDatum.first.datum;
    }
    if (record != null && _record?.dateString != record.dateString) {
      setState(() {
        _record = record;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_record?.relativeDate(context, calendar: Calendar(), now: DateTime.now()) ?? Localizer.translate(context, 'lblHistoryChartTapInstruction')}',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '${_record?.value ?? '-'} ${Localizer.translate(context, 'lblUnitPoints')}',
        ),
        Container(
          height: width * 0.33,
          child: charts.TimeSeriesChart(
            widget.series,
            selectionModels: [
              charts.SelectionModelConfig(
                type: charts.SelectionModelType.info,
                updatedListener: _infoSelectionModelUpdated,
              ),
            ],
            animate: widget.animate,
            dateTimeFactory: const charts.LocalDateTimeFactory(),
            domainAxis: charts.DateTimeAxisSpec(
              renderSpec: charts.SmallTickRendererSpec(
                labelStyle: charts.TextStyleSpec(
                  fontSize: 14,
                  color: HistoryChart.colorFrom(
                      widget.theme.textTheme.bodyText1.color),
                ),
                lineStyle: charts.LineStyleSpec(
                  color: HistoryChart.colorFrom(
                      widget.theme.textTheme.bodyText1.color),
                ),
              ),
            ),
            primaryMeasureAxis: charts.NumericAxisSpec(
              renderSpec: charts.GridlineRendererSpec(
                labelStyle: charts.TextStyleSpec(
                  fontSize: 14,
                  color: HistoryChart.colorFrom(
                      widget.theme.textTheme.bodyText1.color),
                ),
                lineStyle: charts.LineStyleSpec(
                  color: HistoryChart.colorFrom(
                      widget.theme.textTheme.bodyText1.color),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
