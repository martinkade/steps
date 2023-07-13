abstract class FitDao {
  String buildStatement(String placeholderStatement, List<dynamic>? values) {
    final List<String> components = placeholderStatement.split('?');
    if (components.length != (values?.length ?? 0) + 1) {
      final String error =
          'Expected ${components.length - 1} values but was: ${values?.length ?? 0}:\nstatement: $placeholderStatement\ncomponents: $components\nvalues: $values';
      print(error);
      throw FormatException(error);
    }

    if (values == null || values.isEmpty) return placeholderStatement;

    var value;
    String component;
    String statement = components[0];
    for (var i = 1; i < components.length; i++) {
      value = values[i - 1];
      component = components[i];
      if (value is String) {
        if (value == 'null')
          statement += 'NULL';
        else
          statement += '\'${value.replaceAll('\'', '\'\'')}\'';
      } else {
        statement += '$value';
      }

      statement += component;
    }

    // print(statement);
    return statement;
  }
}
