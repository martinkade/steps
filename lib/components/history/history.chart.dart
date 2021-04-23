import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:wandr/components/shared/localizer.dart';
import 'package:wandr/model/calendar.dart';
import 'package:wandr/model/fit.record.dart';

import 'dart:math' show Rectangle, max;
import 'package:charts_flutter/src/text_element.dart' as chartsTextElement;
import 'package:charts_flutter/src/text_style.dart' as chartsTextStyle;

class HistoryChart extends StatefulWidget {
  ///
  final List<charts.Series> series;

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
    Key key,
    @required this.series,
    @required this.target,
    @required this.unitKilometersEnabled,
    @required this.theme,
    this.animate,
  }) : super(key: key);

  @override
  _HistoryChartState createState() => _HistoryChartState();

  ///
  factory HistoryChart.withData(List<FitRecord> data,
      {int target = 0,
      @required bool unitKilometersEnabled,
      Color color,
      @required ThemeData theme,
      bool animate}) {
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
  static charts.Color colorFrom(Color color) {
    return charts.Color(
      r: color.red,
      g: color.green,
      b: color.blue,
      a: color.alpha,
    );
  }

  ///
  static List<charts.Series<FitRecord, DateTime>> _createData(
      List<FitRecord> data,
      {ThemeData theme,
      bool unitKilometersEnabled}) {
    final charts.Color seriesColor = colorFrom(theme.colorScheme.primary);
    return [
      charts.Series<FitRecord, DateTime>(
        id: 'points',
        colorFn: (FitRecord record, _) => seriesColor,
        domainFn: (FitRecord record, _) => record.dateTime,
        measureFn: (FitRecord record, _) =>
            unitKilometersEnabled ? record.value / 12.0 : record.value,
        data: data,
      ),
    ];
  }
}

class _HistoryChartState extends State<HistoryChart>
    implements TooltipRendererDelegate {
  ///
  FitRecord _record;

  @override
  void initState() {
    super.initState();
  }

  @override
  String tooltipGetValue() {
    return _record == null
        ? '-'
        : '${_record?.valueString(displayKilometers: widget.unitKilometersEnabled)} ${widget.unitKilometersEnabled ? Localizer.translate(context, 'lblUnitKilometer') : Localizer.translate(context, 'lblUnitPoints')}';
  }

  @override
  String tooltipGetDate() {
    return _record == null
        ? '-'
        : '${_record?.relativeDate(context, calendar: Calendar(), now: DateTime.now()) ?? '-'}';
  }

  ///
  void _infoSelectionModelUpdated(charts.SelectionModel<DateTime> model) {
    FitRecord record;
    if (model.selectedDatum.isNotEmpty) {
      record = model.selectedDatum.first.datum;
    }
    if (record != null && _record?.dateString != record.dateString) {
      _record = record;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final charts.Color primaryColor = HistoryChart.colorFrom(
      widget.theme.colorScheme.primary.withAlpha(128),
    );
    final charts.Color tooltipBackgoundColor = HistoryChart.colorFrom(
      widget.theme.scaffoldBackgroundColor.withAlpha(172),
    );
    final charts.Color tooltipTextColor = HistoryChart.colorFrom(
      widget.theme.textTheme.bodyText1.color,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Localizer.translate(context, 'lblHistoryChartTapInstruction'),
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          height: width * 0.33,
          child: charts.TimeSeriesChart(
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
        ),
      ],
    );
  }
}

abstract class TooltipRendererDelegate {
  String tooltipGetValue();
  String tooltipGetDate();
}

class TooltipRenderer extends charts.CircleSymbolRenderer {
  ///
  final TooltipRendererDelegate delegate;

  ///
  final charts.Color dotColor;

  ///
  final charts.Color backgroundColor;

  ///
  final charts.Color textColor;

  ///
  final num chartWidth;

  ///
  TooltipRenderer({
    @required this.delegate,
    this.chartWidth = 0,
    this.dotColor = charts.Color.black,
    this.backgroundColor = charts.Color.black,
    this.textColor = charts.Color.white,
  });

  @override
  void paint(charts.ChartCanvas canvas, Rectangle<num> bounds,
      {List<int> dashPattern,
      charts.Color fillColor,
      charts.FillPatternType fillPattern,
      charts.Color strokeColor,
      double strokeWidthPx}) {
    super.paint(canvas, bounds,
        dashPattern: dashPattern,
        fillColor: dotColor,
        strokeColor: dotColor,
        strokeWidthPx: 1);

    final textStyle = chartsTextStyle.TextStyle();
    textStyle.color = textColor;
    textStyle.fontSize = 12;

    final chartsTextElement.TextElement valueElement =
        chartsTextElement.TextElement(delegate.tooltipGetValue(),
            style: textStyle);

    final chartsTextElement.TextElement dateElement =
        chartsTextElement.TextElement(delegate.tooltipGetDate(),
            style: textStyle);

    final num bubblePadding = 8.0;
    final num bubbleElementSpacing = 4.0;
    final num bubbleHeight = 2.0 * bubblePadding +
        bubbleElementSpacing +
        valueElement.measurement.verticalSliceWidth +
        dateElement.measurement.verticalSliceWidth;
    final num bubbleWidth = max(valueElement.measurement.horizontalSliceWidth,
            dateElement.measurement.horizontalSliceWidth) +
        2.0 * bubblePadding;
    final num bubbleRadius = 8.0;
    final num bubbleBoundLeft = bounds.left + bubbleWidth > chartWidth - 44.0
        ? bounds.left - bubbleWidth
        : bounds.left;
    final num bubbleBoundTop = bounds.top - bubbleHeight - 4.0;

    canvas.drawRRect(
      Rectangle(bubbleBoundLeft, bubbleBoundTop, bubbleWidth, bubbleHeight),
      fill: backgroundColor,
      stroke: backgroundColor,
      radius: bubbleRadius,
      roundTopLeft: true,
      roundBottomLeft: true,
      roundBottomRight: true,
      roundTopRight: true,
    );

    final num valueElementBoundsLeft = bubbleBoundLeft + bubblePadding;
    final num valueElementBoundsTop = bubbleBoundTop + bubblePadding;
    canvas.drawText(valueElement, valueElementBoundsLeft.toInt(),
        valueElementBoundsTop.toInt());

    final num dateElementBoundsLeft = bubbleBoundLeft + bubblePadding;
    final num dateElementBoundsTop = bubbleBoundTop +
        bubblePadding +
        valueElement.measurement.verticalSliceWidth +
        bubbleElementSpacing;
    canvas.drawText(dateElement, dateElementBoundsLeft.toInt(),
        dateElementBoundsTop.toInt());
  }
}
