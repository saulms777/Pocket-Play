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

  double _screenWidth = -1;
  double _screenHeight = -1;

  late _Rectangle _player1;
  late _Rectangle _player2;
  late _Rectangle _puck;

  late Ticker _ticker;
  double _puckDx = 1;
  double _puckDy = 1;

  void _onClick(double x, double y) {
    x -= _platformWidth / 2;
    if (y < _screenHeight / 2) {
      _player1.x += (x - _player1.x) / 2;
    }
    else {
      _player2.x += (x - _player2.x) / 2;
    }
    setState(() {});
  }

  void _movePuck() {
    for (int i = 0; i < _puckSpeed; i++) {
      _puck.x += _puckDx;
      _puck.y += _puckDy;

      bool outOfBoundsX = _puck.left() <= 0 || _puck.right() >= _screenWidth;
      bool outOfBoundsY = _puck.top() <= 0 || _puck.bottom() >= _screenHeight;
      bool player1FrontCollide =
          _puck.top() == _player1.bottom() &&
          _puck.right() > _player1.left() && _puck.left() < _player1.right();
      bool player1SideCollide =
          (_puck.right() == _player1.left().roundToDouble() ||
              _puck.left() == _player1.right().roundToDouble()) &&
          _puck.top() < _player1.bottom() && _puck.bottom() > _player1.top();
      bool player2FrontCollide =
          _puck.bottom() == _player2.top() &&
          _puck.right() > _player2.left() && _puck.left() < _player2.right();
      bool player2SideCollide =
          (_puck.right() == _player2.left().roundToDouble() ||
              _puck.left() == _player2.right().roundToDouble()) &&
          _puck.top() < _player2.bottom() && _puck.bottom() > _player2.top();

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
    if (_screenWidth == -1) {
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
            Positioned(
              left: _puck.x,
              top: _puck.y,
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
              left: _player1.x,
              top: _player1.y,
              child: Container(
                width: _player1.width,
                height: _player1.height,
                color: Colors.black,
              ),
            ),
            Positioned(
              left: _player2.x,
              top: _player2.y,
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
  double x;
  double y;
  final double width;
  final double height;
  _Rectangle(this.x, this.y, this.width, this.height);

  double left() => x;
  double right() => x + width;
  double top() => y;
  double bottom() => y + height;
}