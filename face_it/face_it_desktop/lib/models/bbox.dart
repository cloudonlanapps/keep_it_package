class BBox {
  factory BBox(double xmin, double ymin, double xmax, double ymax) {
    return BBox._([xmin, ymin, xmax, ymax]);
  }

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
}
