import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_state.dart';
import '../bloc/game_event.dart';

class GameScreen extends StatefulWidget {
  // --- RECEBE AS VARIÁVEIS DA HOME ---
  final String p1Name;
  final String p2Name;
  final String p1Emoji;
  final String p2Emoji;

  const GameScreen({
    super.key,
    required this.p1Name,
    required this.p2Name,
    required this.p1Emoji,
    required this.p2Emoji,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late ConfettiController _confettiController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playSound(String assetName) async {
    if (_isMuted) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/$assetName'));
    } catch (e) {
      debugPrint("Erro ao tocar som: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0F7FA), Color(0xFF81D4FA), Color(0xFF4FC3F7)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              BlocConsumer<GameBloc, GameState>(
                listener: (context, state) {
                  if (state.winner != null) {
                    HapticFeedback.heavyImpact();

                    // Toca o som da vitória para qualquer um que ganhe a rodada (X ou O)
                    if (state.winner == 'X' || state.winner == 'O') {
                      _playSound('winner.mp3');
                    }

                    // LÓGICA DO TORNEIO (MELHOR DE 3)
                    if (state.playerXScore >= 3 || state.playerOScore >= 3) {
                      // Agora os confetes disparam para qualquer um que ganhe o torneio! 🎉
                      _confettiController.play();

                      // Pega o nome real do vencedor
                      String realWinner = state.winner == 'X'
                          ? widget.p1Name
                          : widget.p2Name;
                      _showTournamentWinnerDialog(context, realWinner);
                    } else {
                      _showResultDialog(context, state.winner!);
                    }
                  }
                },
                builder: (context, state) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.black87,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Expanded(
                              child: Text(
                                'Torneio',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _isMuted ? Icons.volume_off : Icons.volume_up,
                                color: Colors.black87,
                                size: 28,
                              ),
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                setState(() => _isMuted = !_isMuted);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildScoreboard(state),

                      if (state.playerXScore == 2 || state.playerOScore == 2)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            "🔥 MATCH POINT! 🔥",
                            style: GoogleFonts.poppins(
                              color: Colors.red[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),

                      const SizedBox(height: 15),
                      // MOSTRA O NOME DE QUEM ESTÁ JOGANDO
                      Text(
                        state.isThinking
                            ? "${widget.p2Name} a pensar..."
                            : 'Vez de: ${state.currentPlayer == 'X' ? widget.p1Name : widget.p2Name}',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: state.isThinking
                              ? Colors.deepOrange
                              : (state.currentPlayer == 'X'
                                    ? Colors.blue[700]
                                    : Colors.red[700]),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildGrid(context, state),
                      const SizedBox(height: 30),
                      _buildActionButtons(context),
                    ],
                  );
                },
              ),
              ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                  Colors.yellow,
                ],
                numberOfParticles: 20,
                gravity: 0.1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreboard(GameState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // USA OS NOMES E EMOJIS ESCOLHIDOS
            _scoreItem(
              "${widget.p1Name}\n(${widget.p1Emoji})",
              state.playerXScore,
              Colors.blue,
            ),
            Text(
              "VS",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w800,
                color: Colors.grey[400],
                fontSize: 18,
              ),
            ),
            _scoreItem(
              "${widget.p2Name}\n(${widget.p2Emoji})",
              state.playerOScore,
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _scoreItem(String label, int score, MaterialColor color) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: color[700],
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        Text(
          score.toString(),
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildGrid(BuildContext context, GameState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          bool isHumanTurn = state.isVsComputer
              ? state.currentPlayer == 'X'
              : true;
          bool canClick =
              !state.isThinking &&
              state.board[index] == '' &&
              state.winner == null &&
              isHumanTurn;
          bool isWinningSquare = state.winningLine.isNotEmpty
              ? state.winningLine.contains(index)
              : false;

          // AQUI É A MÁGICA: TROCA O 'X' E O 'O' PELO EMOJI NA HORA DE DESENHAR!
          String displaySymbol = '';
          if (state.board[index] == 'X') displaySymbol = widget.p1Emoji;
          if (state.board[index] == 'O') displaySymbol = widget.p2Emoji;

          return GestureDetector(
            onTap: canClick
                ? () {
                    HapticFeedback.lightImpact();
                    _playSound('click.mp3');
                    context.read<GameBloc>().add(MakeMove(index));
                  }
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: isWinningSquare ? Colors.greenAccent[200] : Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  displaySymbol,
                  style: GoogleFonts.fredoka(
                    // Se for emoji, diminui um pouco a fonte para caber perfeito
                    fontSize: (displaySymbol == '✖️' || displaySymbol == '⭕')
                        ? 55
                        : 45,
                    fontWeight: FontWeight.w600,
                    color: state.board[index] == 'X' ? Colors.blue : Colors.red,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            HapticFeedback.mediumImpact();
            context.read<GameBloc>().add(ResetGame());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black87,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          icon: const Icon(Icons.refresh),
          label: Text(
            "Reiniciar",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 10),
        OutlinedButton.icon(
          onPressed: () {
            HapticFeedback.mediumImpact();
            context.read<GameBloc>().add(ClearScoreboard());
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black87,
            side: const BorderSide(color: Colors.black87),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          icon: const Icon(Icons.delete_outline),
          label: Text(
            "Zerar Placar",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  void _showResultDialog(BuildContext context, String result) {
    String realWinnerName = result == 'Empate'
        ? ''
        : (result == 'X' ? widget.p1Name : widget.p2Name);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Fim de Rodada!",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                result == 'Empate' ? Icons.handshake : Icons.emoji_events,
                size: 80,
                color: result == 'Empate' ? Colors.orange : Colors.amber,
              ),
              const SizedBox(height: 20),
              Text(
                result == 'Empate'
                    ? "Temos um Empate!"
                    : "O vencedor da rodada é:\n$realWinnerName!",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                context.read<GameBloc>().add(ClearScoreboard());
                context.read<GameBloc>().add(ResetGame());
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text(
                "SAIR",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                context.read<GameBloc>().add(ResetGame());
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black87),
              child: Text(
                "PRÓXIMA RODADA",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showTournamentWinnerDialog(BuildContext context, String champion) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.amber[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "🏆 GRANDE CAMPEÃO! 🏆",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.amber[900],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, size: 100, color: Colors.amber),
              const SizedBox(height: 20),
              Text(
                "$champion venceu 3 vezes e ganhou o torneio!",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                context.read<GameBloc>().add(ClearScoreboard());
                context.read<GameBloc>().add(ResetGame());
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black87),
              child: Text(
                "VOLTAR AO MENU",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
