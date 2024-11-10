import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

class Session extends StatefulWidget {
  final String name;
  const Session({super.key, required this.name});

  @override
  SessionState createState() => SessionState();
}

class SessionState extends State<Session> {
  double _scaleFactor = 0.5;
  bool useMicInput = true;
  final myRecording = AudioRecorder();
  double volume = 0.0;
  double minVolume = -45.0;
  Timer? timer;
  var logger = Logger();

  @override
  void initState() {
    super.initState();
    requestPermissionAndStartRecording();
  }

  Future<String> getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/myFile.m4a';
  }

  Future<void> requestPermissionAndStartRecording() async {
    if (await myRecording.hasPermission()) {
      startRecording();
    } else {
      logger.e("Microphone Access is denied");
    }
  }

  Future<bool> startRecording() async {
    final path = await getFilePath();
    if (await myRecording.hasPermission()) {
      if (!await myRecording.isRecording()) {
        await myRecording.start(const RecordConfig(), path: path);
      }
      startTimer();
      return true;
    } else {
      return false;
    }
  }

  startTimer() async {
    timer ??= Timer.periodic(
      const Duration(milliseconds: 50), (timer) => updateVolume());
  }

  updateVolume() async {
    Amplitude ampl = await myRecording.getAmplitude();
    if (ampl.current > minVolume) {
      setState(() {
        volume = (ampl.current - minVolume) / minVolume;
        _scaleFactor = 0.5 - (volume * 1.25);
      });
    }
  }

  int volume0to(int maxVolumeToDisplay) {
    return (volume * maxVolumeToDisplay).round().abs();
  }

  @override
  void dispose() {
    timer?.cancel();
    myRecording.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Session'),
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.scale(
                scale: _scaleFactor,
                child: const SizedBox(
                  width: 300,
                  height: 300,
                  child: RiveAnimation.asset('images/pablo.riv'),
                ),
              ),
              Text(
                'Ye Sab Kuch Nai Hota h ${widget.name}!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                'Padhle Chutiye! 😒',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                "VOLUME\n${volume0to(100)}",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
