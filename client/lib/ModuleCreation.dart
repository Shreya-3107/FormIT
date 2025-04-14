import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:trial/DashBoard.dart';  // Import DashBoard

class ModuleCreation extends StatefulWidget {
  const ModuleCreation({Key? key}) : super(key: key);

  @override
  _ModuleCreationState createState() => _ModuleCreationState();
}

class _ModuleCreationState extends State<ModuleCreation> {
  List<bool> isChecked = List.generate(7, (index) => false);
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade50, Colors.indigo.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Stack(
              children: [
                GlassContainer(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(
                            "Choose Your Modules",
                            style: TextStyle(
                              fontSize: 28,
                              fontFamily: 'Pixel',
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.black),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Column(
                              children: List.generate(7, (index) {
                                return Column(
                                  children: [
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: isChecked[index],
                                          onChanged: (bool? value) {
                                            setState(() {
                                              isChecked[index] = value!;
                                            });
                                          },
                                          activeColor: Colors.indigo.shade300,
                                        ),
                                        const SizedBox(width: 10),
                                        Text("AI in generation please wait... ${index + 1}"),
                                      ],
                                    ),
                                    Divider(color: Colors.black),
                                  ],
                                );
                              }),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => DashBoard()),
                        );
                      },
                      onTapDown: (_) {
                        setState(() {
                          _scale = 0.9;
                        });
                      },
                      onTapUp: (_) {
                        setState(() {
                          _scale = 1.0;
                        });
                      },
                      onTapCancel: () {
                        setState(() {
                          _scale = 1.0;
                        });
                      },
                      child: Transform.scale(
                        scale: _scale,
                        child: Container(
                          width: 300,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.indigo.shade300, Colors.indigo.shade100],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Done',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: CustomPaint(
                    size: Size(MediaQuery.of(context).size.width, 50),
                    painter: SpiralPainter(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GlassContainer extends StatelessWidget {
  final Widget child;

  const GlassContainer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade300, Colors.indigo.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: Colors.white.withAlpha(100),
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: child,
        ),
      ),
    );
  }
}

class SpiralPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    double spacing = 30.0;
    double radius = 15.0;
    double startX = spacing / 2;

    Path path = Path();
    for (double x = startX; x < size.width; x += spacing) {
      path.moveTo(x, 0);
      path.quadraticBezierTo(x + radius / 2, -radius, x + radius, 0);
      path.quadraticBezierTo(x + 1.5 * radius, radius, x + 2 * radius, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


