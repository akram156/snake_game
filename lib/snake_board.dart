import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

Set<Position> positions = {};
Counter counterNH = Counter();
Counter counterH = Counter();
IsOver isOver = IsOver();

class SnakeBoard extends StatefulWidget {
  const SnakeBoard({super.key});

  @override
  State<SnakeBoard> createState() => _SnakeBoardState();
}

class _SnakeBoardState extends State<SnakeBoard> {
  late Position healthyPos;
  late Position sickPos;
  late List<Position> unhealthyCels;
  late List<Position> obstacles;
  late List<Position> snake;
  late List<Widget> snakeColor;
  late String direction;
  late bool isGameStarted;
  Timer? gameTimer;
  @override
  void initState() {
    super.initState();
    direction = 'left';
    isGameStarted = false;
    healthyPos = generate_location();
    sickPos = generate_location();
    unhealthyCels = [generate_location()];
    obstacles = [generate_location(), generate_location(), generate_location()];
    snake = [
      Position(10, 9),
      Position(10, 10),
      Position(10, 11),
      Position(10, 12),
    ];
    snakeColor = [Snake_cell(), Snake_cell(), Snake_cell(), Snake_cell()];
  }

  void restart() {
    direction = 'left';
    isGameStarted = false;
    isOver.isOver = false;
    healthyPos = generate_location();
    unhealthyCels = [generate_location()];
    obstacles = [generate_location(), generate_location(), generate_location()];
    snake = [
      Position(10, 9),
      Position(10, 10),
      Position(10, 11),
      Position(10, 12),
    ];
    snakeColor = [Snake_cell(), Snake_cell(), Snake_cell(), Snake_cell()];
  }

  void startGame() {
    gameTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (isOver.isOver || !isGameStarted) {
        timer.cancel();
        return;
      }

      setState(() {
        print('out:$healthyPos');
        if (direction == 'left') {
          move_left(
            snakeColor,
            snake,
            unhealthyCels,
            obstacles,
            direction,
            healthyPos,
            sickPos,
          );
        } else if (direction == 'right') {
          move_right(
            snakeColor,
            snake,
            unhealthyCels,
            obstacles,
            direction,
            healthyPos,
            sickPos,
          );
        } else if (direction == 'up') {
          move_up(
            snakeColor,
            snake,
            unhealthyCels,
            obstacles,
            direction,
            healthyPos,
            sickPos,
          );
        } else if (direction == 'down') {
          move_down(
            snakeColor,
            snake,
            unhealthyCels,
            obstacles,
            direction,
            healthyPos,
            sickPos,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // var (Rh, Ch) = healthyPos;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
              child: Column(
                spacing: 1,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < 20; i++)
                    Row(
                      spacing: 1,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int j = 0; j < 20; j++)
                          if (i == healthyPos.row && j == healthyPos.column)
                            Healthy_cell()
                          else if (i == sickPos.row && j == sickPos.column)
                            Sick_cell()
                          else if (unhealthyCels.contains(Position(i, j)))
                            NonHealthy_cell()
                          else if (obstacles.contains(Position(i, j)))
                            Obstacle_cell()
                          else if (snake.contains(Position(i, j)))
                            snakeColor[snake.indexWhere(
                              (item) => item == Position(i, j),
                            )]
                          else
                            Grid_cell(),
                      ],
                    ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Container(
              child: Column(
                children: [
                  IconButton(
                    onPressed: () {
                      if (isGameStarted && !isOver.isOver) {
                        direction = move_up(
                          snakeColor,
                          snake,
                          unhealthyCels,
                          obstacles,
                          direction,
                          healthyPos,
                          sickPos,
                        );
                        setState(() {});
                      }
                    },
                    icon: Icon(Icons.arrow_upward),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (isGameStarted && !isOver.isOver) {
                            direction = move_left(
                              snakeColor,
                              snake,
                              unhealthyCels,
                              obstacles,
                              direction,
                              healthyPos,
                              sickPos,
                            );
                            setState(() {});
                          }
                        },
                        icon: Icon(Icons.arrow_left),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            isGameStarted = !isGameStarted;
                          });
                          if (isGameStarted) startGame();
                        },
                        icon: isGameStarted
                            ? Icon(Icons.pause)
                            : Icon(Icons.play_circle_outline_sharp),
                      ),
                      IconButton(
                        onPressed: () {
                          if (isGameStarted && !isOver.isOver) {
                            direction = move_right(
                              snakeColor,
                              snake,
                              unhealthyCels,
                              obstacles,
                              direction,
                              healthyPos,
                              sickPos,
                            );
                            setState(() {});
                          }
                        },
                        icon: Icon(Icons.arrow_right),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      if (isGameStarted && !isOver.isOver) {
                        direction = move_down(
                          snakeColor,
                          snake,
                          unhealthyCels,
                          obstacles,
                          direction,
                          healthyPos,
                          sickPos,
                        );
                        setState(() {});
                      }
                    },
                    icon: Icon(Icons.arrow_downward),
                  ),
                ],
              ),
            ),
            Container(
              child: isOver.isOver
                  ? Text('THE GAME IS OVER:')
                  : Text('PLAYING ...'),
            ),
            isOver.isOver
                ? TextButton(
                    onPressed: () {
                      setState(() {
                        restart();
                      });
                    },
                    child: Text('RESTART'),
                  )
                : Text(''),
          ],
        ),
      ),
    );
  }
}

class cell extends StatelessWidget {
  final Color color;
  const cell({super.key, required this.color});
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      width: 10,
      decoration: BoxDecoration(color: color),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is cell && other.color == color;
  }

  @override
  int get hashCode => color.hashCode;
}

class Healthy_cell extends cell {
  const Healthy_cell({super.key}) : super(color: Colors.green);
}

class NonHealthy_cell extends cell {
  const NonHealthy_cell({super.key}) : super(color: Colors.red);
}

class Sick_cell extends cell {
  const Sick_cell({super.key}) : super(color: Colors.yellow);
}

class Obstacle_cell extends cell {
  const Obstacle_cell({super.key}) : super(color: Colors.black);
}

class Grid_cell extends cell {
  const Grid_cell({super.key}) : super(color: Colors.transparent);
}

class Snake_cell extends cell {
  const Snake_cell({super.key}) : super(color: Colors.blue);
}

Position generate_location() {
  final random = Random();
  int row = random.nextInt(20);
  int column = random.nextInt(20);
  do {
    row = random.nextInt(20);
    column = random.nextInt(20);
  } while (positions.contains(Position(row, column)));
  positions.add(Position(row, column));
  return Position(row, column);
}

String move_left(
  List<Widget> snakeColor,
  List<Position> snake,
  List<Position> unhealthyCels,
  List<Position> obstacles,
  String direction,
  Position healthyPos,
  Position sickPos,
) {
  if (direction != 'right') {
    var head = snake[0];
    if (head.column - 1 >= 0) {
      var newPosition = Position(head.row, head.column - 1);
      if (newPosition == healthyPos) {
        eatHealthy(snakeColor, snake, head, healthyPos);
        print('in:$healthyPos');
      } else if (unhealthyCels.contains(newPosition)) {
        eatUnHealthy(
          snakeColor,
          snake,
          unhealthyCels,
          obstacles,
          head,
          newPosition,
        );
      } else if (obstacles.contains(newPosition)) {
        hitObstacle(snakeColor);
      } else if (newPosition == sickPos) {
        eatSick(
          snakeColor,
          snake,
          unhealthyCels,
          obstacles,
          head,
          newPosition,
          sickPos,
        );
      } else if (snake.contains(newPosition)) {
        isOver.setIsOver();
      }
      snake.insert(0, newPosition);
      snake.removeLast();
      return "left";
    } else {
      isOver.setIsOver();
    }
  }
  return "right";
}

String move_right(
  List<Widget> snakeColor,
  List<Position> snake,
  List<Position> unhealthyCels,
  List<Position> obstacles,
  String direction,
  Position healthyPos,
  Position sickPos,
) {
  if (direction != 'left') {
    var head = snake[0];
    if (head.column + 1 < 20) {
      var newPosition = Position(head.row, head.column + 1);
      if (newPosition == healthyPos) {
        eatHealthy(snakeColor, snake, head, healthyPos);
        print('in:$healthyPos');
      } else if (unhealthyCels.contains(newPosition)) {
        eatUnHealthy(
          snakeColor,
          snake,
          unhealthyCels,
          obstacles,
          head,
          newPosition,
        );
      } else if (obstacles.contains(newPosition)) {
        hitObstacle(snakeColor);
      } else if (newPosition == sickPos) {
        eatSick(
          snakeColor,
          snake,
          unhealthyCels,
          obstacles,
          head,
          newPosition,
          sickPos,
        );
      } else if (snake.contains(newPosition)) {
        isOver.setIsOver();
      }
      snake.insert(0, newPosition);
      snake.removeLast();
      return "right";
    } else {
      isOver.setIsOver();
    }
  }
  return "left";
}

String move_up(
  List<Widget> snakeColor,
  List<Position> snake,
  List<Position> unhealthyCels,
  List<Position> obstacles,
  String direction,
  Position healthyPos,
  Position sickPos,
) {
  if (direction != 'down') {
    var head = snake[0];
    if (head.row - 1 >= 0) {
      var newPosition = Position(head.row - 1, head.column);
      if (newPosition == healthyPos) {
        eatHealthy(snakeColor, snake, head, healthyPos);
        print('in:$healthyPos');
      } else if (unhealthyCels.contains(newPosition)) {
        eatUnHealthy(
          snakeColor,
          snake,
          unhealthyCels,
          obstacles,
          head,
          newPosition,
        );
      } else if (obstacles.contains(newPosition)) {
        hitObstacle(snakeColor);
      } else if (newPosition == sickPos) {
        eatSick(
          snakeColor,
          snake,
          unhealthyCels,
          obstacles,
          head,
          newPosition,
          sickPos,
        );
      } else if (snake.contains(newPosition)) {
        isOver.setIsOver();
      }
      snake.insert(0, newPosition);
      snake.removeLast();
      return "up";
    } else {
      isOver.setIsOver();
    }
  }
  return "down";
}

String move_down(
  List<Widget> snakeColor,
  List<Position> snake,
  List<Position> unhealthyCels,
  List<Position> obstacles,
  String direction,
  Position healthyPos,
  Position sickPos,
) {
  if (direction != 'up') {
    var head = snake[0];
    if (head.row + 1 < 20) {
      var newPosition = Position(head.row + 1, head.column);
      if (newPosition == healthyPos) {
        eatHealthy(snakeColor, snake, head, healthyPos);
        print('in:$healthyPos');
      } else if (unhealthyCels.contains(newPosition)) {
        eatUnHealthy(
          snakeColor,
          snake,
          unhealthyCels,
          obstacles,
          head,
          newPosition,
        );
      } else if (obstacles.contains(newPosition)) {
        hitObstacle(snakeColor);
      } else if (newPosition == sickPos) {
        eatSick(
          snakeColor,
          snake,
          unhealthyCels,
          obstacles,
          head,
          newPosition,
          sickPos,
        );
      } else if (snake.contains(newPosition)) {
        isOver.setIsOver();
      }
      snake.insert(0, newPosition);
      snake.removeLast();
      return "down";
    } else {
      isOver.setIsOver();
    }
  }
  return "up";
}

class Position {
  int row;
  int column;

  Position(this.row, this.column);

  @override
  bool operator ==(Object other) =>
      other is Position && row == other.row && column == other.column;

  @override
  int get hashCode => Object.hash(row, column);

  @override
  String toString() {
    return "($row,$column)";
  }
}

class Counter {
  int counter = 0;
  void setToZero() {
    counter = 0;
  }

  void increment() {
    counter++;
  }
}

class IsOver {
  bool isOver = false;
  void setIsOver() {
    isOver = true;
  }
}

void eatHealthy(
  List<Widget> snakeColor,
  List<Position> snake,
  Position head,
  Position healthyPos,
) {
  counterNH.setToZero();
  counterH.counter++;
  if (counterH.counter == 3) {
    int index = snakeColor.indexWhere((item) => item == NonHealthy_cell());
    snakeColor.removeAt(index);
    snake.removeAt(index);
    counterH.setToZero();
  }
  var tail = snake[snake.length - 1];
  var beforeTail = snake[snake.length - 2];
  var temp1 = tail.row;
  var temp2 = tail.column;
  if (tail.row < beforeTail.row && tail.row - 1 >= 0) temp1 = --tail.row;
  if (tail.row > beforeTail.row && tail.row + 1 <= 20) temp1 = ++tail.row;
  if (tail.column > beforeTail.column && tail.column + 1 <= 20)
    temp2 = ++tail.column;
  if (tail.column < beforeTail.column && tail.column - 1 <= 20)
    temp2 = --tail.column;
  var temp = generate_location();
  healthyPos.row = temp.row;
  healthyPos.column = temp.column;
  snake.insert(snake.length - 1, Position(temp1, temp2));
  snakeColor.insert(snake.length - 1, Healthy_cell());
}

void eatUnHealthy(
  List<Widget> snakeColor,
  List<Position> snake,
  List<Position> unhealthyCels,
  List<Position> obstacles,
  Position head,
  Position newPosition,
) {
  counterNH.increment();
  if (counterNH.counter == 3) {
    obstacles.addAll([generate_location()]);
    counterNH.setToZero();
  }
  counterH.setToZero();
  var tail = snake[snake.length - 1];
  var beforeTail = snake[snake.length - 2];
  var temp1 = tail.row;
  var temp2 = tail.column;
  if (tail.row < beforeTail.row && tail.row - 1 >= 0) temp1 = --tail.row;
  if (tail.row > beforeTail.row && tail.row + 1 <= 20) temp1 = ++tail.row;
  if (tail.column > beforeTail.column && tail.column + 1 <= 20)
    temp2 = ++tail.column;
  if (tail.column < beforeTail.column && tail.column - 1 <= 20)
    temp2 = --tail.column;
  unhealthyCels.remove(newPosition);
  unhealthyCels.addAll([generate_location(), generate_location()]);
  snake.insert(snake.length - 1, Position(temp1, temp2));
  snakeColor.insert(snake.length - 1, NonHealthy_cell());
}

void eatSick(
  List<Widget> snakeColor,
  List<Position> snake,
  List<Position> unhealthyCels,
  List<Position> obstacles,
  Position head,
  Position newPosition,
  Position sickPos,
) {
  var tail = snake[snake.length - 1];
  var beforeTail = snake[snake.length - 2];
  var temp1 = tail.row;
  var temp2 = tail.column;
  if (tail.row < beforeTail.row && tail.row - 1 >= 0) temp1 = --tail.row;
  if (tail.row > beforeTail.row && tail.row + 1 <= 20) temp1 = ++tail.row;
  if (tail.column > beforeTail.column && tail.column + 1 <= 20)
    temp2 = ++tail.column;
  if (tail.column < beforeTail.column && tail.column - 1 <= 20)
    temp2 = --tail.column;
  var temp = generate_location();
  sickPos.row = temp.row;
  sickPos.column = temp.column;
  snake.insert(snake.length - 1, Position(temp1, temp2));
  snakeColor.insert(snake.length - 1, Sick_cell());
}

void hitObstacle(List<Widget> snakeColor) {
  if (snakeColor.contains(Sick_cell())) {
    var result = snakeColor.indexWhere((item) => item == Sick_cell());
    snakeColor[result] = NonHealthy_cell();
  } else {
    Random random = Random();
    int rand;
    do {
      rand = random.nextInt(snakeColor.length);
    } while (snakeColor[rand] == NonHealthy_cell());
    snakeColor[rand] = Sick_cell();
  }
}
