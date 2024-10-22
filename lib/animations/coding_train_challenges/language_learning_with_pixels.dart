import 'dart:core';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart' hide Image;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;

class LanguageLearningWithPixels extends StatelessWidget {
  const LanguageLearningWithPixels({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // print(size.aspectRatio);

    return size.aspectRatio.abs() <= 0.75
        ? LanguageLearningWithPixelsCanvas(
            screenSize: size,
          )
        : Scaffold(
            appBar: AppBar(title: const Text('Painting With Pixels (Error)')),
            backgroundColor: Colors.white,
            body: const Center(
              child: Text(
                'Screen resolution won\'t work.',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          );
  }
}

class LanguageLearningWithPixelsCanvas extends StatefulWidget {
  final Size screenSize;

  const LanguageLearningWithPixelsCanvas({
    super.key,
    required this.screenSize,
  });

  @override
  State<LanguageLearningWithPixelsCanvas> createState() =>
      _LanguageLearningWithPixelsCanvasState();
}

class _LanguageLearningWithPixelsCanvasState
    extends State<LanguageLearningWithPixelsCanvas>
    with SingleTickerProviderStateMixin {
  late ui.Image image;
  late img.Image imagePixels;
  late final Ticker _ticker;

  bool _loading = true;
  List<Offset> offsets = List.empty(growable: true);
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();

    loadImage();
    _ticker = createTicker((elapsed) {
      if (!_loading) {
        // "speed"
        for (int i = 1; i < 10; i++) {
          // 100
          randomizePoints();
        }
      }
      setState(() {});
    });
    _ticker.start();
  }

  void loadImage() async {
    var data = await rootBundle.load('assets/images/romanji-a.jpg');
    final buffer = data.buffer;
    var bytes = buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    image = await decodeImageFromList(bytes);
    imagePixels = img.decodeJpg(bytes)!;
    imagePixels = img.copyResize(
      imagePixels,
      width: widget.screenSize.width.floor(),
    );

    _loading = false;
    randomizePoints();
    setState(() {});
  }

  void randomizePoints() {
    int x = _random.nextInt(imagePixels.width);
    int y = _random.nextInt(imagePixels.height);

    // print(widget.screenSize.height); // 964
    // print(imagePixels.height); // 663
    // var positionBottom = widget.screenSize.height - imagePixels.height;
    // print(positionBottom); // 301

    Offset offset = Offset(x.toDouble(), (y).toDouble());

    if (!offsets.contains(offset)) {
      offsets.add(offset);
    } else {
      randomizePoints();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      backgroundColor: Colors.white,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              color: Colors.green,
              width: widget.screenSize.width,
              height: widget.screenSize.height - appBar().preferredSize.height,
              child: Stack(
                children: [
                  Container(
                    color: Colors.red,
                    height: widget.screenSize.height -
                        imagePixels.height -
                        appBar().preferredSize.height -
                        60 - // for the actions / buttons
                        10, // avoids the circles being painted via diameter
                    width: widget.screenSize.width,
                    child: const Center(
                      child: Text('Instructions...'),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      top: widget.screenSize.height -
                          imagePixels.height -
                          appBar().preferredSize.height -
                          60 -
                          0,
                    ),
                    // color: Colors.yellow,
                    child: CustomPaint(
                      painter: _PixelPainter(
                        // image: image,
                        imagePixels: imagePixels,
                        offsets: offsets,
                      ),
                      child: SizedBox(
                        // height: widget.screenSize.height,
                        height: imagePixels.height.toDouble(),
                        // width: widget.screenSize.width,
                        width: imagePixels.width.toDouble(),
                      ),
                    ),
                  ),
                  Positioned(
                    top: widget.screenSize.height -
                        appBar().preferredSize.height -
                        60, // Actions/ buttons size
                    child: Container(
                      color: Colors.blue,
                      height: 60,
                      width: widget.screenSize.width,
                      child: const Center(
                        child: Text('Actions / Buttons'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      // : Padding(
      //     padding: EdgeInsets.only(
      //       top: widget.screenSize.height -
      //           imagePixels.height -
      //           appBar().preferredSize.height,
      //     ),
      //     child: CustomPaint(
      //       painter: _PixelPainter(
      //         // image: image,
      //         imagePixels: imagePixels,
      //         offsets: offsets,
      //       ),
      //       child: SizedBox(
      //         // height: widget.screenSize.height,
      //         height: imagePixels.height.toDouble(),
      //         // width: widget.screenSize.width,
      //         width: imagePixels.width.toDouble(),
      //       ),
      //     ),
      //   ),
    );
  }

  AppBar appBar() {
    return AppBar(title: const Text('Painting With Pixels'));
  }
}

class _PixelPainter extends CustomPainter {
  // final ui.Image image;
  final img.Image imagePixels;
  final List<Offset> offsets;

  _PixelPainter({
    // required this.image,
    required this.imagePixels,
    required this.offsets,
  });

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    for (Offset offset in offsets) {
      img.Pixel pixel = imagePixels.getPixelSafe(
        offset.dx.toInt(),
        offset.dy.toInt(),
      );
      List colorList = pixel.toList();
      canvas.drawCircle(
        offset,
        5, // 3
        Paint()
          ..color = Color.fromARGB(
            255,
            colorList[0],
            colorList[1],
            colorList[2],
          ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
