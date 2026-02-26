import 'dart:math';
import 'check_winner_usecase.dart';

enum Difficulty { easy, medium, hard }

class CalculateBotMoveUseCase {
  final CheckWinnerUseCase checkWinner;

  CalculateBotMoveUseCase(this.checkWinner);

  int execute(List<String> board, Difficulty difficulty, String botPlayer, String humanPlayer) {
    List<int> emptySpots = [];
    for (int i = 0; i < board.length; i++) {
      if (board[i] == '') emptySpots.add(i);
    }

    if (difficulty == Difficulty.easy) return _getRandomMove(emptySpots);

    if (difficulty == Difficulty.medium) {
      bool playSmart = Random().nextBool();
      if (!playSmart) return _getRandomMove(emptySpots);
    }

    int? winningMove = _findWinningMove(board, emptySpots, botPlayer);
    if (winningMove != null) return winningMove;

    int? blockingMove = _findWinningMove(board, emptySpots, humanPlayer);
    if (blockingMove != null) return blockingMove;

    if (board[4] == '') return 4;

    return _getRandomMove(emptySpots);
  }

  int _getRandomMove(List<int> emptySpots) {
    final random = Random();
    return emptySpots[random.nextInt(emptySpots.length)];
  }

  int? _findWinningMove(List<String> board, List<int> emptySpots, String playerSymbol) {
    for (int spot in emptySpots) {
      List<String> tempBoard = List.from(board);
      tempBoard[spot] = playerSymbol; 
      if (checkWinner.execute(tempBoard) == playerSymbol) {
        return spot; 
      }
    }
    return null; 
  }
}