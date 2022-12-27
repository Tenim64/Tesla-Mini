// Packages
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tesla_mini/debugger.dart';
import 'package:tesla_mini/globals.dart';
import 'package:tesla_mini/menubuttons.dart';
import 'package:tesla_mini/tensorflow.dart';
import 'package:tesla_mini/globals.dart' as globals;
import 'package:tesla_mini/udpserver.dart';

// UI
class Interface extends StatefulWidget {
  const Interface(
      {super.key,
      required this.pInitializeControllerFuture,
      required this.pController});

  final Future<void> pInitializeControllerFuture;
  final CameraController pController;

  @override
  InterfaceState createState() => InterfaceState();
}

class InterfaceState extends State<Interface> {
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
                  toggleCameraButton(widget.pController);
                  setState(() {});
                },
                child: recognitionsNotifier.value.isOdd
                    ? const Text('Stop')
                    : const Text('Start')),
            TextButton(
                onPressed: () {
                  focusButton(widget.pController);
                },
                child: const Text(
                  'Focus',
                )),
            TextButton(
                onPressed: () {
                  testTCP();
                },
                child: const Text('Test UDP')),
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
        future: widget.pInitializeControllerFuture,
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
                      child: SizedBox(
                          key: cameraPreviewWrapper,
                          height: double.infinity,
                          width: double.infinity,
                          child: CameraPreview(widget.pController)),
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

String errorToExplanation(error) {
  String explenation = error;

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
