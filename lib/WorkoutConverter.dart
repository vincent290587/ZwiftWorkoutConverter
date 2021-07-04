import 'dart:convert';

class WorkoutConverter {
  WorkoutConverter();

  String convertWorkout(String input) {
    String res = '';
    LineSplitter ls = new LineSplitter();
    List<String> lines = ls.convert(input);
    List<String> output = [];

    int parsed = 0;
    do {
      List<String> line_pair = lines.sublist(0, 1);
      parsed = parseLinesPair(line_pair, output);
      lines.removeAt(0);
      if (parsed == 2) {
        lines.removeAt(0);
      }
    } while (parsed > 0);

    return res;
  }

  int parseLinesPair(List<String> line_pair, List<String> output) {
    if (line_pair.isEmpty) {
      return 0;
    }

    if (line_pair.first.contains('x')) {
      // intervals
      String res = addRepetition(line_pair.first);
      output.add(res);

      return 2;
    } else {
      // single block
      String res = addSingleBlock(line_pair.first);
      output.add(res);

      return 1;
    }
  }

  String addRamp(String input) {
    String res = '';
    return res;
  }

  String addSingleBlock(String input) {
    String res = '';
    int lapse = extractTime(input);

    if (input.contains('from')) {

      var ramp = addRamp(input);

    } else {

    }

    return res;
  }

  String addRepetition(String input) {
    String res = '';
    return res;
  }

  int extractTime(String input_) {

    String input = input_;
    if (input.contains('x')) {
      input = input_.substring(input.indexOf('x')+2);
    }

    if (input.contains('min')) {
      final regex = RegExp(r'^([0-9]+)min .*$');
      final match = regex.firstMatch(input);

      final minutes = match!.group(1);
      return (60 * int.parse(minutes!));
    } else if (input.contains('sec')) {
      final regex = RegExp(r'^([0-9]+)sec .*$');
      final match = regex.firstMatch(input);

      final seconds = match!.group(1);
      return (1 * int.parse(seconds!));
    }

    return 0;
  }

  int extractReps(String input) {
    if (input.contains('x')) {
      final regex = RegExp(r'^([0-9]+)x (.*)$');
      final match = regex.firstMatch(input);

      final reps = match!.group(1);
      return int.parse(reps!);
    }

    return 0;
  }

  int extractCadence(String input) {
    if (input.contains('x')) {
      final regex = RegExp(r'^(.*) @\s([0-9]+)rpm, (.*)$');
      final RegExpMatch? match = regex.firstMatch(input);

      if (match == null || match.groupCount < 2) {
        return 0;
      }

      final reps = match.group(2);
      return int.parse(reps!);
    }

    return 0;
  }

  List<int> parseRamp(String input) {

    List<int> res = [];

    final regex = RegExp(r'^.* from\s([0-9]+) to\s([0-9]+)% FTP$');
    final RegExpMatch? match = regex.firstMatch(input);

    if (match == null || match.groupCount < 2) {
      return res;
    }

    var reps = match.group(1);
    res.add(int.parse(reps!));

    reps = match.group(2);
    res.add(int.parse(reps!));

    return res;
  }
}

// class Ramp {
//
//   int duration;
//   int start_power;
//   int stop_power;
//   int cadence;
//
// }
