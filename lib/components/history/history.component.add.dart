import 'package:flutter/material.dart';
import 'package:steps/components/shared/localizer.dart';
import 'package:steps/components/shared/page.default.dart';
import 'package:steps/model/repositories/fitness.repository.dart';

class HistoryAdd extends StatefulWidget {
  ///
  HistoryAdd({Key key}) : super(key: key);

  @override
  _HistoryAddState createState() => _HistoryAddState();
}

class _HistoryAddState extends State<HistoryAdd> {
  ///
  final FitnessRepository _repository = FitnessRepository();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultPage(
      child: Container(),
      title: Localizer.translate(context, 'lblHistoryAdd'),
    );
  }
}
