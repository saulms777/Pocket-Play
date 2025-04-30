import 'dart:async';
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
  static const double _puckSpeed = 5;
  static final Random _random = Random();

  bool _initialized = false;
  late double _screenWidth;
  late double _screenHeight;

  late Timer _startTimer;
  late int _countdown;
  late String _countdownMsg;
  late bool _finished = false;

  late Ticker _ticker;
  late _Player _player1;
  late _Player _player2;
  late _Player _puck;
  late double _puckDx;
  late double _puckDy;

  void _initialize(BuildContext context) {
    _initialized = true;
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;

    _countdown = 3;
    _countdownMsg = '3';

    _player1 = _Player(
        (_screenWidth - _platformWidth) / 2,
        _platformSpacing,
        _platformWidth, _platformHeight
    );
    _player2 = _Player(
        (_screenWidth - _platformWidth) / 2,
        _screenHeight.toInt() - _platformSpacing - _platformHeight,
        _platformWidth, _platformHeight
    );
    _puck = _Player(
        ((_screenWidth - _puckSize) / 2).roundToDouble(),
        ((_screenHeight - _puckSize) / 2).roundToDouble(),
        _puckSize, _puckSize
    );
    _puckDx = _random.nextBool() ? 1 : -1;
    _puckDy = _random.nextBool() ? 1 : -1;
  }

  void _onClick(double x, double y) {
    if (!_ticker.isActive) return;
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

  void _updateGame() {
    for (int i = 0; i < _puckSpeed; i++) {
      // Move puck
      _puck.left += _puckDx;
      _puck.top += _puckDy;

      // Check for puck collision
      bool outOfBoundsX = _puck.left <= 0 || _puck.right >= _screenWidth;
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
      if (player1FrontCollide || player2FrontCollide ||
          player1SideCollide || player2SideCollide) {
        _puckDy *= -1;
      }

      // Check for score
      if (_puck.bottom >= _screenHeight) {
        _player1.score++;
        _puck = _Player(
            ((_screenWidth - _puckSize) / 2).roundToDouble(),
            ((_screenHeight - _puckSize) / 2).roundToDouble(),
            _puckSize, _puckSize
        );
      }
      if (_puck.top <= 0) {
        _player2.score++;
        _puck = _Player(
            ((_screenWidth - _puckSize) / 2).roundToDouble(),
            ((_screenHeight - _puckSize) / 2).roundToDouble(),
            _puckSize, _puckSize
        );
      }

      // Check for win
      if (_player1.score == 10) {
        _ticker.stop();
        _finished = true;
        _puck.remove();
        _player1.message = 'You Win!';
        _player2.message = 'You Lose!';
      }
      else if (_player2.score == 10) {
        _ticker.stop();
        _finished = true;
        _puck.remove();
        _player1.message = 'You Lose!';
        _player2.message = 'You Win!';
      }
    }
  }

  void _playAgain() {
    setState(() {
      _initialized = false;
      initState();
      _finished = false;
    });
  }

  @override
  void initState() {
    if (!_finished) {
      super.initState();
      _ticker = createTicker((_) => setState(() => _updateGame()));
    }
    _startTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_countdown == 0) {
        timer.cancel();
        _ticker.start();
        _countdownMsg = '';
      }
      else {
        setState(() {
          _countdown--;
          _countdownMsg = _countdown == 0 ? 'Play!' : _countdown.toString();
        });
      }
    });
  }

  @override
  void dispose() {
    _startTimer.cancel();
    _ticker.stop();
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) _initialize(context);
    return Scaffold(
      body: Listener(
        onPointerDown: (PointerDownEvent event) =>
            _onClick(event.localPosition.dx, event.localPosition.dy),
        child: Stack(
          children: [
            // Background
            Container(
              color: Colors.transparent,
              width: double.infinity,
              height: double.infinity,
            ),

            // Dotted line
            CustomPaint(
              size: Size(
                _screenWidth, 10
              ),
              painter: _DottedLinePainter(0, _screenHeight / 2 - 5, 20, 10),
            ),
            
            // Countdown
            Container(
              alignment: Alignment.bottomRight,
              padding: EdgeInsets.only(bottom: 10),
              child: RotatedBox(
                quarterTurns: 1,
                child: Text(
                  _countdownMsg,
                  style: TextStyle(fontSize: 48),
                ),
              ),
            ),

            // Back button
            Positioned(
              right: 0,
              top: 0,
              child: RotatedBox(
                quarterTurns: 1,
                child: TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: 30,
                  ),
                  label: Text(
                    'Back',
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),

            // Play again
            Container(
              alignment: Alignment.bottomRight,
              padding: EdgeInsets.only(bottom: 10),
              child: RotatedBox(
                quarterTurns: 1,
                child: TextButton(
                  onPressed: _finished ? _playAgain : null,
                  child: Text(
                    _finished ? 'Play Again' : '',
                    style: TextStyle(
                      fontSize: 36,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),

            // Player 1 score
            Positioned(
              right: 0,
              bottom: _screenHeight / 2 + 20,
              child: RotatedBox(
                quarterTurns: 1,
                child: Text(
                  _player1.score.toString(),
                  style: TextStyle(fontSize: 48),
                ),
              ),
            ),

            // Player 2 score
            Positioned(
              right: 0,
              top: _screenHeight / 2 + 20,
              child: RotatedBox(
                quarterTurns: 1,
                child: Text(
                  _player2.score.toString(),
                  style: TextStyle(fontSize: 48),
                ),
              ),
            ),

            // Puck
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

            // Player 1 paddle
            Positioned(
              left: _player1.left,
              top: _player1.top,
              child: Container(
                width: _player1.width,
                height: _player1.height,
                color: Colors.black,
              ),
            ),

            // Player 2 paddle
            Positioned(
              left: _player2.left,
              top: _player2.top,
              child: Container(
                width: _player2.width,
                height: _player2.height,
                color: Colors.black,
              ),
            ),

            // Player 1 end screen
            Positioned(
              width: _screenWidth,
              height: _screenHeight / 2,
              child: Container(
                alignment: Alignment.center,
                child: RotatedBox(
                  quarterTurns: 1,
                  child: Text(
                    _player1.message,
                    style: TextStyle(fontSize: 36),
                  ),
                ),
              ),
            ),

            // Player 2 end screen
            Positioned(
              top: _screenHeight / 2,
              width: _screenWidth,
              height: _screenHeight / 2,
              child: Container(
                alignment: Alignment.center,
                child: RotatedBox(
                  quarterTurns: 1,
                  child: Text(
                    _player2.message,
                    style: TextStyle(fontSize: 36),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Player {
  double score = 0;
  String message = '';
  double left;
  double top;
  final double width;
  final double height;
  _Player(this.left, this.top, this.width, this.height);

  double get right => left + width;
  double get bottom => top + height;
  void remove() => left = top = double.infinity;
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