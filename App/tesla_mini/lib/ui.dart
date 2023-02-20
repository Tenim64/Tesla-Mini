// ---------- Packages
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

// ---------- UI
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
        child: Padding(
          padding: const EdgeInsetsDirectional.all(24),
          child: Column(children: [
            Stack(
              children: [
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(top: 0, end: 32),
                        child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text(
                              welcomeText(),
                              textAlign: TextAlign.start,
                              style: const TextStyle(fontSize: 100, fontWeight: FontWeight.bold),
                            )),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(start: 4, end: MediaQuery.of(context).size.width * 0.24),
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
            Stack(
              children: [
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
                          padding: const EdgeInsetsDirectional.fromSTEB(24, 4, 0, 0),
                          child: Row(
                            children: [
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    globals.carName,
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.width * 0.075,
                                      fontWeight: FontWeight.bold,
                                      height: 0,
                                      color: const Color(0xFF3E3E3E),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.only(bottom: 4),
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
                            ],
                          ),
                        ),
                        const Divider(
                          color: Color(0xFF808080),
                          height: 0,
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 16),
                          child: Row(
                            children: [
                              ValueListenableBuilder(
                                  valueListenable: globals.connectionStateNotifier,
                                  builder: (context, value, child) {
                                    return Expanded(
                                        child: Column(children: [
                                      const AspectRatio(
                                        aspectRatio: 6 / 1,
                                        child: Align(
                                          alignment: AlignmentDirectional.center,
                                          child: Padding(
                                            padding: EdgeInsetsDirectional.only(top: 8, bottom: 2),
                                            child: FittedBox(
                                              fit: BoxFit.fitHeight,
                                              child: Text(
                                                'Connection:',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Color(0xFF808080),
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
                                          checkTCPServerStatus();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(24),
                                            shape: BoxShape.rectangle,
                                            color: const Color.fromARGB(255, 200, 200, 200),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional.all(12),
                                            child: Column(children: [
                                              AspectRatio(
                                                aspectRatio: 1 / 1,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(20),
                                                    shape: BoxShape.rectangle,
                                                    color: const Color.fromARGB(255, 242, 242, 242),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsetsDirectional.all(20),
                                                    child: Stack(children: [
                                                      if (globals.connectionState == -1)
                                                        const Align(
                                                          alignment: AlignmentDirectional(0, 0),
                                                          child: FittedBox(
                                                            fit: BoxFit.fill,
                                                            child: FaIcon(
                                                              FontAwesomeIcons.xmark,
                                                              color: Color(0xFFE30000),
                                                              size: 500,
                                                            ),
                                                          ),
                                                        ),
                                                      if (globals.connectionState == 0)
                                                        const Align(
                                                          alignment: AlignmentDirectional(0, 0),
                                                          child: FittedBox(
                                                            fit: BoxFit.fill,
                                                            child: FaIcon(
                                                              FontAwesomeIcons.wifi,
                                                              color: Color(0xFFFFB800),
                                                              size: 500,
                                                            ),
                                                          ),
                                                        ),
                                                      if (globals.connectionState == 1)
                                                        const Align(
                                                          alignment: AlignmentDirectional(0, 0),
                                                          child: FittedBox(
                                                            fit: BoxFit.fill,
                                                            child: FaIcon(
                                                              FontAwesomeIcons.check,
                                                              color: Color(0xFF2060F2),
                                                              size: 500,
                                                            ),
                                                          ),
                                                        ),
                                                    ]),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsetsDirectional.only(top: 8),
                                                child: AspectRatio(
                                                  aspectRatio: 16 / 5,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(20),
                                                      shape: BoxShape.rectangle,
                                                      color: const Color.fromARGB(255, 242, 242, 242),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsetsDirectional.fromSTEB(16, 7, 16, 7),
                                                      child: FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        child: Stack(
                                                          children: [
                                                            if (globals.connectionState == -1)
                                                              const Text(
                                                                'Disconnected',
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                  color: Color(0xFFE30000),
                                                                  fontSize: 100,
                                                                  fontWeight: FontWeight.bold,
                                                                  height: 1.25,
                                                                ),
                                                              ),
                                                            if (globals.connectionState == 0)
                                                              const Text(
                                                                'Connecting',
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                  color: Color(0xFFFFB800),
                                                                  fontSize: 100,
                                                                  fontWeight: FontWeight.bold,
                                                                  height: 1.25,
                                                                ),
                                                              ),
                                                            if (globals.connectionState == 1)
                                                              const Text(
                                                                'Connected',
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                  color: Color(0xFF2060F2),
                                                                  fontSize: 100,
                                                                  fontWeight: FontWeight.bold,
                                                                  height: 1.25,
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
                                valueListenable: globals.connectionStateNotifier,
                                builder: (context, value, child) {
                                  return ValueListenableBuilder(
                                    valueListenable: globals.batteryStateNotifier,
                                    builder: (context, value, child) {
                                      return Expanded(
                                          child: Column(children: [
                                        const AspectRatio(
                                          aspectRatio: 6 / 1,
                                          child: Align(
                                            alignment: AlignmentDirectional.center,
                                            child: Padding(
                                              padding: EdgeInsetsDirectional.only(top: 8, bottom: 2),
                                              child: FittedBox(
                                                fit: BoxFit.fitHeight,
                                                child: Text(
                                                  'Battery:',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Color(0xFF808080),
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
                                              borderRadius: BorderRadius.circular(24),
                                              shape: BoxShape.rectangle,
                                              color: const Color.fromARGB(255, 200, 200, 200),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsetsDirectional.all(12),
                                              child: Column(children: [
                                                AspectRatio(
                                                  aspectRatio: 1 / 1,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(20),
                                                      shape: BoxShape.rectangle,
                                                      color: const Color.fromARGB(255, 242, 242, 242),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsetsDirectional.all(20),
                                                      child: Stack(children: [
                                                        if (globals.connectionState == -1 || globals.connectionState == 0) ...[
                                                          const Align(
                                                            alignment: AlignmentDirectional(0, 0),
                                                            child: FittedBox(
                                                              fit: BoxFit.fill,
                                                              child: FaIcon(
                                                                FontAwesomeIcons.xmark,
                                                                color: Color(0xFFE30000),
                                                                size: 500,
                                                              ),
                                                            ),
                                                          ),
                                                        ] else ...[
                                                          if (globals.batteryState == -1)
                                                            const Align(
                                                              alignment: AlignmentDirectional(0, 0),
                                                              child: FittedBox(
                                                                fit: BoxFit.fill,
                                                                child: FaIcon(
                                                                  FontAwesomeIcons.batteryEmpty,
                                                                  color: Color(0xFFE35200),
                                                                  size: 500,
                                                                ),
                                                              ),
                                                            ),
                                                          if (globals.batteryState == 0)
                                                            const Align(
                                                              alignment: AlignmentDirectional(0, 0),
                                                              child: FittedBox(
                                                                fit: BoxFit.fill,
                                                                child: FaIcon(
                                                                  FontAwesomeIcons.bolt,
                                                                  color: Color(0xFFDFBB00),
                                                                  size: 500,
                                                                ),
                                                              ),
                                                            ),
                                                          if (globals.batteryState == 1)
                                                            const Align(
                                                              alignment: AlignmentDirectional(0, 0),
                                                              child: FittedBox(
                                                                fit: BoxFit.fill,
                                                                child: FaIcon(
                                                                  FontAwesomeIcons.batteryFull,
                                                                  color: Color(0xFF00DF09),
                                                                  size: 500,
                                                                ),
                                                              ),
                                                            ),
                                                        ]
                                                      ]),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsetsDirectional.only(top: 8),
                                                  child: AspectRatio(
                                                    aspectRatio: 16 / 5,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(20),
                                                        shape: BoxShape.rectangle,
                                                        color: const Color.fromARGB(255, 242, 242, 242),
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsetsDirectional.fromSTEB(16, 7, 16, 7),
                                                        child: FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          child: Stack(children: [
                                                            if (globals.connectionState == -1 || globals.connectionState == 0) ...[
                                                              const Text(
                                                                'Disconnected',
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                  color: Color(0xFFE30000),
                                                                  fontSize: 100,
                                                                  fontWeight: FontWeight.bold,
                                                                  height: 1.25,
                                                                ),
                                                              ),
                                                            ] else ...[
                                                              if (globals.batteryState == -1)
                                                                const Text(
                                                                  'Low battery',
                                                                  textAlign: TextAlign.center,
                                                                  style: TextStyle(
                                                                    color: Color(0xFFE35200),
                                                                    fontSize: 100,
                                                                    fontWeight: FontWeight.bold,
                                                                    height: 1.25,
                                                                  ),
                                                                ),
                                                              if (globals.batteryState == 0)
                                                                const Text(
                                                                  'Charging',
                                                                  textAlign: TextAlign.center,
                                                                  style: TextStyle(
                                                                    color: Color(0xFFDFBB00),
                                                                    fontSize: 100,
                                                                    fontWeight: FontWeight.bold,
                                                                    height: 1.25,
                                                                  ),
                                                                ),
                                                              if (globals.batteryState == 1)
                                                                const Text(
                                                                  'Charged',
                                                                  textAlign: TextAlign.center,
                                                                  style: TextStyle(color: Color(0xFF00DF09), fontSize: 100, fontWeight: FontWeight.bold, height: 1.25),
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
                        ),
                      ],
                    ),
                  ),
                )
              ],
            )
          ]),
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
                child: recognitionsNotifier.value.isOdd ? const Text('Stop') : const Text('Start')),
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
                return Center(
                    child: ValueListenableBuilder(
                        valueListenable: globals.dialogNotifier,
                        builder: (context, value, child) {
                          if (value != 0) {
                            Future.delayed(const Duration(seconds: 0), () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return makeDialog(context);
                                  });
                            });
                          }
                          return const SizedBox();
                        }));
              }()),
              (() {
                if (snapshot.connectionState == ConnectionState.done) {
                  // If the Future is complete, display the preview.
                  return Stack(children: [
                    Center(
                      child: SizedBox(key: cameraPreviewWrapper, height: double.infinity, width: double.infinity, child: CameraPreview(controller)),
                    ),
                    ValueListenableBuilder(
                        valueListenable: recognitionsNotifier,
                        builder: (context, value, widget) {
                          final keyContext = cameraPreviewWrapper.currentContext;
                          final box = keyContext!.findRenderObject() as RenderBox;
                          if (value != 0) {
                            final boxes = displayBoxesAroundRecognizedObjects(box.hasSize ? box.size : size);
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

// ---- Pop up
String errorToExplanation(error) {
  String explenation = error;

  if (error.contains("Connection timed out")) {
    explenation = "Failed to connect: check the network connection to your Tesla Mini";
  }
  if (error.contains("Network is unreachable")) {
    explenation = "No network connection found: try (re)connecting to the Tesla Mini";
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
