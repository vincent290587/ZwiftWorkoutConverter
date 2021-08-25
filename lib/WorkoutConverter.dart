import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WorkoutConverter {

  bool upgrade_ramps = false;
  List<Interval> intervals = [];

  WorkoutConverter();

  void parseWorkout(bool up_ramps, String input) {

    upgrade_ramps = up_ramps;

    if (input.isEmpty) {
      return;
    }

    LineSplitter ls = new LineSplitter();
    List<String> lines = ls.convert(input);

    intervals.clear();

    try {
      int parsed = 0;
      do {
        List<String> linePair = [lines.first];
        if (lines.length > 1) {
          linePair = lines.sublist(0, 2);
        }
        parsed = parseLinesPair(linePair);
        lines.removeAt(0);
        if (parsed == 2) {
          lines.removeAt(0);
        }
      } while (parsed > 0 && lines.isNotEmpty);
    } catch(e, s) {
      print(e.toString());
      //print(s.toString());
    }

    return;
  }

  String convertToICU() {
    String start = '';

    for (var interval in intervals) {
      start += interval.toIcuString();
    }

    return start;
  }

  String convertToZwift() {
    String start = '';

    start = "<workout_file>\n";
    start += "    <author>Vincent Golle</author>\n";
    start += "    <name>";
    start += "name_placeholder";
    start += "</name>\n";
    start += "    <description></description>\n";
    start += "    <sportType>bike</sportType>\n";
    start += "    <tags>\n";
    start += "    </tags>\n";
    start += "    <workout>\n";

    for (var interval in intervals) {
      start += interval.toZwiftString();
    }

    start += "    </workout>\n";
    start += "</workout_file>\n";

    return start;
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
    int lapse = extractTime(input);
    int cad = extractCadence(input);

    if (input.contains('from')) {

      var power = this.parseRamp(input);

      if (upgrade_ramps && lapse >= 10 && lapse <= 45) {

        int cpower = power.first;
        int nb_intervals = (lapse/10).floor();
        int d_time = (lapse/nb_intervals).ceil();
        int d_power = ((power.last - power.first)/(nb_intervals-1)).ceil();
        int cur_lapse = 0;
        do {
          intervals.add(SteadyState(d_time, cpower, cad));
          cpower += d_power;
          cur_lapse += d_time;
        } while(cur_lapse < lapse);
      } else {
        intervals.add(Ramp(lapse, power, cad));
      }

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
      final regex = RegExp(r'^.*\s([0-9]+)%\sFTP.*$');
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

  String toIcuString();
}

class SteadyState implements Interval {

  int duration;
  int start_power;
  int cadence;

  SteadyState(this.duration, this.start_power, this.cadence);

  @override
  String toZwiftString() {
    String res = '';
    String power_on = percentToString(start_power).toStringAsFixed(2);
    if (start_power==0) {
      // free ride
      res = "        <FreeRide Duration=\"$duration\" FlatRoad=\"1\"/>\n";
    } else if(cadence == 0) {
      res = "        <SteadyState Duration=\"$duration\" Power=\"$power_on\"/>\n";
    } else {
      res = "        <SteadyState Duration=\"$duration\" Power=\"$power_on\" Cadence=\"$cadence\"/>\n";
    }
    return res;
  }

  @override
  String toIcuString() {
    String res = '\n';
    if (start_power==0) {
      // free ride
      res += "- ${duration}s ${start_power}%\n";
    } else if(cadence == 0) {
      res += "- ${duration}s ${start_power}%\n";
    } else {
      res += "- ${duration}s ${start_power}% cadence ${cadence}rpm\n";
    }
    return res;
  }
}

class Repetition implements Interval {

  int reps;
  List<SteadyState> intervals;

  Repetition(this.reps, this.intervals);

  @override
  String toZwiftString() {
    String res = '';
    int on = intervals.first.duration;
    int off = intervals.last.duration;
    String power_on = percentToString(intervals.first.start_power).toStringAsFixed(2);
    String power_off = percentToString(intervals.last.start_power).toStringAsFixed(2);
    int cad_on = intervals.first.cadence;
    int cad_off = intervals.last.cadence;
    res = "        <IntervalsT Repeat=\"$reps\" OnDuration=\"$on\" OffDuration=\"$off\" OnPower=\"$power_on\" OffPower=\"$power_off\"";
    if(cad_on > 0) {
      res += " Cadence=\"$cad_on\"";
    }
    if (cad_off > 0) {
      res += " CadenceResting=\"$cad_off\"";
    }
    res += "/>\n";
    return res;
  }

  @override
  String toIcuString() {
    String res = '\n';
    int on = intervals.first.duration;
    int off = intervals.last.duration;
    int cad_on = intervals.first.cadence;
    int cad_off = intervals.last.cadence;
    res += "${reps}x\n";

    res += "- ${on}s ${intervals.first.start_power}%";
    if(cad_on > 0) {
      res += " cadence ${cad_on}rpm";
    }
    res += "\n";

    res += "- ${off}s ${intervals.last.start_power}%";
    if (cad_off > 0) {
      res += " cadence ${cad_off}rpm";
    }
    res += "\n";
    res += "\n";

    return res;
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
    String res = '';
    String power0 = percentToString(start_power).toStringAsFixed(2);
    String power1 = percentToString(stop_power).toStringAsFixed(2);
    if(cadence == 0) {
      res = "        <Ramp Duration=\"$duration\" PowerLow=\"$power0\" PowerHigh=\"$power1\"/>\n";
    } else {
      res = "        <Ramp Duration=\"$duration\" PowerLow=\"$power0\" PowerHigh=\"$power1\" Cadence=\"$cadence\"/>\n";
    }
    return res;
  }

  @override
  String toIcuString() {
    String res = '\n';
    if(cadence == 0) {
      res += "- ${duration}s ramp ${start_power}-${stop_power}%\n";
    } else {
      res += "- ${duration}s ramp ${start_power}-${stop_power}% cadence ${cadence}rpm\n";
    }
    return res;
  }
}

double percentToString(int input) {
  return input / 100.0;
}
