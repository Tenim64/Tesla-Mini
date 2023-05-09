// ignore_for_file: non_constant_identifier_names
// ---------- Packages
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tesla_mini/debugger.dart';
import 'package:tesla_mini/globals.dart';
import 'package:tesla_mini/menubuttons.dart';
import 'package:tesla_mini/tensorflow.dart';
import 'package:tesla_mini/globals.dart' as globals;
import 'package:tesla_mini/tcpserver.dart';
import 'package:tesla_mini/carfunctions.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math' as math;

// ---------- Extra
final List<Widget> pages = [
  const HomePage(),
  const ControllerPage(),
  CameraPage(camera: globals.mainCamera)
];

// ---------- Widgets
String welcomeText() {
  final currentHour = DateTime.now().hour;
  if (currentHour < 6) {
    return "Good evening!";
  }
  if (currentHour < 12) {
    return "Good morning!";
  }
  if (currentHour < 18) {
    return "Good afternoon!";
  }
  return "Good evening!";
}

class Joystick extends StatefulWidget {
  final ValueChanged<double> onChanged;
  final BuildContext context;
  final double angle;

  const Joystick({
    super.key,
    required this.onChanged,
    required this.context,
    required this.angle,
  });

  @override
  JoystickState createState() => JoystickState();
}

class JoystickState extends State<Joystick> {
  double sliderValue = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsetsDirectional.all(
            MediaQuery.of(context).size.aspectRatio * 50),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFC8C8C8),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFBCBCBC),
              width: MediaQuery.of(context).size.aspectRatio * 20,
            ),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(12),
            child: Transform.rotate(
              angle: math.pi * 2 / 360 * widget.angle,
              child: Slider(
                min: -100,
                max: 100,
                value: sliderValue,
                divisions: 200,
                onChanged: (newValue) {
                  setState(() {
                    sliderValue = newValue;
                  });
                  widget.onChanged(newValue);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Dialog extends StatefulWidget {
  const Dialog({
    super.key,
  });

  @override
  DialogState createState() => DialogState();
}

class DialogState extends State<Dialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      builder: (context, snapshot) {
        return Stack(
          children: [
            (() {
              return Center(
                child: ValueListenableBuilder(
                  valueListenable: globals.dialogNotifier,
                  builder: (context, value, child) {
                    if (value != 0) {
                      Future.delayed(const Duration(seconds: 0), () {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return makeDialog(context);
                            });
                      });
                    }
                    return const SizedBox();
                  },
                ),
              );
            }())
          ],
        );
      },
    );
  }
}

// ---------- Pages
// ---- Home page
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String carName = "Tesla Mini";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 242, 242, 242),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 108),
              child: Column(children: [
                Stack(
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsetsDirectional.only(
                                top: 0, end: 32),
                            child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Text(
                                  welcomeText(),
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                      fontSize: 100,
                                      fontWeight: FontWeight.bold),
                                )),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: EdgeInsetsDirectional.only(
                                start: 4,
                                end: MediaQuery.of(context).size.width * 0.24),
                            child: const FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Text(
                                  "Your Tesla Mini is waiting for you",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(fontSize: 100),
                                )),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                Stack(children: [
                  Padding(
                      padding: const EdgeInsetsDirectional.only(top: 24),
                      child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 226, 226, 226),
                            borderRadius: BorderRadius.circular(24),
                            shape: BoxShape.rectangle,
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    24, 4, 0, 0),
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          globals.carName,
                                          style: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.075,
                                            fontWeight: FontWeight.bold,
                                            height: 0,
                                            color: const Color(0xFF3E3E3E),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Opacity(
                                      opacity: 0,
                                      child: Padding(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                                bottom: 4),
                                        child: FittedBox(
                                          fit: BoxFit.fitHeight,
                                          child: IconButton(
                                            icon: const FittedBox(
                                              fit: BoxFit.fitHeight,
                                              child: Opacity(
                                                opacity: 0.3,
                                                child: Icon(
                                                  Icons.edit_outlined,
                                                  color: Color(0xFF3E3E3E),
                                                  size: 100,
                                                ),
                                              ),
                                            ),
                                            onPressed: () {
                                              printMessage("*Edit name*");
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(
                                color: Color(0xFF808080),
                                height: 0,
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    16, 4, 16, 16),
                                child: Row(
                                  children: [
                                    ValueListenableBuilder(
                                        valueListenable:
                                            globals.connectionStateNotifier,
                                        builder: (context, value, child) {
                                          return Expanded(
                                              child: Column(children: [
                                            const AspectRatio(
                                              aspectRatio: 6 / 1,
                                              child: Align(
                                                alignment:
                                                    AlignmentDirectional.center,
                                                child: Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .only(top: 8, bottom: 2),
                                                  child: FittedBox(
                                                    fit: BoxFit.fitHeight,
                                                    child: Text(
                                                      'Connection:',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF808080),
                                                        fontSize: 100,
                                                        height: 1,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                getCarState();
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                  shape: BoxShape.rectangle,
                                                  color: const Color.fromARGB(
                                                      255, 200, 200, 200),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .all(12),
                                                  child: Column(children: [
                                                    AspectRatio(
                                                      aspectRatio: 1 / 1,
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                          shape: BoxShape
                                                              .rectangle,
                                                          color: const Color
                                                                  .fromARGB(255,
                                                              242, 242, 242),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .all(20),
                                                          child:
                                                              Stack(children: [
                                                            if (globals
                                                                    .connectionState ==
                                                                -1)
                                                              const Align(
                                                                alignment:
                                                                    AlignmentDirectional(
                                                                        0, 0),
                                                                child:
                                                                    FittedBox(
                                                                  fit: BoxFit
                                                                      .fill,
                                                                  child: FaIcon(
                                                                    FontAwesomeIcons
                                                                        .xmark,
                                                                    color: Color(
                                                                        0xFFE30000),
                                                                    size: 500,
                                                                  ),
                                                                ),
                                                              ),
                                                            if (globals
                                                                    .connectionState ==
                                                                0)
                                                              const Align(
                                                                alignment:
                                                                    AlignmentDirectional(
                                                                        0, 0),
                                                                child:
                                                                    FittedBox(
                                                                  fit: BoxFit
                                                                      .fill,
                                                                  child: FaIcon(
                                                                    FontAwesomeIcons
                                                                        .wifi,
                                                                    color: Color(
                                                                        0xFFFFB800),
                                                                    size: 500,
                                                                  ),
                                                                ),
                                                              ),
                                                            if (globals
                                                                    .connectionState ==
                                                                1)
                                                              const Align(
                                                                alignment:
                                                                    AlignmentDirectional(
                                                                        0, 0),
                                                                child:
                                                                    FittedBox(
                                                                  fit: BoxFit
                                                                      .fill,
                                                                  child: FaIcon(
                                                                    FontAwesomeIcons
                                                                        .check,
                                                                    color: Color(
                                                                        0xFF2060F2),
                                                                    size: 500,
                                                                  ),
                                                                ),
                                                              ),
                                                          ]),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsetsDirectional
                                                              .only(top: 8),
                                                      child: AspectRatio(
                                                        aspectRatio: 16 / 5,
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                            shape: BoxShape
                                                                .rectangle,
                                                            color: const Color
                                                                    .fromARGB(
                                                                255,
                                                                242,
                                                                242,
                                                                242),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                    16,
                                                                    7,
                                                                    16,
                                                                    7),
                                                            child: FittedBox(
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                              child: Stack(
                                                                children: [
                                                                  if (globals
                                                                          .connectionState ==
                                                                      -1)
                                                                    const Text(
                                                                      'Disconnected',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        color: Color(
                                                                            0xFFE30000),
                                                                        fontSize:
                                                                            100,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        height:
                                                                            1.25,
                                                                      ),
                                                                    ),
                                                                  if (globals
                                                                          .connectionState ==
                                                                      0)
                                                                    const Text(
                                                                      'Connecting',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        color: Color(
                                                                            0xFFFFB800),
                                                                        fontSize:
                                                                            100,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        height:
                                                                            1.25,
                                                                      ),
                                                                    ),
                                                                  if (globals
                                                                          .connectionState ==
                                                                      1)
                                                                    const Text(
                                                                      'Connected',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        color: Color(
                                                                            0xFF2060F2),
                                                                        fontSize:
                                                                            100,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        height:
                                                                            1.25,
                                                                      ),
                                                                    ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ]),
                                                ),
                                              ),
                                            ),
                                          ]));
                                        }),
                                    const VerticalDivider(width: 16),
                                    ValueListenableBuilder(
                                      valueListenable:
                                          globals.connectionStateNotifier,
                                      builder: (context, value, child) {
                                        return ValueListenableBuilder(
                                          valueListenable:
                                              globals.batteryStateNotifier,
                                          builder: (context, value, child) {
                                            return Expanded(
                                                child: Column(children: [
                                              const AspectRatio(
                                                aspectRatio: 6 / 1,
                                                child: Align(
                                                  alignment:
                                                      AlignmentDirectional
                                                          .center,
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .only(
                                                                top: 8,
                                                                bottom: 2),
                                                    child: FittedBox(
                                                      fit: BoxFit.fitHeight,
                                                      child: Text(
                                                        'Battery:',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xFF808080),
                                                          fontSize: 100,
                                                          height: 1,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  getSetBatteryState();
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            24),
                                                    shape: BoxShape.rectangle,
                                                    color: const Color.fromARGB(
                                                        255, 200, 200, 200),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsetsDirectional
                                                            .all(12),
                                                    child: Column(children: [
                                                      AspectRatio(
                                                        aspectRatio: 1 / 1,
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                            shape: BoxShape
                                                                .rectangle,
                                                            color: const Color(
                                                                0xFFF2F2F2),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsetsDirectional
                                                                    .all(20),
                                                            child: Stack(
                                                                children: [
                                                                  if (globals.connectionState ==
                                                                          -1 ||
                                                                      globals.connectionState ==
                                                                          0) ...[
                                                                    const Align(
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              0,
                                                                              0),
                                                                      child:
                                                                          FittedBox(
                                                                        fit: BoxFit
                                                                            .fill,
                                                                        child:
                                                                            FaIcon(
                                                                          FontAwesomeIcons
                                                                              .question,
                                                                          color:
                                                                              Color(0xFFE30000),
                                                                          size:
                                                                              500,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ] else ...[
                                                                    if (globals
                                                                            .batteryState ==
                                                                        -1)
                                                                      const Align(
                                                                        alignment: AlignmentDirectional(
                                                                            0,
                                                                            0),
                                                                        child:
                                                                            FittedBox(
                                                                          fit: BoxFit
                                                                              .fill,
                                                                          child:
                                                                              FaIcon(
                                                                            FontAwesomeIcons.batteryEmpty,
                                                                            color:
                                                                                Color(0xFFE35200),
                                                                            size:
                                                                                500,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    if (globals
                                                                            .batteryState ==
                                                                        0)
                                                                      const Align(
                                                                        alignment: AlignmentDirectional(
                                                                            0,
                                                                            0),
                                                                        child:
                                                                            FittedBox(
                                                                          fit: BoxFit
                                                                              .fill,
                                                                          child:
                                                                              FaIcon(
                                                                            FontAwesomeIcons.bolt,
                                                                            color:
                                                                                Color(0xFFDFBB00),
                                                                            size:
                                                                                500,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    if (globals
                                                                            .batteryState ==
                                                                        1)
                                                                      const Align(
                                                                        alignment: AlignmentDirectional(
                                                                            0,
                                                                            0),
                                                                        child:
                                                                            FittedBox(
                                                                          fit: BoxFit
                                                                              .fill,
                                                                          child:
                                                                              FaIcon(
                                                                            FontAwesomeIcons.batteryFull,
                                                                            color:
                                                                                Color(0xFF00DF09),
                                                                            size:
                                                                                500,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                  ]
                                                                ]),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .only(top: 8),
                                                        child: AspectRatio(
                                                          aspectRatio: 16 / 5,
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                              shape: BoxShape
                                                                  .rectangle,
                                                              color: const Color(
                                                                  0xFFF2F2F2),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsetsDirectional
                                                                          .fromSTEB(
                                                                      16,
                                                                      7,
                                                                      16,
                                                                      7),
                                                              child: FittedBox(
                                                                fit: BoxFit
                                                                    .scaleDown,
                                                                child: Stack(
                                                                    children: [
                                                                      if (globals.connectionState ==
                                                                              -1 ||
                                                                          globals.connectionState ==
                                                                              0) ...[
                                                                        const Text(
                                                                          'Unknown',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Color(0xFFE30000),
                                                                            fontSize:
                                                                                100,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            height:
                                                                                1.25,
                                                                          ),
                                                                        ),
                                                                      ] else ...[
                                                                        if (globals.batteryState ==
                                                                            -1)
                                                                          const Text(
                                                                            'Low battery',
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style:
                                                                                TextStyle(
                                                                              color: Color(0xFFE35200),
                                                                              fontSize: 100,
                                                                              fontWeight: FontWeight.bold,
                                                                              height: 1.25,
                                                                            ),
                                                                          ),
                                                                        if (globals.batteryState ==
                                                                            0)
                                                                          const Text(
                                                                            'Charging',
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style:
                                                                                TextStyle(
                                                                              color: Color(0xFFDFBB00),
                                                                              fontSize: 100,
                                                                              fontWeight: FontWeight.bold,
                                                                              height: 1.25,
                                                                            ),
                                                                          ),
                                                                        if (globals.batteryState ==
                                                                            1)
                                                                          const Text(
                                                                            'Charged',
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style: TextStyle(
                                                                                color: Color(0xFF00DF09),
                                                                                fontSize: 100,
                                                                                fontWeight: FontWeight.bold,
                                                                                height: 1.25),
                                                                          ),
                                                                      ],
                                                                    ]),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ]),
                                                  ),
                                                ),
                                              ),
                                            ]));
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              )
                            ],
                          )))
                ])
              ]),
            ),
            navbar(context),
            Dialog(),
          ],
        ),
      ),
    );
  }
}

// ---- Controller
class ControllerPage extends StatefulWidget {
  const ControllerPage({super.key});

  @override
  ControllerPageState createState() => ControllerPageState();
}

class ControllerPageState extends State<ControllerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 242, 242, 242),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 108),
              child: Column(children: [
                Expanded(
                  child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFE2E2E2),
                        borderRadius: BorderRadius.all(Radius.circular(35)),
                      ),
                      child: Stack(children: [
                        Column(
                          children: [
                            Joystick(
                              onChanged: (newValue) {
                                setTurnPercentage(newValue.round());
                              },
                              context: context,
                              angle: 90,
                            ),
                            Joystick(
                              onChanged: (newValue) {
                                setSpeed(newValue.round());
                              },
                              context: context,
                              angle: 0,
                            ),
                          ],
                        ),
                        Positioned(
                          right: MediaQuery.of(context).size.aspectRatio * 20,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFFF2F2F2),
                              shape: BoxShape.circle,
                            ),
                            width:
                                MediaQuery.of(context).size.aspectRatio * 150,
                            height:
                                MediaQuery.of(context).size.aspectRatio * 150,
                            child: IconButton(
                              icon: Icon(
                                Icons.open_in_full,
                                size: MediaQuery.of(context).size.aspectRatio *
                                    100,
                                color: const Color(0xFFCC0000),
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      //pageBuilder: (context, animation, secondaryAnimation) => FullControllerPage(),
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          pages.elementAt(1),
                                      transitionDuration:
                                          const Duration(milliseconds: 180),
                                      transitionsBuilder: (context, animation,
                                              secondaryAnimation, child) =>
                                          FadeTransition(
                                              opacity: animation, child: child),
                                    ));
                              },
                            ),
                          ),
                        )
                      ])),
                )
              ]),
            ),
            navbar(context),
            Dialog(),
          ],
        ),
      ),
    );
  }
}

// ---- Camera AI page
class CameraPage extends StatefulWidget {
  const CameraPage({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  CameraPageState createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> {
  late CameraController controller;
  late Future<void> initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.max,
      // Disable audio recording
      enableAudio: false,
      // Format of the images
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    // Next, initialize the controller. This returns a Future.
    initializeControllerFuture = controller.initialize();

    // Load Tensorflow models
    tfLoadModel('Android');
  }

  @override
  void dispose() {
    // Dispose app
    super.dispose();
    // Dispose of the controller when the widget is disposed.
    controller.stopImageStream();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    GlobalKey cameraPreviewWrapper = GlobalKey();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            TextButton(
                onPressed: () {
                  toggleCameraButton(controller);
                  setState(() {});
                },
                child: recognitionsNotifier.value.isOdd
                    ? const Text('Stop')
                    : const Text('Start')),
            TextButton(
                onPressed: () {
                  focusButton(controller);
                },
                child: const Text(
                  'Focus',
                )),
            TextButton(
                onPressed: () {
                  testTCP();
                },
                child: const Text('Test TCP')),
            TextButton(
                onPressed: () {
                  restartButton();
                },
                child: const Text(
                  'Restart',
                )),
          ],
        ),
        titleSpacing: 5,
        toolbarHeight: 40.0,
      ),
      body: FutureBuilder<void>(
        future: initializeControllerFuture,
        builder: (context, snapshot) {
          return Stack(
            children: [
              (() {
                return Dialog();
              }()),
              (() {
                if (snapshot.connectionState == ConnectionState.done) {
                  // If the Future is complete, display the preview.
                  return Stack(children: [
                    Center(
                      child: SizedBox(
                          key: cameraPreviewWrapper,
                          height: double.infinity,
                          width: double.infinity,
                          child: CameraPreview(controller)),
                    ),
                    ValueListenableBuilder(
                        valueListenable: recognitionsNotifier,
                        builder: (context, value, widget) {
                          final keyContext =
                              cameraPreviewWrapper.currentContext;
                          final box =
                              keyContext!.findRenderObject() as RenderBox;
                          if (value != 0) {
                            final boxes = displayBoxesAroundRecognizedObjects(
                                box.hasSize ? box.size : size);
                            isProcessing = false;
                            return Stack(
                              children: boxes,
                            );
                          } else {
                            return Stack();
                          }
                        }),
                  ]);
                } else {
                  // Otherwise, display a loading indicator.
                  return const Center(child: CircularProgressIndicator());
                }
              }()),
            ],
          );
        },
      ),
    );
  }
}

Widget navbarItem(IconData icon, int index, dynamic context) {
  return Expanded(
    child: GestureDetector(
      onTap: () async {
        globals.currentPageIndex = index;

        Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  pages.elementAt(index),
              transitionDuration: const Duration(milliseconds: 180),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      FadeTransition(opacity: animation, child: child),
            ));
      },
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(6, 0, 6, 4),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: const BorderSide(width: 0, color: Color(0x00000000)),
              top: const BorderSide(width: 0, color: Color(0x00000000)),
              right: const BorderSide(width: 0, color: Color(0x00000000)),
              bottom: BorderSide(
                  width: MediaQuery.of(context).size.height * 0.004,
                  color: globals.currentPageIndex == index
                      ? const Color(0xFFFFFFFF)
                      : const Color(0x00000000)),
            ),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(4, 10, 4, 2),
            child: Icon(
              icon,
              size: MediaQuery.of(context).size.height * 0.055,
              color: globals.currentPageIndex == index
                  ? const Color(0xFFFFFFFF)
                  : const Color(0xFFE2E2E2),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget navbar(context) {
  return Positioned(
    bottom: 0,
    left: 0,
    right: 0,
    child: Container(
      height: MediaQuery.of(context).size.height * 0.1,
      decoration: BoxDecoration(
        color: const Color(0xFFCC0000),
        borderRadius: BorderRadiusDirectional.vertical(
          top: Radius.circular(MediaQuery.of(context).size.height * 0.05),
          bottom: const Radius.circular(0),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(12, 6, 12, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  navbarItem(Icons.home, 0, context),
                  navbarItem(Icons.directions_car, 1, context),
                  navbarItem(Icons.pin_drop, 2, context),
                  navbarItem(Icons.memory, 3, context),
                  navbarItem(Icons.account_circle, 4, context),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ---- Pop up
String errorToExplanation(error) {
  String explenation = error;

  if (error.contains("Connection reset by peer")) {
    explenation = "Connection issues emerged: please restart your Tesla Mini";
  }
  if (error.contains("Connection timed out")) {
    explenation =
        "Failed to connect: check the network connection to your Tesla Mini";
  }
  if (error.contains("Network is unreachable")) {
    explenation =
        "No network connection found: try (re)connecting to the Tesla Mini";
  }

  return explenation;
}

CupertinoAlertDialog makeDialog(context) {
  globals.dialogContent = errorToExplanation(globals.dialogContent);

  return CupertinoAlertDialog(
    title: Text(globals.dialogTitle),
    content: Text(globals.dialogContent),
    actions: (() {
      List<CupertinoDialogAction> actions = [];
      if (globals.dialogBtn1Function == closeDialog) {
        actions.add(CupertinoDialogAction(
          onPressed: () => closeDialog(context),
          child: Text(globals.dialogBtn1Content),
        ));
      } else {
        actions.add(CupertinoDialogAction(
          onPressed: globals.dialogBtn1Function(),
          child: Text(globals.dialogBtn1Content),
        ));
      }
      if (globals.dialogButtonCount == 2) {
        actions.add(CupertinoDialogAction(
          onPressed: globals.dialogBtn2Function(),
          child: Text(dialogBtn2Content),
        ));
      }
      return actions;
    }()),
  );
}
