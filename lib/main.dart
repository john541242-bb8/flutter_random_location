import 'package:flutter/material.dart';
import 'pages/lobby.dart';
import 'pages/resultsList.dart';

void main() {
  runApp(
    MaterialApp(
      initialRoute: "/lobby",
      routes: {
        "/lobby": (context) => Lobby(),
        "/resultList": (context) => Resultslist(),
      },
    ),
  );
}
