import 'package:flutter/material.dart';

class QuickHelpDialog extends StatelessWidget {
  const QuickHelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Colors.white, width: 2),
        borderRadius: BorderRadius.zero,
      ),
      title: const Text(
        'DICAS DE MESTRE',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2),
      ),
      content: const SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A sua dica deve refletir o quão alta ou baixa é a sua nota secreta em relação ao tema.',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              'Exemplo - Tema: Lugares para passar as férias',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '• Nota Baixa (1 a 30): Pense no pior cenário possível. Ex: Acampamento num pântano cheio de mosquitos.',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              '• Nota Média (31 a 70): Algo comum ou razoável. Ex: Ficar em casa assistindo série ou ir pra casa da sogra.',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              '• Nota Alta (71 a 100): O melhor cenário imaginável. Ex: Resort 5 estrelas nas Maldivas com tudo pago.',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              'Lembre-se: O desafio é alinhar a sua ideia com a dos seus amigos sem dizer o seu número!',
              style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ENTENDI!'),
        ),
      ],
    );
  }
}
