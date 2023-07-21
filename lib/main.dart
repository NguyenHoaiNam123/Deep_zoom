import 'dart:math';
import 'dart:typed_data';

import 'package:deep_zoom/CustomPaint.dart';
import 'package:deep_zoom/object/render_object.dart';
import 'package:deep_zoom/object/touch_object.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui show Image;
import 'dart:ui';

import 'package:flutter/services.dart';

ui.Image? image;

void main() {
  runApp(MyApp());
}

Future<ui.Image> loadAsset() async {
  final byteData = await rootBundle.load('assets/deepzoom1.jpeg');
  final codec = await instantiateImageCodec(byteData.buffer.asUint8List());
  return (await codec.getNextFrame()).image;
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State {
  PaintObject paintObject = PaintObject();
  List<PointerInfo> pointerInfo = [];

  @override
  void initState() {
    super.initState();
    loadAsset().then((value) {
      image = value;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Listener(
          onPointerDown: (details) {
            print("onPointerDown: " +
                details.pointer.toString() +
                ", " +
                "dx: " +
                details.position.dx.toString() +
                "dy: " +
                details.position.dy.toString());
            PointerInfo info = PointerInfo();
            info.pointerEvent = details;
            info.xDown = details.position.dx;
            info.yDown = details.position.dy;
            pointerInfo.add(info);
            printInfo();
          },
          onPointerUp: (details) {
            print("onPointerUp: " +
                details.pointer.toString() +
                ", " +
                "dx: " +
                details.position.dx.toString() +
                "dy: " +
                details.position.dy.toString());
            if (pointerInfo.length == 2) {
              PointerInfo p = pointerInfo
                  .where((element) =>
                      element.pointerEvent?.pointer.toString() !=
                      details.pointer.toString())
                  .first;
              p.xDown = (p.pointerEvent?.position.dx ?? 0) -
                  (paintObject.x - paintObject.xOld);
              p.yDown = (p.pointerEvent?.position.dy ?? 0) -
                  (paintObject.y - paintObject.yOld);
              paintObject.oldWidth = paintObject.width;
              paintObject.oldHeight = paintObject.height;
            } else
              paintObject.xOld = paintObject.x;
            paintObject.yOld = paintObject.y;

            final info = pointerInfo
                .where((element) =>
                    element.pointerEvent?.pointer.toString() ==
                    details.pointer.toString())
                .first;
            pointerInfo.remove(info);
            printInfo();
          },
          onPointerMove: (details) {
            print("onPointerMove: " +
                details.pointer.toString() +
                ", " +
                "dx: " +
                details.position.dx.toString() +
                "dy: " +
                details.position.dy.toString());
            if (pointerInfo.isEmpty) {
              return;
            }
            if (pointerInfo.length == 1) {
              double deltaX = details.position.dx - pointerInfo[0].xDown;
              double deltaY = details.position.dy - pointerInfo[0].yDown;
              paintObject.x = deltaX + paintObject.xOld;
              paintObject.y = deltaY + paintObject.yOld;
            } else if (pointerInfo.length > 1) {
              //update pointerInfo
              var pInfo = pointerInfo.where((element) =>
                  element.pointerEvent?.pointer.toString() ==
                  details.pointer.toString());
              if (pInfo.isEmpty) {
                pInfo.first.pointerEvent = details;
              }

              PointerInfo p1 = pointerInfo[0];
              PointerInfo p2 = pointerInfo[1];

              double p1X = p1.pointerEvent?.position.dx ?? 0;
              double p1Y = p1.pointerEvent?.position.dy ?? 0;
              double p2X = p2.pointerEvent?.position.dx ?? 0;
              double p2Y = p2.pointerEvent?.position.dy ?? 0;
              double distance = sqrt(pow(p1X - p2X, 2) + pow(p1Y - p2Y, 2));
              double centerX = (p2X + p1X) / 2;
              double centerY = (p2Y + p1Y) / 2;

              double p1DownPositionX = p1.xDown;
              double p1DownPositionY = p1.yDown;
              double p2DownPositionX = p2.xDown;
              double p2DownPositionY = p1.yDown;
              double downDistance = sqrt(
                  pow(p2DownPositionX - p1DownPositionX, 2) +
                      pow(p2DownPositionY - p2DownPositionY, 2));

              double centerDownX = (p2DownPositionX + p1DownPositionX) / 2;
              double centerDownY = (p2DownPositionY + p1DownPositionY) / 2;

              double scale = distance / downDistance;
              paintObject.width = paintObject.oldWidth * scale;
              paintObject.height = paintObject.oldHeight * scale;

              double centerDownToObjectX = centerDownX - paintObject.xOld;
              double centerDownToObjectY = centerDownY - paintObject.yOld;
              double newCenterDownToObjectX = centerDownToObjectX * scale;
              double newCenterDownToObjectY = centerDownToObjectY * scale;
              double offsetScaleX =
                  newCenterDownToObjectX - centerDownToObjectX;
              double offsetScaleY =
                  newCenterDownToObjectY - centerDownToObjectY;

              paintObject.x =
                  paintObject.xOld + (centerX - centerDownX) - offsetScaleX;
              paintObject.y =
                  paintObject.yOld + (centerY - centerDownY) - offsetScaleY;
            }
            setState(() {});
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text("My App"),
            ),
            body: Stack(
              children: [
                CustomPaint(
                  painter: MyCustomPainter(paintObject),
                ),
              ],
            ),
          ),
        ));
  }

  void printInfo() {
    print("======= pointer info list====");
    pointerInfo.forEach((element) {
      print(element.xDown.toString() + ", " + element.yDown.toString());
    });
  }
}
