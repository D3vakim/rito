import 'package:flutter/material.dart';

class NavConfirmDialog extends StatelessWidget {
  const NavConfirmDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Colors.white),
        borderRadius: BorderRadius.all(Radius.zero),
      ),
      title: const Text(
        'REALMENTE DESEJA VOLTAR?',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: const Text(
        'O progresso da rodada atual será perdido e você voltará para a tela inicial de jogadores.',
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('CANCELAR'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('SIM, VOLTAR'),
        ),
      ],
    );
  }
}

Future<bool> showNavConfirmDialog(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => const NavConfirmDialog(),
      ) ??
      false;
}
