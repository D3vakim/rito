import 'package:flutter/material.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('COMO JOGAR')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStep('1. SETUP', 'Adicione de 2 a 10 jogadores na tela inicial e inicie a partida.'),
            _buildStep('2. TEMA E NOTAS', 'Um tema será sorteado. Cada jogador receberá uma nota secreta de 1 a 100.'),
            _buildStep('3. DICAS', 'Cada um deve escrever uma dica que represente sua nota baseada no tema. (Ex: Tema "Frutas", Nota 100 = "Morango Suculento", Nota 1 = "Tomate Passado")'),
            _buildStep('4. ORDENAÇÃO', 'A equipe deve ler as dicas e tentar organizar os jogadores da MAIOR para a MENOR nota.'),
            _buildStep('5. RESULTADO', 'Descubra quem acertou a ordem e divirta-se com os erros!'),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ENTENDI!'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 1),
            ),
            child: Text(
              description,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
