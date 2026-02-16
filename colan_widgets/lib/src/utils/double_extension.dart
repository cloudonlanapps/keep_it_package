extension UtilExtensionOnDouble on double {
  double nearest(double value) {
    if (value == 0.0) {
      // Avoid division by zero
      return value;
    }
    return (this / value).floor() * value;
  }
}
