// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.


import 'package:flutter_test/flutter_test.dart';
import 'package:zwift_converter/WorkoutConverter.dart';

void main() {
  group('Getting time', ()
  {
    test('Seconds', () {
      WorkoutConverter converter = WorkoutConverter();
      expect(converter.extractTime('30sec @ 85rpm, 50% FTP'), equals(30));
    });
    test('Minutes', () {
      WorkoutConverter converter = WorkoutConverter();
      expect(converter.extractTime('10min from 25 to 75% FTP'), equals(600));
    });
    test('Seconds_rep', () {
      WorkoutConverter converter = WorkoutConverter();
      expect(converter.extractTime('1x 30sec @ 95rpm, 95% FTP,'), equals(30));
    });
    test('Minutes_rep', () {
      WorkoutConverter converter = WorkoutConverter();
      expect(converter.extractTime('1x 5min @ 95rpm, 95% FTP,'), equals(300));
    });
  });

  test('Get', () {
    WorkoutConverter converter = WorkoutConverter();
    expect(converter.extractReps('5x 1min @ 100rpm, 65% FTP,'), equals(5));
    expect(converter.extractReps('18x 1min, 65% FTP,'), equals(18));
  });

  test('Cadence', () {
    WorkoutConverter converter = WorkoutConverter();
    expect(converter.extractCadence('5x 1min @ 100rpm, 65% FTP,'), equals(100));
    expect(converter.extractCadence('18x 1min, 65% FTP,'), equals(0));
    expect(converter.extractCadence('3min @ 90rpm, 65% FTP'), equals(90));
  });

  group('Power', () {
    test('Power_single', () {
      WorkoutConverter converter = WorkoutConverter();
      expect(converter.extractPower('3min @ 90rpm, 65% FTP'), equals(65));
    });
    test('Power_rep', () {
      WorkoutConverter converter = WorkoutConverter();
      expect(converter.extractPower('5x 1min @ 100rpm, 65% FTP,'), equals(65));
    });
  });

  test('Ramp', () {
    WorkoutConverter converter = WorkoutConverter();
    expect(converter.parseRamp('10min from 25 to 75% FTP'), equals({25, 75}));
  });
}
