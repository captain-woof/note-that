import 'dart:async';
import 'package:flutter/foundation.dart';

class TimeCounter with ChangeNotifier {
  int _timeInMillis = 0;
  Duration updateInterval;
  late Timer _timer;

  TimeCounter({this.updateInterval = const Duration(milliseconds: 1)});

  // Starts counter
  void start() {
    _timeInMillis = 0;
    notifyListeners();
    _timer = Timer.periodic(updateInterval, (_) {
      _timeInMillis += updateInterval.inMilliseconds;
      notifyListeners();
    });
  }

  // Pauses counter
  void pause() {
    _timer.cancel();
    notifyListeners();
  }

  // Resumes counter
  void resume() {
    _timer = Timer.periodic(updateInterval, (_) {
      _timeInMillis += updateInterval.inMilliseconds;
      notifyListeners();
    });
  }

  // Stops counter
  void stop() {
    _timer.cancel();
    _timeInMillis = 0;
    notifyListeners();
  }

  int get timeInMillis => _timeInMillis;

  String get formattedTime => formatTime(_timeInMillis);

  static String formatTime(int timeInMillis) {
    Duration duration = Duration(milliseconds: timeInMillis);

    int hours = duration.inHours;
    int mins = duration.inMinutes.remainder(60);
    int secs = duration.inSeconds.remainder(60);

    String formatNumberForDisplay(int num) => num < 10 ? "0$num" : "$num";

    String formattedTime =
        "${hours != 0 ? "${formatNumberForDisplay(hours)}:" : ""}${formatNumberForDisplay(mins)}:${formatNumberForDisplay(secs)}";

    return formattedTime;
  }
}
