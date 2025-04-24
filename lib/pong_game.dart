import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class PongGame extends StatefulWidget {
  const PongGame({super.key});

  @override
  State<PongGame> createState() => _PongGameState();
}

class _PongGameState extends State<PongGame>
    with SingleTickerProviderStateMixin {
  static const double _platformSpacing = 30;
  static const double _platformWidth = 100;
  static const double _platformHeight = 10;
  static const double _puckSize = 20;
  static const double _puckSpeed = 3;

  bool _initialized = false;
  double _screenWidth = -1;
  double _screenHeight = -1;
  late Ticker _ticker;
  late _Rectangle _player1;
  late _Rectangle _player2;
  late _Rectangle _puck;
  double _puckDx = 1;
  double _puckDy = 1;

  void _initialize(BuildContext context) {
    _initialized = true;
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height - kToolbarHeight;
    _player1 = _Rectangle(
        (_screenWidth - _platformWidth) / 2,
        _platformSpacing,
        _platformWidth, _platformHeight
    );
    _player2 = _Rectangle(
        (_screenWidth - _platformWidth) / 2,
        _screenHeight.toInt() - _platformSpacing - _platformHeight,
        _platformWidth, _platformHeight
    );
    _puck = _Rectangle(
        ((_screenWidth - _puckSize) / 2).roundToDouble(),
        ((_screenHeight - _puckSize) / 2).roundToDouble(),
        _puckSize, _puckSize
    );
  }

  void _onClick(double x, double y) {
    x = max(x, _platformWidth / 2);
    x = min(x, _screenWidth - _platformWidth / 2);
    x -= _platformWidth / 2;

    if (y < _screenHeight / 2) {
      _player1.left += (x - _player1.left) / 2;
    }
    else {
      _player2.left += (x - _player2.left) / 2;
    }
    setState(() {});
  }

  void _movePuck() {
    for (int i = 0; i < _puckSpeed; i++) {
      _puck.left += _puckDx;
      _puck.top += _puckDy;

      bool outOfBoundsX = _puck.left <= 0 || _puck.right >= _screenWidth;
      bool outOfBoundsY = _puck.top <= 0 || _puck.bottom >= _screenHeight;
      bool player1FrontCollide =
          _puck.top == _player1.bottom &&
          _puck.right > _player1.left && _puck.left < _player1.right;
      bool player1SideCollide =
          (_puck.right == _player1.left.roundToDouble() ||
              _puck.left == _player1.right.roundToDouble()) &&
          _puck.top < _player1.bottom && _puck.bottom > _player1.top;
      bool player2FrontCollide =
          _puck.bottom == _player2.top &&
          _puck.right > _player2.left && _puck.left < _player2.right;
      bool player2SideCollide =
          (_puck.right == _player2.left.roundToDouble() ||
              _puck.left == _player2.right.roundToDouble()) &&
          _puck.top < _player2.bottom && _puck.bottom > _player2.top;

      if (outOfBoundsX || player1SideCollide || player2SideCollide) {
        _puckDx *= -1;
      }
      if (outOfBoundsY || player1FrontCollide || player2FrontCollide ||
          player1SideCollide || player2SideCollide) {
        _puckDy *= -1;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((Duration elapsed) => setState(() => _movePuck()));
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.stop();
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) _initialize(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Pong'),
      ),
      body: Listener(
        onPointerDown: (PointerDownEvent event) =>
            _onClick(event.localPosition.dx, event.localPosition.dy),
        child: Stack(
          children: [
            Container(
              color: Colors.transparent,
              width: double.infinity,
              height: double.infinity,
            ),
            CustomPaint(
              size: Size(
                _screenWidth, 10
              ),
              painter: _DottedLinePainter(0, _screenHeight / 2, 20, 10),
            ),
            Positioned(
              left: 10,
              top: _screenHeight / 2 - 60,
              child: Text(
                _player1.score.toString(),
                style: TextStyle(
                  fontSize: 48,
                ),
              ),
            ),
            Positioned(
              left: 10,
              top: _screenHeight / 2,
              child: Text(
                _player2.score.toString(),
                style: TextStyle(
                  fontSize: 48,
                ),
              ),
            ),
            Positioned(
              left: _puck.left,
              top: _puck.top,
              child: Container(
                width: _puck.width,
                height: _puck.height,
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.rectangle,
                ),
              ),
            ),
            Positioned(
              left: _player1.left,
              top: _player1.top,
              child: Container(
                width: _player1.width,
                height: _player1.height,
                color: Colors.black,
              ),
            ),
            Positioned(
              left: _player2.left,
              top: _player2.top,
              child: Container(
                width: _player2.width,
                height: _player2.height,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Rectangle {
  double score = 0;
  double left;
  double top;
  final double width;
  final double height;
  _Rectangle(this.left, this.top, this.width, this.height);

  double get right => left + width;
  double get bottom => top + height;
}

class _DottedLinePainter extends CustomPainter {
  final double x;
  final double y;
  final double dashWidth;
  final double dashSpace;
  _DottedLinePainter(this.x, this.y, this.dashWidth, this.dashSpace);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 10;

    double startX = x;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, y + size.height / 2),
        Offset(startX + dashWidth, y + size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}