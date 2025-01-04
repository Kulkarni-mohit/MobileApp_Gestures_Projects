import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:torch_light/torch_light.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ShakeAndTorchApp(),
    );
  }
}

class ShakeAndTorchApp extends StatefulWidget {
  @override
  _ShakeAndTorchAppState createState() => _ShakeAndTorchAppState();
}

class _ShakeAndTorchAppState extends State<ShakeAndTorchApp> {
  static const double shakeThreshold = 15.0; // Customize as needed
  static const int requiredShakeCount = 4; // Number of shakes to toggle the torch
  bool isTorchOn = false;
  int shakeCount = 0;
  Timer? resetTimer;

  @override
  void initState() {
    super.initState();
    _startListeningToAccelerometer();
  }

  void _startListeningToAccelerometer() {
    accelerometerEvents.listen((event) {
      final double acceleration = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      if (acceleration > shakeThreshold) {
        _onShakeDetected();
      }
    });
  }

  void _onShakeDetected() {
    setState(() {
      shakeCount++;
    });

    // Reset shake count after 1 second of no additional shakes
    resetTimer?.cancel(); // Cancel any existing timer
    resetTimer = Timer(Duration(seconds: 1), () {
      setState(() {
        shakeCount = 0;
      });
    });

    if (shakeCount >= requiredShakeCount) {
      _toggleTorch();
      shakeCount = 0; // Reset immediately after toggling
      resetTimer?.cancel(); // Stop the timer as we reset manually
    }

    print('Shake detected! Count: $shakeCount');
  }

  Future<void> _toggleTorch() async {
    try {
      if (isTorchOn) {
        await TorchLight.disableTorch();
      } else {
        await TorchLight.enableTorch();
      }
      setState(() {
        isTorchOn = !isTorchOn;
      });
    } catch (e) {
      print('Error toggling torch: $e');
      _showErrorDialog();
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('Failed to access the flashlight.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Shake to Toggle Torch')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Shake count: $shakeCount',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              isTorchOn ? 'Torch is ON' : 'Torch is OFF',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    resetTimer?.cancel(); // Clean up the timer
    super.dispose();
  }
}
