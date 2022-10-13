import 'package:flutter/material.dart';
import 'package:wandr/components/shared/localizer.dart';
import 'package:wandr/components/shared/page.default.dart';
import 'package:wandr/components/shared/segmented.control.dart';
import 'package:wandr/model/fit.record.dart';
import 'package:wandr/model/repositories/fitness.repository.dart';
import 'package:intl/intl.dart';

class HistoryAdd extends StatefulWidget {
  ///
  final FitRecord oldRecord;

  ///
  HistoryAdd({Key key, this.oldRecord}) : super(key: key);

  @override
  _HistoryAddState createState() => _HistoryAddState();
}

class _HistoryAddState extends State<HistoryAdd> {
  ///
  final FitnessRepository _repository = FitnessRepository();

  ///
  TextEditingController _valueInputController;

  ///
  FocusNode _valueFocusNode;

  ///
  TextEditingController _nameInputController;

  ///
  FocusNode _nameFocusNode;

  ///
  TextEditingController _dateInputController;

  ///
  FocusNode _dateFocusNode;

  ///
  int _selectedModeIndex;

  ///
  DateTime _selectedDate;

  @override
  void initState() {
    super.initState();

    _valueInputController = TextEditingController();
    _valueFocusNode = FocusNode();
    _nameInputController = TextEditingController();
    _nameFocusNode = FocusNode();
    _dateInputController = TextEditingController();
    _dateFocusNode = FocusNode();

    if (widget.oldRecord != null) {
      _selectedModeIndex =
          widget.oldRecord.type == FitRecord.TYPE_ACTIVE_MINUTES ? 0 : 1;
      _selectedDate = widget.oldRecord.dateTime;
      _nameInputController.text = widget.oldRecord.name;
      _valueInputController.text = widget.oldRecord.value.toString();
      _dateInputController.text =
          DateFormat('dd.MM.yyyy').format(_selectedDate);
    } else {
      _selectedModeIndex = 0;
      _selectedDate = DateTime.now();
      _dateInputController.text =
          DateFormat('dd.MM.yyyy').format(_selectedDate);
    }
  }

  bool _validate(String value) {
    final int numericValue = int.tryParse(value) ?? 0;
    return true;
  }

  void _save() {
    final int value = int.tryParse(_valueInputController.text) ?? 0;
    final String name = _nameInputController.text;
    final DateTime date = _selectedDate;
    print('$value with name=$name and date $date');
    if (value <= 0) return;

    final FitRecord record = FitRecord(dateTime: date);
    record.fill(
      source: FitRecord.SOURCE_MANUAL,
      value: value,
      type: _selectedModeIndex == 0
          ? FitRecord.TYPE_ACTIVE_MINUTES
          : FitRecord.TYPE_STEPS,
      name: name.isEmpty ? null : name,
    );

    _repository.addRecord(record, oldRecord: widget.oldRecord).then((_) {
      if (!mounted) return;
      Navigator.of(context).pop();
    });
  }

  void _delete() {
    if (widget.oldRecord == null) return;

    _repository.deleteRecord(widget.oldRecord).then((_) {
      if (!mounted) return;
      Navigator.of(context).pop();
    });
  }

  void _pickDate(BuildContext context) {
    final DateTime date = _selectedDate;
    showDatePicker(
            context: context,
            initialDate: date,
            firstDate: FitnessRepository.firstPossibleDate(),
            lastDate: DateTime.now())
        .then((value) {
      if (value != null) {
        _selectedDate = value;
        _dateInputController.text =
            DateFormat('dd.MM.yyyy').format(_selectedDate);
      }
      _dateFocusNode.unfocus();
      _valueFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _valueFocusNode.dispose();
    _valueInputController.dispose();
    _nameFocusNode.dispose();
    _nameInputController.dispose();
    _dateFocusNode.dispose();
    _dateInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultPage(
      child: SingleChildScrollView(
        child: Container(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              children: [
                SegmentedControl(
                  onChange: (model) {
                    setState(() {
                      _selectedModeIndex = model.index;
                    });
                  },
                  options: [
                    OptionModel(
                      index: 0,
                      isSelected: _selectedModeIndex == 0,
                      title:
                          Localizer.translate(context, 'lblUnitActiveMinutes'),
                    ),
                    OptionModel(
                      index: 1,
                      isSelected: _selectedModeIndex == 1,
                      title: Localizer.translate(context, 'lblUnitSteps'),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 8.0),
                  child: TextField(
                    keyboardType: TextInputType.text,
                    controller: _nameInputController,
                    focusNode: _nameFocusNode,
                    textInputAction: TextInputAction.next,
                    obscureText: false,
                    onSubmitted: (value) {
                      _nameFocusNode.unfocus();
                      _dateFocusNode.requestFocus();
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: Localizer.translate(context, 'lblHistoryName'),
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 16.0,
                        ),
                        child: TextField(
                          controller: _dateInputController,
                          focusNode: _dateFocusNode,
                          readOnly: true,
                          onTap: () {
                            _pickDate(context);
                          },
                          obscureText: false,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText:
                                Localizer.translate(context, 'lblHistoryDate'),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 16.0,
                        ),
                        child: TextField(
                          keyboardType: TextInputType.numberWithOptions(),
                          controller: _valueInputController,
                          focusNode: _valueFocusNode,
                          textInputAction: TextInputAction.done,
                          onChanged: (value) {
                            _validate(value);
                          },
                          onSubmitted: (value) {
                            if (_validate(value)) {
                              _save();
                            }
                          },
                          obscureText: false,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: _selectedModeIndex == 0
                                ? Localizer.translate(
                                    context, 'lblUnitActiveMinutes')
                                : Localizer.translate(context, 'lblUnitSteps'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      widget.oldRecord == null
                          ? Container()
                          : TextButton(
                              child: Text(
                                Localizer.translate(context, 'lblActionDelete'),
                                style: TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                              onPressed: () {
                                _delete();
                              },
                            ),
                      TextButton(
                        child: Text(
                          Localizer.translate(context, 'lblActionDone'),
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          _save();
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      title: widget.oldRecord == null
          ? Localizer.translate(context, 'lblHistoryAdd')
          : Localizer.translate(context, 'lblHistoryEdit'),
    );
  }
}
