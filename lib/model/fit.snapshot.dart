import 'package:fit_kit/fit_kit.dart';

class FitSnapshot {
  Map<String, num> value;

  FitSnapshot({final DataType type, List<FitData> data}) {
    this.value = Map();

    String key;
    num sum = 0;
    data.forEach((element) {
      key =
          '${element.dateFrom.year}-${element.dateFrom.month.toString().padLeft(2, '0')}-${element.dateFrom.day.toString().padLeft(2, '0')}';
      if (this.value.containsKey(key)) {
        this.value.update(key, (value) => value + element.value);
      } else {
        this.value.putIfAbsent(key, () => element.value);
      }
      sum += element.value;
    });
    this.value['sum'] = sum;
  }

  num valueOfDate(DateTime date) {
    final String key =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    if (this.value != null && this.value.containsKey(key)) {
      return this.value[key];
    }
    return 0;
  }
}
