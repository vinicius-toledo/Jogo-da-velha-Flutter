import '../../domain/usecases/calculate_bot_move_usecase.dart';

abstract class GameEvent {}

class MakeMove extends GameEvent {
  final int index;
  MakeMove(this.index);
}

class ChangeDifficulty extends GameEvent {
  final Difficulty difficulty;
  ChangeDifficulty(this.difficulty);
}

class SetStartingPlayer extends GameEvent {
  final String player;
  final bool isVsComputer;
  SetStartingPlayer(this.player, this.isVsComputer);
}

class ResetGame extends GameEvent {}

class ClearScoreboard extends GameEvent {}