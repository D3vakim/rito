import 'package:flutter/material.dart';
import '../models/player.dart';
import '../logic/game_logic.dart';
import 'secret_draw_screen.dart';

class ResultsScreen extends StatelessWidget {
  final List<Player> orderedPlayers;

  const ResultsScreen({super.key, required this.orderedPlayers});

  void _playAgain(BuildContext context) {
    final GameLogic gameLogic = GameLogic();
    
    // Limpa scores e respostas
    for (var player in orderedPlayers) {
      player.score = null;
      player.answer = null;
    }

    // Obriga um novo sorteio aleatório ao iniciar nova rodada
    String theme = gameLogic.getRandomTheme();
    gameLogic.assignUniqueScores(orderedPlayers);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => SecretDrawScreen(players: orderedPlayers, theme: theme),
      ),
      (route) => route.isFirst,
    );
  }

  String _getFeedbackMessage(double percentage) {
    if (percentage == 1.0) return 'PARABÉNS, VOCÊS ARRASARAM!';
    if (percentage > 0.5) return 'FOI QUASE';
    if (percentage > 0.0) return 'É, NÃO FOI UM DESASTRE COMPLETO';
    return 'FRACASSO TOTAL';
  }

  @override
  Widget build(BuildContext context) {
    final List<Player> correctOrder = List.from(orderedPlayers);
    correctOrder.sort((a, b) => (b.score ?? 0).compareTo(a.score ?? 0));

    int correctCount = 0;
    for (int i = 0; i < orderedPlayers.length; i++) {
      if (orderedPlayers[i] == correctOrder[i]) {
        correctCount++;
      }
    }
    double percentage = correctCount / orderedPlayers.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('RESULTADOS'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              _getFeedbackMessage(percentage),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: orderedPlayers.length,
              itemBuilder: (context, index) {
                final player = orderedPlayers[index];
                final bool isCorrect = player == correctOrder[index];

                return Card(
                  color: isCorrect ? Colors.green : Colors.red,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.zero),
                  ),
                  child: ListTile(
                    leading: Text(
                      '${player.score}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    title: Text(
                      player.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    subtitle: Text(
                      player.answer ?? '',
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: Icon(
                      isCorrect ? Icons.check : Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => _playAgain(context),
                child: const Text('JOGAR NOVAMENTE', style: TextStyle(letterSpacing: 2)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
