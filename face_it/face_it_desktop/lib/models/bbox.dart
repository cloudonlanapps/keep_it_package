import 'dart:convert';

class BBox {
  factory BBox(double xmin, double ymin, double xmax, double ymax) {
    return BBox._([xmin, ymin, xmax, ymax]);
  }

  factory BBox.fromMap(Map<String, dynamic> map) {
    final list = map['data'];
    if (list case [
      final double xmin,
      final double ymin,
      final double xmax,
      final double ymax,
    ]) {
      return BBox(xmin, ymin, xmax, ymax);
    }
    throw ArgumentError('BBox must have exactly 4 entries.');
  }

  factory BBox.fromJson(String source) =>
      BBox.fromMap(json.decode(source) as Map<String, dynamic>);

  BBox._(this._data) {
    if (_data.length != 4) {
      throw ArgumentError('BBox must have exactly 4 entries.');
    }
  }
  final List<double> _data;

  double get xmin => _data[0];
  double get ymin => _data[1];
  double get xmax => _data[2];
  double get ymax => _data[3];

  double get width => xmax - xmin;
  double get height => ymax - ymin;

  List<double> get data => List.unmodifiable(_data);

  @override
  String toString() {
    return 'BBox(xmin: $xmin, ymin: $ymin, xmax: $xmax, ymax: $ymax)';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'_data': _data};
  }

  String toJson() => json.encode(toMap());
}
