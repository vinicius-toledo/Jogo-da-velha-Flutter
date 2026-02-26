import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../../domain/usecases/calculate_bot_move_usecase.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool vsComputer = true;
  Difficulty selectedDifficulty = Difficulty.easy;
  String selectedStarter = 'X'; 

  // Variáveis para Nomes e Emojis
  final TextEditingController _p1Controller = TextEditingController();
  final TextEditingController _p2Controller = TextEditingController();
  
  String p1Emoji = '✖️';
  String p2Emoji = '⭕';
  
  // Lista de avatares (adicionei mais alguns divertidos!)
  final List<String> emojis = [
    '✖️', '⭕', '🐶', '🐱', '👽', '🤖', '⚔️', '🛡️', 
    '🍕', '🍔', '👻', '🦄', '🦖', '🚀'
  ];

  @override
  void dispose() {
    _p1Controller.dispose();
    _p2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0F7FA), Color(0xFF81D4FA), Color(0xFF4FC3F7)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text("Jogo da Velha", style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 20),

                // 1. ESCOLHA O MODO
                _buildCard(
                  title: "Escolha o modo",
                  child: Row(
                    children: [
                      _modeButton("COMPUTADOR", vsComputer, () => setState(() => vsComputer = true)),
                      const SizedBox(width: 10),
                      _modeButton("JOGADOR", !vsComputer, () => setState(() => vsComputer = false)),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                // 2. NOMES DOS JOGADORES
                _buildCard(
                  title: "Personalizar Jogadores",
                  child: Column(
                    children: [
                      _buildPlayerSetup(
                        isPlayer1: true, 
                        controller: _p1Controller, 
                        hint: vsComputer ? "Seu Nome" : "Nome do Player 1",
                        currentEmoji: p1Emoji,
                      ),
                      const SizedBox(height: 15),
                      _buildPlayerSetup(
                        isPlayer1: false, 
                        controller: _p2Controller, 
                        hint: vsComputer ? "Computador" : "Nome do Player 2",
                        currentEmoji: p2Emoji,
                        enableName: !vsComputer, // Desativa o nome se for PC, mas deixa o emoji livre!
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                // 3. QUEM COMEÇA?
                _buildCard(
                  title: "Quem começa?",
                  child: Row(
                    children: [
                      _modeButton(
                        vsComputer ? "EU ($p1Emoji)" : "P1 ($p1Emoji)",
                        selectedStarter == 'X',
                        () => setState(() => selectedStarter = 'X'),
                      ),
                      const SizedBox(width: 10),
                      _modeButton(
                        vsComputer ? "BOT ($p2Emoji)" : "P2 ($p2Emoji)",
                        selectedStarter == 'O',
                        () => setState(() => selectedStarter = 'O'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                // 4. DIFICULDADE
                if (vsComputer)
                  _buildCard(
                    title: "Dificuldade",
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _diffButton("Fácil", Difficulty.easy),
                        _diffButton("Médio", Difficulty.medium),
                        _diffButton("Difícil", Difficulty.hard),
                      ],
                    ),
                  ),

                const SizedBox(height: 30),

                // BOTÃO INICIAR
                GestureDetector(
                  onTap: () {
                    final bloc = context.read<GameBloc>();
                    bloc.add(SetStartingPlayer(selectedStarter, vsComputer));
                    if (vsComputer) bloc.add(ChangeDifficulty(selectedDifficulty));
                    
                    // Define os nomes finais
                    String finalP1Name = _p1Controller.text.isEmpty ? (vsComputer ? "Você" : "Player 1") : _p1Controller.text;
                    String finalP2Name = vsComputer ? "Bot" : (_p2Controller.text.isEmpty ? "Player 2" : _p2Controller.text);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GameScreen(
                          p1Name: finalP1Name,
                          p2Name: finalP2Name,
                          p1Emoji: p1Emoji,
                          p2Emoji: p2Emoji,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 300,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(15)),
                    child: Text("Iniciar Torneio", textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES DA HOME ---

  Widget _buildPlayerSetup({
    required bool isPlayer1, 
    required TextEditingController controller, 
    required String hint, 
    required String currentEmoji, 
    bool enableName = true,
  }) {
    return Row(
      children: [
        // Botão para abrir os Emojis (Sempre ativo!)
        GestureDetector(
          onTap: () => _showEmojiPicker(isPlayer1),
          child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(currentEmoji, style: const TextStyle(fontSize: 24))),
          ),
        ),
        const SizedBox(width: 10),
        // Campo de Texto (Bloqueia apenas se for o PC)
        Expanded(
          child: TextField(
            controller: controller,
            enabled: enableName,
            style: GoogleFonts.poppins(),
            decoration: InputDecoration(
              hintText: hint,
              contentPadding: const EdgeInsets.symmetric(horizontal: 15),
              filled: true,
              fillColor: enableName ? Colors.grey[100] : Colors.grey[300],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ),
        ),
      ],
    );
  }

  void _showEmojiPicker(bool isPlayer1) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Escolha o Avatar", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Wrap(
                spacing: 15,
                runSpacing: 15,
                children: emojis.map((emoji) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isPlayer1) p1Emoji = emoji;
                        else p2Emoji = emoji;
                      });
                      Navigator.pop(context);
                    },
                    child: Text(emoji, style: const TextStyle(fontSize: 40)),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  Widget _modeButton(String text, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: isActive ? Colors.black87 : Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black87)),
          child: Text(text, textAlign: TextAlign.center, style: GoogleFonts.poppins(color: isActive ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
    );
  }

  Widget _diffButton(String label, Difficulty diff) {
    bool isSelected = selectedDifficulty == diff;
    return GestureDetector(
      onTap: () => setState(() => selectedDifficulty = diff),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: isSelected ? Colors.blueAccent : Colors.grey[200], borderRadius: BorderRadius.circular(8)),
        child: Text(label, style: GoogleFonts.poppins(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }
}