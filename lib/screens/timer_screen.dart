import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:studysphere/services/notification_service.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  // 🎯 TEST SETTINGS (Shortened for testing)
  static const int studyTime = 10; // Changed from 25 * 60 to 10 seconds
  static const int breakTime = 5;  // Changed from 5 * 60 to 5 seconds

  int seconds = studyTime;
  bool isRunning = false;
  bool isStudyMode = true;

  Timer? timer;

  // 🔊 AUDIO PLAYER
  final AudioPlayer _audioPlayer = AudioPlayer();

  // ▶ START / PAUSE
  void toggleTimer() {
    if (isRunning) {
      timer?.cancel();
      setState(() => isRunning = false);
    } else {
      startTimer();
    }
  }

  // ▶ START TIMER
  void startTimer() {
    setState(() => isRunning = true);

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds > 0) {
        setState(() => seconds--);
      } else {
        t.cancel();
        onTimerFinished();
      }
    });
  }

  // ⏰ TIMER FINISHED HANDLER
  Future<void> onTimerFinished() async {
    setState(() => isRunning = false);

    // 🔔 Notification (Triggered when timer hits 0)
    NotificationService.showNotification(
      title: "⏰ Time's Up!",
      body: isStudyMode
          ? "Great job! Take a short break ☕"
          : "Break is over! Time to focus 📚",
    );

    // 🔊 STOP ANY PREVIOUS SOUND FIRST
    await _audioPlayer.stop();

    // 🔊 PLAY ALARM (Make sure alarm.mp3 is in assets/sounds/)
    try {
      await _audioPlayer.play(
        AssetSource('sounds/alarm.mp3'),
      );
    } catch (e) {
      print("Error playing sound: $e");
    }

    // 🔄 Switch mode
    switchMode();
  }

  // 🔄 SWITCH MODE
  void switchMode() {
    setState(() {
      isStudyMode = !isStudyMode;
      seconds = isStudyMode ? studyTime : breakTime;
      isRunning = false;
    });
  }

  // 🔁 RESET
  void resetTimer() {
    timer?.cancel();
    _audioPlayer.stop();

    setState(() {
      isRunning = false;
      isStudyMode = true;
      seconds = studyTime;
    });
  }

  // ⏱ FORMAT TIME
  String formatTime(int s) {
    int m = s ~/ 60;
    int sec = s % 60;
    return "$m:${sec.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The background color switches between Teal (Study) and Orange (Break)
      backgroundColor: isStudyMode ? Colors.teal : Colors.orangeAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isStudyMode ? "📚 Study Time" : "☕ Break Time",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              formatTime(seconds),
              style: const TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: toggleTimer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
              ),
              child: Text(isRunning ? "Pause" : "Start"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: resetTimer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text("Reset"),
            ),
          ],
        ),
      ),
    );
  }
}