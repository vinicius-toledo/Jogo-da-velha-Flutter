import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Use os caminhos corretos do seu projeto
import 'domain/usecases/check_winner_usecase.dart';
import 'domain/usecases/calculate_bot_move_usecase.dart';
import 'presentation/bloc/game_bloc.dart';
import 'presentation/screens/home_screen.dart'; // Verifique se este caminho está certo

void main() {
  final checkWinner = CheckWinnerUseCase();
  final calculateBot = CalculateBotMoveUseCase(checkWinner);

  runApp(
    BlocProvider(
      create: (context) => GameBloc(checkWinner, calculateBot),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(), // Aqui é onde o erro acontece se o import estiver errado
    );
  }
}