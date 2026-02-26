import 'package:flutter_bloc/flutter_bloc.dart';
import 'game_event.dart';
import 'game_state.dart';
import '../../domain/usecases/check_winner_usecase.dart';
import '../../domain/usecases/calculate_bot_move_usecase.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final CheckWinnerUseCase checkWinnerUseCase;
  final CalculateBotMoveUseCase calculateBotMoveUseCase;

  GameBloc(this.checkWinnerUseCase, this.calculateBotMoveUseCase)
    : super(
        GameState(
          board: List.filled(9, ''),
          currentPlayer: 'X',
          startingPlayer: 'X',
        ),
      ) {
    on<MakeMove>(_onMakeMove);
    on<ChangeDifficulty>(_onChangeDifficulty);
    on<ResetGame>(_onResetGame);
    on<ClearScoreboard>(_onClearScoreboard);
    on<SetStartingPlayer>(_onSetStartingPlayer);
  }

  void _onSetStartingPlayer(SetStartingPlayer event, Emitter<GameState> emit) {
    emit(
      GameState(
        board: List.filled(9, ''),
        currentPlayer: event.player,
        startingPlayer: event.player,
        isVsComputer: event.isVsComputer, // Define o modo de jogo
        difficulty: state.difficulty,
        playerXScore: state.playerXScore,
        playerOScore: state.playerOScore,
        isThinking: false,
      ),
    );

    // Se escolheu o Bot (O) para começar E for contra o computador, o bot joga
    if (event.isVsComputer && event.player == 'O') {
      add(MakeMove(-1));
    }
  }

  void _onResetGame(ResetGame event, Emitter<GameState> emit) {
    String nextStarter = (state.startingPlayer == 'X') ? 'O' : 'X';
  
    emit(GameState(
      board: List.filled(9, ''),
      currentPlayer: nextStarter,
      startingPlayer: nextStarter,
      difficulty: state.difficulty,
      playerXScore: state.playerXScore,
      playerOScore: state.playerOScore,
      isThinking: false,
      isVsComputer: state.isVsComputer, // Mantém o modo
    ));

    // Se for contra o PC e a vez inicial for do 'O', o bot começa sozinho
    if (state.isVsComputer && nextStarter == 'O') {
      add(MakeMove(-1));
    }
  }

  void _onMakeMove(MakeMove event, Emitter<GameState> emit) async {
    // Bloqueia se o jogo acabou ou se o bot já está pensando
    if (state.winner != null || state.isThinking) return;

    // 1. Processa a jogada do humano (Player 1 ou Player 2)
    if (event.index != -1) {
      if (state.board[event.index] != '') return;
      _processTurn(event.index, state.currentPlayer, emit);
    }

    // 2. JOGADA DO BOT: Só entra se for convidado (isVsComputer = true)
    if (state.isVsComputer &&
        state.winner == null &&
        state.currentPlayer == 'O') {
      
      emit(_copyState(isThinking: true));

      await Future.delayed(const Duration(milliseconds: 1000));

      int botIndex = calculateBotMoveUseCase.execute(
        state.board,
        state.difficulty,
        'O',
        'X',
      );

      _processTurn(botIndex, 'O', emit);
      emit(_copyState(isThinking: false));
    }
  }

  // --- O MÉTODO CORRIGIDO (COM AS VARIÁVEIS DE PONTUAÇÃO E TURNO) ---
  void _processTurn(int index, String player, Emitter<GameState> emit) {
    List<String> newBoard = List.from(state.board);
    newBoard[index] = player;
    
    String? winner = checkWinnerUseCase.execute(newBoard);
    String nextPlayer = (player == 'X') ? 'O' : 'X';
    
    int newXScore = state.playerXScore;
    int newOScore = state.playerOScore;

    // --- NOVA LÓGICA: DESCOBRIR A LINHA VENCEDORA ---
    List<int> winLine = [];
    if (winner != null) {
      if (winner == 'X') newXScore++;
      if (winner == 'O') newOScore++;
      
      // Combinações possíveis para ganhar
      const lines = [
        [0, 1, 2], [3, 4, 5], [6, 7, 8], // Linhas horizontais
        [0, 3, 6], [1, 4, 7], [2, 5, 8], // Linhas verticais
        [0, 4, 8], [2, 4, 6]             // Diagonais
      ];
      for (var line in lines) {
        if (newBoard[line[0]] == winner && newBoard[line[1]] == winner && newBoard[line[2]] == winner) {
          winLine = line; // Guarda os índices vencedores!
          break;
        }
      }
    }

    emit(
      GameState(
        board: newBoard,
        currentPlayer: nextPlayer,
        startingPlayer: state.startingPlayer,
        winner: winner,
        difficulty: state.difficulty,
        playerXScore: newXScore,
        playerOScore: newOScore,
        isThinking: false,
        isVsComputer: state.isVsComputer,
        winningLine: winLine, // <--- PASSE A LINHA AQUI
      ),
    );
  }

  void _onChangeDifficulty(ChangeDifficulty event, Emitter<GameState> emit) {
    emit(_copyState(difficulty: event.difficulty));
  }

  void _onClearScoreboard(ClearScoreboard event, Emitter<GameState> emit) {
    emit(
      GameState(
        board: List.filled(9, ''),
        currentPlayer: 'X',
        startingPlayer: 'X',
        difficulty: state.difficulty,
        playerXScore: 0,
        playerOScore: 0,
        isThinking: false,
        isVsComputer: state.isVsComputer, // Mantém o modo
      ),
    );
  }

  GameState _copyState({bool? isThinking, Difficulty? difficulty}) {
    return GameState(
      board: state.board,
      currentPlayer: state.currentPlayer,
      startingPlayer: state.startingPlayer,
      winner: state.winner,
      difficulty: difficulty ?? state.difficulty,
      playerXScore: state.playerXScore,
      playerOScore: state.playerOScore,
      isThinking: isThinking ?? state.isThinking,
      isVsComputer: state.isVsComputer, // Mantém o modo de jogo
    );
  }
}