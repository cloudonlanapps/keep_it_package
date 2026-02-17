//https://stackoverflow.com/a/76902150

extension UtilExtensionOnNum on num {
  String toHumanReadableFileSize({int round = 2, bool useBase1024 = true}) {
    const affixes = <String>['B', 'KB', 'MB', 'GB', 'TB', 'PB'];

    final num divider = useBase1024 ? 1024 : 1000;

    final size = this;
    var runningDivider = divider;
    num runningPreviousDivider = 0;
    var affix = 0;

    while (size >= runningDivider && affix < affixes.length - 1) {
      runningPreviousDivider = runningDivider;
      runningDivider *= divider;
      affix++;
    }

    var result =
        (runningPreviousDivider == 0 ? size : size / runningPreviousDivider)
            .toStringAsFixed(round);

    if (result.endsWith('0' * round)) {
      result = result.substring(0, result.length - round - 1);
    }

    return '$result ${affixes[affix]}';
  }
}
