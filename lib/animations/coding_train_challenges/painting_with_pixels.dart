import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart' hide Image;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;

class PaintingWithPixels extends StatelessWidget {
  const PaintingWithPixels({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return PaintingWithPixelsCanvas(
      screenSize: size,
    );
  }
}

class PaintingWithPixelsCanvas extends StatefulWidget {
  final Size screenSize;

  const PaintingWithPixelsCanvas({
    super.key,
    required this.screenSize,
  });

  @override
  State<PaintingWithPixelsCanvas> createState() =>
      _PaintingWithPixelsCanvasState();
}

class _PaintingWithPixelsCanvasState extends State<PaintingWithPixelsCanvas>
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
        for (int i = 1; i < 100; i++) {
          randomizePoints();
        }
      }
      setState(() {});
    });
    _ticker.start();
  }

  void loadImage() async {
    var data = await rootBundle.load('assets/images/i-spy.jpeg');
    final buffer = data.buffer;
    var bytes = buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    image = await decodeImageFromList(bytes);
    imagePixels = img.decodeJpg(bytes)!;
    // TODO: height cap
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

    Offset offset = Offset(x.toDouble(), y.toDouble());
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
      appBar: AppBar(title: const Text('Painting With Pixels')),
      backgroundColor: Colors.white,
      body: _loading
          ? const SizedBox.shrink()
          : Center(
              child: CustomPaint(
                painter: _PixelPainter(
                  // image: image,
                  imagePixels: imagePixels,
                  offsets: offsets,
                ),
                child: SizedBox(
                  height: widget.screenSize.height,
                  width: widget.screenSize.width,
                ),
              ),
            ),
    );
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
        3,
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
