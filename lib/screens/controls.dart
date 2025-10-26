import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:line_icons/line_icons.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';

class Control extends StatefulWidget {
  const Control({super.key});
  @override
  State<Control> createState() => _ControlState();
}

class _ControlState extends State<Control> {
  // Firebase reference
  late DatabaseReference _databaseRef;
  bool firebaseConnected = false;

  // Sensor values - will be updated from Firebase
  double temperature = 0.0;
  double humidity = 0.0;

  // Devices - only Red LED syncs with Firebase
  List smartDevices = [
    [
      const Icon(LineIcons.lightbulb, size: 35, color: Colors.red),
      "Red LED",
      "Living Room",
      false, // Syncs with Firebase leds/Led_1
    ],
    [
      const Icon(LineIcons.lightbulb, size: 35, color: Colors.blue),
      "Blue LED",
      "Bed Room",
      false, // Local only
    ],
    [
      const Icon(LineIcons.lightbulb, size: 35, color: Colors.green),
      "Green LED",
      "Office",
      false, // Local only
    ],
  ];

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      // Check if Firebase is already initialized
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      _databaseRef = FirebaseDatabase.instance.ref();
      _setupFirebaseListeners();
      setState(() {
        firebaseConnected = true;
      });
      print('Firebase connected successfully!');
    } catch (error) {
      print('Firebase initialization error: $error');
      setState(() {
        firebaseConnected = false;
      });
    }
  }

  void _setupFirebaseListeners() {
    // Listen to Red LED (Led_1) changes
    _databaseRef.child('leds/Led_1').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && mounted) {
        setState(() {
          smartDevices[0][3] = data == true;
        });
      }
    });

    // Listen to Temperature changes
    _databaseRef.child('sensors/temperature').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && mounted) {
        setState(() {
          temperature = (data as num).toDouble();
        });
      }
    });

    // Listen to Humidity changes
    _databaseRef.child('sensors/humidity').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && mounted) {
        setState(() {
          humidity = (data as num).toDouble();
        });
      }
    });
  }

  void onPowerChange(bool value, int index) async {
    setState(() {
      smartDevices[index][3] = value;
    });

    // Only update Firebase for Red LED (index 0)
    if (index == 0 && firebaseConnected) {
      try {
        await _databaseRef.child('leds/Led_1').set(value);
      } catch (error) {
        print('Firebase update error: $error');
        // Revert on error
        setState(() {
          smartDevices[index][3] = !value;
        });
      }
    }
  }

  // Helper method to create colors with opacity
  Color _withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GradientText(
                  'My IoT App',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                  colors: const [
                    Colors.deepPurpleAccent,
                    Colors.deepPurple,
                    Colors.purple,
                  ],
                ),
                Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: firebaseConnected ? Colors.green : Colors.grey.shade900,
                  ),
                  child: Icon(
                    firebaseConnected ? LineIcons.server : LineIcons.powerOff,
                    size: 25,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Temperature and Humidity Display
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // Temperature Card
                Container(
                  height: 85,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: firebaseConnected
                        ? _withOpacity(Colors.orangeAccent, 0.19)
                        : _withOpacity(Colors.redAccent, 0.19),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.thermostat_rounded,
                          size: 60,
                          color: firebaseConnected
                              ? _withOpacity(Colors.orangeAccent, 0.9)
                              : _withOpacity(Colors.redAccent, 0.9)),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            firebaseConnected
                                ? '${temperature.toStringAsFixed(1)}°C'
                                : '--.-°C',
                            style: TextStyle(
                                height: 1,
                                fontSize: 25,
                                fontWeight: FontWeight.w700,
                                color: firebaseConnected
                                    ? _withOpacity(Colors.orangeAccent, 0.9)
                                    : _withOpacity(Colors.redAccent, 0.9)),
                          ),
                          Text(
                            firebaseConnected
                                ? 'Current Temperature'
                                : 'Firebase Disconnected',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: firebaseConnected
                                  ? _withOpacity(Colors.orangeAccent, 0.9)
                                  : _withOpacity(Colors.redAccent, 0.9),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Humidity Card
                Container(
                  height: 85,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: firebaseConnected
                        ? _withOpacity(Colors.blueAccent, 0.19)
                        : _withOpacity(Colors.redAccent, 0.19),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.water_drop_rounded,
                          size: 60,
                          color: firebaseConnected
                              ? _withOpacity(Colors.blueAccent, 0.9)
                              : _withOpacity(Colors.redAccent, 0.9)),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            firebaseConnected
                                ? '${humidity.toStringAsFixed(1)}%'
                                : '--.-%',
                            style: TextStyle(
                                height: 1,
                                fontSize: 25,
                                fontWeight: FontWeight.w700,
                                color: firebaseConnected
                                    ? _withOpacity(Colors.blueAccent, 0.9)
                                    : _withOpacity(Colors.redAccent, 0.9)),
                          ),
                          Text(
                            firebaseConnected
                                ? 'Current Humidity'
                                : 'Firebase Disconnected',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: firebaseConnected
                                  ? _withOpacity(Colors.blueAccent, 0.9)
                                  : _withOpacity(Colors.redAccent, 0.9),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Devices Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Linked Devices',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70),
                ),
                Text(
                  'See All',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          // Devices Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              itemCount: smartDevices.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                return SmartDeviceBox(
                  icon: smartDevices[index][0],
                  deviceName: smartDevices[index][1],
                  deviceLocation: smartDevices[index][2],
                  powerOn: smartDevices[index][3],
                  onChanged: (value) => onPowerChange(value, index),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

class SmartDeviceBox extends StatelessWidget {
  final Icon icon;
  final String deviceName;
  final String deviceLocation;
  final bool powerOn;
  final void Function(bool)? onChanged;

  const SmartDeviceBox({
    super.key,
    required this.icon,
    required this.deviceName,
    required this.deviceLocation,
    required this.powerOn,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: powerOn ? Colors.grey.shade900 : Colors.grey.shade800,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: powerOn ? Colors.greenAccent : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            icon.icon,
            size: 35,
            color: powerOn ? Colors.greenAccent : Colors.white70,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                deviceName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: powerOn ? Colors.white : Colors.white70,
                ),
              ),
              Text(
                deviceLocation,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: powerOn ? Colors.greenAccent : Colors.white54,
                ),
              ),
            ],
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: powerOn,
              onChanged: onChanged,
              activeColor: Colors.greenAccent, // This is actually still supported for now
              inactiveThumbColor: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}