import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snakes/blank_pixel.dart';
import 'package:snakes/food_pixel.dart';
import 'package:snakes/high_score_tile.dart';
import 'package:snakes/snake_pixel.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}
enum snake_Direction{UP,DOWN,LEFT,RIGHT}

class _HomePageState extends State<HomePage> {
  //grid dimensions
  int rowSize = 10, totalNumberOfSquares = 100;

  //user score
  int currentScore = 0;

  bool gameHasStarted = false;
  final _nameController =new  TextEditingController();

  //snake position
  List<int> snakePos =[0,1,2];

  //food position
  int foodPosition = 55;

  //Snake direction is initially to the right
  var currentDirection = snake_Direction.RIGHT;

  //highscore list
  List<String> highscore_DocIds = [];
  late final Future? letsGetDocIds;

  @override
  void initState(){
    letsGetDocIds = getDocId();
    super.initState();
  }
  Future getDocId()async{
    await FirebaseFirestore.instance
        .collection("highscores")
        .orderBy("score",descending: true)
        .limit(10)
        .get()
        .then((value) => value.docs.forEach((element) {
          highscore_DocIds.add(element.reference.id);
    }));
  }

  //start the game!
  void startGame(){
    gameHasStarted = true;
    Timer.periodic(const Duration(milliseconds: 200),(timer){
      setState((){
        //keep snake moving
        moveSnake();
        if (gameOver()){
          timer.cancel();
          showDialog(
            barrierDismissible: false,
              context: context,
              builder: (context){
                return AlertDialog(
                  title: const Text('Game Over'),
                  content:Column(
                    children: [
                      Text('Current Score: '+currentScore.toString()),
                       TextField(
                        controller: _nameController,
                        decoration:const InputDecoration(
                          hintText: "Enter Name",
                        ) ,
                      )
                    ],
                  ),
                  actions: [
                    MaterialButton(
                      onPressed: (){
                        submitScore();
                        Navigator.pop(context);
                        newGame();
                      },
                    child: const Text("Submit Score"),
                      color: Colors.red,
                    )
                  ],
                );
              }
          );
        }
      });
    }
    );
  }

  void eatFood(){
    currentScore+=1;
    while(snakePos.contains(foodPosition)){
     foodPosition = Random().nextInt(totalNumberOfSquares);
    }
  }
  void moveSnake(){
    switch(currentDirection){

      case snake_Direction.RIGHT:
        {
          //add a new head
          if (snakePos.last % rowSize == 9){
            snakePos.add(snakePos.last +1 - rowSize);
          }else
            {
              snakePos.add(snakePos.last +1);
            }

        }
        break;
      case snake_Direction.LEFT:
        {
          //add a new head
          if (snakePos.last % rowSize == 0){
            snakePos.add(snakePos.last -1 + rowSize);
          }else
          {
            snakePos.add(snakePos.last -1);
          }
        }
        break;
      case snake_Direction.UP:
        {
          //add a new head
          if (snakePos.last < rowSize){
           snakePos.add(snakePos.last - rowSize + totalNumberOfSquares);
          }else{
            snakePos.add(snakePos.last - rowSize);
          }
        }
        break;
      case snake_Direction.DOWN:
        {
          //add a new head
          if (snakePos.last + rowSize > totalNumberOfSquares){
            snakePos.add(snakePos.last + rowSize - totalNumberOfSquares);
          }else{
            snakePos.add(snakePos.last + rowSize);
          }

        }
        break;
      default:
    }
    if (snakePos.last == foodPosition){
      eatFood();
    }else{
      snakePos.removeAt(0);
    }
  }

  //game over
  bool gameOver(){
    List <int> bodySnake = snakePos.sublist(0,snakePos.length-1);
    if (bodySnake.contains(snakePos.last)){
      return true;
    }
    return false;
  }
  void submitScore(){
    var database = FirebaseFirestore.instance;
    database.collection('highscores').add({
      "name": _nameController.text,
      "score": currentScore,
    });
  }
  Future newGame()async{
    highscore_DocIds = [];
    await getDocId();
    setState((){
      snakePos = [0,1,2];
      foodPosition = 55;
      currentDirection = snake_Direction.RIGHT;
      gameHasStarted = false;
      currentScore = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.black,
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: (event){
          if (event.isKeyPressed(LogicalKeyboardKey.arrowDown) &&
              currentDirection != snake_Direction.UP ){
            currentDirection  =snake_Direction.DOWN;
          }else if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)&&
              currentDirection != snake_Direction.DOWN ){
            currentDirection = snake_Direction.UP;
          }else if(event.isKeyPressed(LogicalKeyboardKey.arrowLeft) &&
          currentDirection != snake_Direction.RIGHT ){
            currentDirection = snake_Direction.LEFT;
          }else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight) &&
              currentDirection != snake_Direction.RIGHT ){
            currentDirection = snake_Direction.RIGHT;
          }
        },
        child: Center(
          child: SizedBox(
            width: screenWidth > 428 ? 428 :screenWidth,
            child: Column(
              children: [
                Expanded(
                    child: Row(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(currentScore.toString(),
                              style:const TextStyle(fontSize: 35) ,
                            ),
                            const Text("CURRENT SCORE"),
                          ],
                        ),
                        const SizedBox(width:100),
                        Flexible(
                          child: gameHasStarted
                              ? Container()
                              : FutureBuilder(
                              future: letsGetDocIds,
                              builder:(context,snapshot){
                                return Container(
                                  height: 98,
                                  child: ListView.builder(
                                      itemCount: highscore_DocIds.length,
                                      itemBuilder: ((context,index){
                                        return HighScoreTile(documentId: highscore_DocIds[index]);
                                      })),
                                );
                              }),
                        )
                      ],
                    )),
                Expanded(
                    flex: 4,
                    child: GestureDetector(
                      onVerticalDragUpdate: (details){
                        if(details.delta.dy > 0 && currentDirection!= snake_Direction.UP) {
                          currentDirection = snake_Direction.DOWN;
                        }else if (details.delta.dy < 0 && currentDirection != snake_Direction.DOWN){
                          currentDirection = snake_Direction.UP;
                        }
                      },
                      onHorizontalDragUpdate: (details){
                        if(details.delta.dx > 0 && currentDirection != snake_Direction.LEFT) {
                          currentDirection = snake_Direction.RIGHT;
                        }else if (details.delta.dx < 0 && currentDirection != snake_Direction.RIGHT){
                          currentDirection = snake_Direction.LEFT;
                        }
                      },
                      child: GridView.builder(
                        itemCount: totalNumberOfSquares,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: rowSize,
                          ),
                          itemBuilder: (context,index){
                          if (snakePos.contains(index)){
                            return const SnakePixel();
                          }else if(foodPosition == index){
                            return const FoodPixel();
                          }else {
                            return const BlankPixel();
                          }
                          }),
                    )
                ),
                Expanded(
                    child: Container(
                      child: Center(
                        child: MaterialButton(
                          onPressed:gameHasStarted? (){} : startGame,
                          child: const Text("PLAY"),
                          color: gameHasStarted ? Colors.grey : Colors.red,
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
