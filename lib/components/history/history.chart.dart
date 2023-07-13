import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wandr/components/shared/localizer.dart';
import 'package:wandr/model/calendar.dart';
import 'package:wandr/model/fit.record.dart';

class HistoryChart extends StatefulWidget {
  ///
  final _ChartData series;

  ///
  final bool animate;

  ///
  final ThemeData theme;

  ///
  final int target;

  ///
  final bool unitKilometersEnabled;

  ///
  HistoryChart({
    Key? key,
    required this.series,
    required this.target,
    required this.unitKilometersEnabled,
    required this.theme,
    this.animate = false,
  }) : super(key: key);

  @override
  _HistoryChartState createState() => _HistoryChartState();

  ///
  factory HistoryChart.withData(List<FitRecord> data,
      {int target = 0,
      required bool unitKilometersEnabled,
      Color? color,
      required ThemeData theme,
      bool animate = false}) {
    return HistoryChart(
      series: _createData(
        data,
        theme: theme,
        unitKilometersEnabled: unitKilometersEnabled,
      ),
      target: target,
      unitKilometersEnabled: unitKilometersEnabled,
      theme: theme,
      animate: animate,
    );
  }

  ///
  static _ChartData _createData(List<FitRecord> data,
      {required ThemeData theme, bool unitKilometersEnabled = false}) {
    final double minX = 0.0, maxX = data.length - 1;
    double minY = 1000.0, maxY = 0.0, x = 0.0, y = 0.0;
    final List<FlSpot> dataset = <FlSpot>[];
    data.forEach((record) {
      y = unitKilometersEnabled
          ? (record.value / 12.0).toDouble()
          : record.value.toDouble();
      if (y < minY) minY = y;
      if (y > maxY) maxY = y;
      dataset.add(FlSpot(
          x.toDouble(), // record.dateTime,
          y));
      x += 1;
    });
    return _ChartData(
      dataset: dataset,
      minX: minX,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
    );
  }
}

class _ChartData {
  final List<FlSpot> dataset;
  final double minX, maxX, minY, maxY;
  const _ChartData(
      {required this.dataset,
      required this.minX,
      required this.maxX,
      required this.minY,
      required this.maxY});
}

class _HistoryChartState extends State<HistoryChart> {
  ///
  FitRecord? _record;

  @override
  void initState() {
    super.initState();
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );

    print(value.toInt());

    Widget text;
    if (value.toInt() == widget.series.maxX)
      text = Text(Localizer.translate(context, 'lblToday'),
          style: style, textAlign: TextAlign.left);
    else
      text = const Text('', style: style);

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
      fitInside: const SideTitleFitInsideData(
        enabled: true,
        distanceFromEdge: 0.0,
        parentAxisSize: 0,
        axisPosition: 0,
      ),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );

    int mod = 50;
    if (widget.series.maxY < 100) mod = 25;

    String text;
    if (value.toInt() % mod == 0)
      text = '${value.toInt()}';
    else
      return Container();

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final LineChartData chartData = LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: const Color(0xffcccccc),
            strokeWidth: 0,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: const Color(0xffcccccc),
            strokeWidth: 0,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 30,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
            left: BorderSide(color: const Color(0xffcccccc)),
            bottom: BorderSide(color: const Color(0xffcccccc)),
            right: BorderSide.none,
            top: BorderSide.none),
      ),
      minX: widget.series.minX,
      maxX: widget.series.maxX,
      minY: widget.series.minY,
      maxY: widget.series.maxY,
      lineBarsData: [
        LineChartBarData(
          spots: widget.series.dataset,
          isCurved: true,
          gradient: LinearGradient(
            colors: <Color>[
              widget.theme.colorScheme.secondary.withAlpha(32),
              widget.theme.colorScheme.secondary.withAlpha(192),
            ],
          ),
          barWidth: 2.0,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: <Color>[
                widget.theme.colorScheme.primary.withAlpha(16),
                widget.theme.colorScheme.primary.withAlpha(96),
              ],
            ),
          ),
        ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            Localizer.translate(
              context,
              widget.unitKilometersEnabled
                  ? 'lblUnitKilometer'
                  : 'lblUnitPoints',
            ),
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(height: width * 0.33, child: LineChart(chartData)),
      ],
    );
  }
}

/*
 charts.TimeSeriesChart(
            widget.series,
            selectionModels: [
              charts.SelectionModelConfig(
                changedListener: _infoSelectionModelUpdated,
              ),
            ],
            animate: widget.animate,
            behaviors: [
              charts.RangeAnnotation([
                charts.LineAnnotationSegment(
                  widget.unitKilometersEnabled
                      ? widget.target / 12.0
                      : widget.target,
                  charts.RangeAnnotationAxisType.measure,
                  dashPattern: [4, 4],
                  strokeWidthPx: 1,
                  axisId: 'points',
                  color: primaryColor,
                  endLabel:
                      Localizer.translate(context, 'lblSettingsGoalDailyTitle'),
                  labelStyleSpec: charts.TextStyleSpec(
                    fontSize: 12,
                    color: primaryColor,
                  ),
                ),
              ]),
              charts.LinePointHighlighter(
                showHorizontalFollowLine:
                    charts.LinePointHighlighterFollowLineType.none,
                showVerticalFollowLine:
                    charts.LinePointHighlighterFollowLineType.nearest,
                symbolRenderer: TooltipRenderer(
                  delegate: this,
                  dotColor: HistoryChart.colorFrom(
                    widget.theme.colorScheme.primary,
                  ),
                  backgroundColor: tooltipBackgoundColor,
                  textColor: tooltipTextColor,
                  chartWidth: width,
                ),
              ),
              charts.SelectNearest(
                eventTrigger: charts.SelectionTrigger.tapAndDrag,
              )
            ],
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
 */