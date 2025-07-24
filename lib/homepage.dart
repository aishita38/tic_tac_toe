import 'dart:isolate';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  final bool isBotMode;
  const HomePage({super.key, required this.isBotMode});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late bool isBotMode;
  bool win = false;
  int oh_score = 0;
  int x_score = 0;
  bool ohTurn = true; // first person would be oh
  int filledBoxes = 0;
  List<String> displayExOh = ["", "", "", "", "", "", "", "", ""];

  @override
  void initState() {
    super.initState();
    isBotMode = widget.isBotMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "TIC TAC TOE",
              style: GoogleFonts.pressStart2p(
                color: Colors.white,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Score Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      "Player 1",
                      style: GoogleFonts.pressStart2p(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      oh_score.toString(),
                      style: GoogleFonts.pressStart2p(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      "Player 2",
                      style: GoogleFonts.pressStart2p(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      x_score.toString(),
                      style: GoogleFonts.pressStart2p(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Grid Section
            AspectRatio(
              aspectRatio: 1, // Keeps grid square
              child: GridView.builder(
                itemCount: 9,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _tapped(index),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          displayExOh[index],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isWinner(String player) {
    List<List<int>> winConditions = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var condition in winConditions) {
      if (displayExOh[condition[0]] == player &&
          displayExOh[condition[1]] == player &&
          displayExOh[condition[2]] == player) {
        return true;
      }
    }

    return false;
  }

  int minimax(bool isMaximizing) {
    if (_isWinner('X')) return 1;
    if (_isWinner('0')) return -1;
    if (!displayExOh.contains('')) return 0;

    if (isMaximizing) {
      int bestScore = -1000;
      for (int i = 0; i < displayExOh.length; i++) {
        if (displayExOh[i] == '') {
          displayExOh[i] = 'X';

          int score = minimax(false);
          displayExOh[i] = '';
          bestScore = max(score, bestScore);
        }
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int i = 0; i < displayExOh.length; i++) {
        if (displayExOh[i] == '') {
          displayExOh[i] = '0';
          int score = minimax(true);
          displayExOh[i] = '';
          bestScore = min(score, bestScore);
        }
      }
      return bestScore;
    }
  }

  void _botMove() {
    int bestScore = -1000;
    int move = -1;

    for (int i = 0; i < displayExOh.length; i++) {
      if (displayExOh[i] == '') {
        displayExOh[i] = 'X'; // simulate bot move
        int score = minimax(false); //get max score
        displayExOh[i] = ''; // undo move
        if (score > bestScore) {
          bestScore = score;
          move = i;
        }
      }
      if (bestScore == 1) {
        break;
      }
    }

    // ✅ NOW place the bot's chosen move on the board
    if (move != -1) {
      setState(() {
        displayExOh[move] = 'X';
      });
      _checkWinner();
      if (!win) _checkDraw();
      filledBoxes++;
    }
  }

  void _tapped(int index) {
    setState(() {
      if (displayExOh[index] == '') {
        filledBoxes++;
        if (ohTurn) {
          displayExOh[index] = '0';
        } else {
          displayExOh[index] = 'X';
        }

        ohTurn = !ohTurn;
        _checkWinner();
        if (!win) _checkDraw();
        if (isBotMode) {
          _botMove();
          ohTurn = !ohTurn;
        }
      }
    });
  }

  void _checkDraw() {
    if (filledBoxes == 9) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("DRAW"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // closes the dialog
                  reset_grid(); // resets the board
                },
                child: Text("Play Again"),
              ),
            ],
          );
        },
      );
    }
  }

  void _checkWinner() {
    List<List<int>> winConditions = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var condition in winConditions) {
      String a = displayExOh[condition[0]];
      String b = displayExOh[condition[1]];
      String c = displayExOh[condition[2]];

      if (a != '' && a == b && b == c) {
        win = true;
        String winner = (a == '0') ? 'Player 1' : 'Player 2';
        if (a == "0") {
          oh_score++;
        } else {
          x_score++;
        }
        _showDialog(winner);
        return;
      }
    }
  }

  void reset_grid() {
    setState(() {
      displayExOh = ["", "", "", "", "", "", "", "", ""];
      filledBoxes = 0;
      win = false;
    });
  }

  void _showDialog(String winner) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("WINNER IS: " + winner),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // closes the dialog
                reset_grid(); // resets the board
              },
              child: Text("Play Again"),
            ),
          ],
        );
      },
    );
  }
}
