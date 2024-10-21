import 'package:animation_playground_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class SimpleParticleSystem extends StatefulWidget {
  const SimpleParticleSystem({super.key});

  @override
  State<SimpleParticleSystem> createState() => _SimpleParticleSystemState();
}

class _SimpleParticleSystemState extends State<SimpleParticleSystem>
    with SingleTickerProviderStateMixin {
  late List<SimpleParticle> particles;
  late List<SimpleParticle> particlesToRemove;
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    particles = List.generate(1, (index) => SimpleParticle());
    particlesToRemove = List.empty(growable: true);

    _ticker = createTicker((elapsed) {
      particles.add(SimpleParticle());
      for (var particle in particlesToRemove) {
        particles.remove(particle);
      }
      setState(() {});
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Particle System'),
      ),
      backgroundColor: Colors.black,
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: CustomPaint(
          painter: ParticlePainter(
            particles: particles,
            particlesToRemove: particlesToRemove,
          ),
        ),
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final List<SimpleParticle> particles;
  final List<SimpleParticle> particlesToRemove;

  const ParticlePainter({
    required this.particles,
    required this.particlesToRemove,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.setPosition(
        particle.x * size.width,
        particle.y * size.height,
      );
      particle.update();
      var paint = Paint()
        ..color = Color.fromARGB(particle.opacity, 255, 255, 255)
        ..strokeWidth = 3.0;
      canvas.drawCircle(
        Offset(particle.x, particle.y),
        13,
        paint,
      );
      if (particle.finished()) particlesToRemove.add(particle);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SimpleParticle {
  double x = 0.5;
  double y = 0.9;
  double vx = doubleInRange(-1, 1);
  double vy = doubleInRange(-5, -1);
  int opacity = 255;

  SimpleParticle();

  void setPosition(double xPos, double yPos) {
    if (x < 1 && y < 1) {
      x = xPos;
      y = yPos;
    }
  }

  void update() {
    x += vx;
    y += vy;
    if (opacity > 0) {
      opacity -= 3;
    }
  }

  bool finished() {
    return opacity <= 0;
  }
}
