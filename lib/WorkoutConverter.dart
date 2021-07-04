import 'dart:convert';

class WorkoutConverter {

  List<Interval> intervals = [];

  WorkoutConverter();

  String convertWorkout(String input) {
    String res = '';
    LineSplitter ls = new LineSplitter();
    List<String> lines = ls.convert(input);

    intervals.clear();

    int parsed = 0;
    do {
      List<String> line_pair = lines.sublist(0, 1);
      parsed = parseLinesPair(line_pair);
      lines.removeAt(0);
      if (parsed == 2) {
        lines.removeAt(0);
      }
    } while (parsed > 0);

    return res;
  }

  int parseLinesPair(List<String> line_pair) {
    if (line_pair.isEmpty) {
      return 0;
    }

    if (line_pair.first.contains('x')) {
      // intervals
      addRepetition(line_pair);

      return 2;
    } else {
      // single block
      addSingleBlock(line_pair.first);

      return 1;
    }
  }

  void addRepetition(List<String> line_pair) {

    String input = line_pair.first;

    int reps = extractReps(input);
    int lapse1 = extractTime(input);
    int cad1 = extractCadence(input);
    int power1 = this.extractPower(input);

    input = line_pair.last;

    int lapse2 = extractTime(input);
    int cad2 = extractCadence(input);
    int power2 = this.extractPower(input);

    intervals.add(Repetition(reps, [SteadyState(lapse1, power1, cad1), SteadyState(lapse2, power2, cad2)]));

    return;
  }

  void addSingleBlock(String input) {
    String res = '';
    int lapse = extractTime(input);
    int cad = extractCadence(input);

    if (input.contains('from')) {

      var power = this.parseRamp(input);
      intervals.add(Ramp(lapse,power,cad));

      return;
    }

    int power = this.extractPower(input);
    intervals.add(SteadyState(lapse,power,cad));

    return;
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

  int extractPower(String input) {
    if (input.contains('FTP')) {
      final regex = RegExp(r'^.*,\s([0-9]+)%\sFTP.*$');
      final match = regex.firstMatch(input);

      final reps = match!.group(1);
      return int.parse(reps!);
    }

    return 0;
  }

  int extractCadence(String input) {
    if (input.contains('@')) {
      final regex = RegExp(r'^(.*) @\s([0-9]+)rpm, .*$');
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

abstract class Interval {

  String toZwiftString();
}

class SteadyState implements Interval {

  int duration;
  int start_power;
  int cadence;

  SteadyState(this.duration, this.start_power, this.cadence);

  @override
  String toZwiftString() {
    // TODO: implement toZwiftString
    throw UnimplementedError();
  }
}

class Repetition implements Interval {

  List<SteadyState> intervals;

  Repetition(int reps, this.intervals);

  @override
  String toZwiftString() {
    // TODO: implement toZwiftString
    throw UnimplementedError();
  }
}

class Ramp implements Interval {

  int duration;
  late int start_power;
  late int stop_power;
  int cadence;

  Ramp(this.duration, List<int> lpower, this.cadence){
    this.start_power = lpower.elementAt(0);
    this.stop_power = lpower.elementAt(1);
  }

  @override
  String toZwiftString() {
    // TODO: implement toZwiftString
    throw UnimplementedError();
  }
}
