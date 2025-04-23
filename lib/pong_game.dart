import 'dart:async';
import 'package:flutter/material.dart';

class PongGame extends StatefulWidget {
  const PongGame({super.key});

  @override
  State<PongGame> createState() => _PongGameState();
}

class _PongGameState extends State<PongGame> {
  static const double _platformWidth = 100;
  static const double _platformHeight = 10;
  static const double _puckSize = 20;

  double _screenWidth = -1;
  double _screenHeight = -1;
  double _player1X = -1;
  double _player2X = -1;
  double _puckX = 10;
  double _puckY = 10;

  late Timer timer;

  void _onClick(double x, double y) {
    x -= _platformWidth / 2;
    if (y < _screenHeight / 2) {
      _player1X += (x - _player1X) / 2;
    }
    else {
      _player2X += (x - _player2X) / 2;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(milliseconds: 16), (timer) {
      setState() {
        _puckX++;
        _puckY++;
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_screenWidth == -1) {
      _screenWidth = MediaQuery.of(context).size.width;
      _player1X = _player2X = _screenWidth / 2;
    }
    if (_screenHeight == -1) {
      _screenHeight = MediaQuery.of(context).size.height - kToolbarHeight;
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
              left: _puckX,
              top: _puckY,
              child: Container(
                width: _puckSize,
                height: _puckSize,
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.rectangle,
                ),
              ),
            ),
            Positioned(
              left: _player1X,
              top: 30,
              child: Container(
                width: _platformWidth,
                height: _platformHeight,
                color: Colors.black,
              ),
            ),
            Positioned(
              left: _player2X,
              top: _screenHeight - 40,
              child: Container(
                width: _platformWidth,
                height: _platformHeight,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}