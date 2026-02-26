class CheckWinnerUseCase {
  String? execute(List<String> b) {
    List<List<int>> lines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Linhas horizontais
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Linhas verticais
      [0, 4, 8], [2, 4, 6]             // Diagonais
    ];
    for (var line in lines) {
      if (b[line[0]] != '' && b[line[0]] == b[line[1]] && b[line[0]] == b[line[2]]) {
        return b[line[0]];
      }
    }
    if (!b.contains('')) return 'Empate';
    return null;
  }
}