import '../../domain/usecases/calculate_bot_move_usecase.dart';

class GameState {
  final List<String> board;
  final String currentPlayer;
  final String startingPlayer; // Adicionado
  final String? winner;
  final Difficulty difficulty;
  final int playerXScore;
  final int playerOScore;
  final bool isThinking; 
  final bool isVsComputer;
  final List<int> winningLine;

  GameState({
    required this.board,
    required this.currentPlayer,
    required this.startingPlayer,
    this.winner,
    this.difficulty = Difficulty.easy,
    this.playerXScore = 0,
    this.playerOScore = 0,
    this.isThinking = false,
    this.isVsComputer = true,
    this.winningLine = const [],
  });
}