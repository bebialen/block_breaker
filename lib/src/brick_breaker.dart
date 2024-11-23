




import 'dart:async';
import 'dart:math' as math;

import 'package:bounce_game/src/components/components.dart';
import 'package:bounce_game/src/config.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


enum PlayState{welcome , playing , gameOver, won,  }

class BrickBreaker extends FlameGame with HasCollisionDetection,KeyboardEvents,TapDetector{
  //collision detection helps to find when two objects come together


  BrickBreaker():super(
    camera: CameraComponent.withFixedResolution(
      width: gameWidth,
      height: gameHeight
    ),
  );

  double get width => size.x;
  double get height => size.y;
  final rand = math.Random();
  final ValueNotifier<int> score = ValueNotifier(0);

  late PlayState _playState;
  PlayState get playState => _playState;

  set playState(PlayState playState){
    _playState = playState;
    switch (playState){

      case PlayState.welcome:
      case PlayState.gameOver:
      case PlayState.won:
           overlays.add(playState.name);
      case PlayState.playing:
           overlays.remove(PlayState.welcome.name);
           overlays.remove(PlayState.gameOver.name);
           overlays.remove(PlayState.won.name);
    }

  }


  @override
  FutureOr<void>onLoad()async{

    super.onLoad();
    camera.viewfinder.anchor = Anchor.topLeft;

    world.add(PlayArea());

    playState = PlayState.welcome;
  }

  void startGame(){
    if(playState == PlayState.playing) return;

    world.removeAll(world.children.query<Ball>());
     world.removeAll(world.children.query<Bat>());
    world.removeAll(world.children.query<Brick>());
    playState = PlayState.playing;
    score.value = 0;

    world.add(Ball(velocity: Vector2((rand.nextDouble()-0.5)*width, height*0.2).normalized()..scale(height/4), position: size/2, radius: ballRadius, difficultyModifier: difficultyModifier));

    world.add(Bat(cornerRadius:const Radius.circular(ballRadius/2), position: Vector2(width/2, height*0.95), size: Vector2(batWidth, batHeight)));
    debugMode = true;

    world.addAll([
      for(var i = 0 ; i<brickColors.length; i++)
       for(var j =1; j<=5; j++)
         Brick(position: Vector2(
          (i+0.5)* brickWidth+(i+1)* brickGutter,
          (j+2.0)* brickHeight + j * brickGutter
         ), color: brickColors[i])
    ]);
    // debugMode = true;
  }
  @override

  void onTap(){
    super.onTap();
    startGame();
  }


  @override
  KeyEventResult onKeyEvent(

    KeyEvent event , Set<LogicalKeyboardKey>keysPressed

  ){
    super.onKeyEvent(event, keysPressed);

    switch (event.logicalKey){

      case LogicalKeyboardKey.arrowLeft:
           world.children.query<Bat>().first.moveBy(-batStep);
      case LogicalKeyboardKey.arrowRight:
           world.children.query<Bat>().first.moveBy(batStep);
      case LogicalKeyboardKey.space:
      case LogicalKeyboardKey.enter:
           startGame();
  
    }

    return KeyEventResult.handled;
  }

@override
Color backgroundColor() => const Color(0xff238cf);
  //adding controls
}
