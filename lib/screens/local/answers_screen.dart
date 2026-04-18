import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../widgets/nav_confirm_dialog.dart';
import 'ordering_screen.dart';

class AnswersScreen extends StatefulWidget {
  final List<Player> players;
  final String theme;

  const AnswersScreen({super.key, required this.players, required this.theme});

  @override
  State<AnswersScreen> createState() => _AnswersScreenState();
}

class _AnswersScreenState extends State<AnswersScreen> {
  int _currentIndex = 0;
  final TextEditingController _controller = TextEditingController();

  void _saveAnswer() {
    if (_controller.text.trim().isNotEmpty) {
      widget.players[_currentIndex].answer = _controller.text.trim();
      if (_currentIndex < widget.players.length - 1) {
        setState(() {
          _currentIndex++;
          _controller.clear();
        });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderingScreen(players: widget.players, theme: widget.theme),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPlayer = widget.players[_currentIndex];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final bool shouldPop = await showNavConfirmDialog(context);
        if (shouldPop && context.mounted) {
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('FASE DE RESPOSTAS'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final bool shouldPop = await showNavConfirmDialog(context);
              if (shouldPop && context.mounted) {
                Navigator.popUntil(context, (route) => route.isFirst);
              }
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text(
                'TEMA: ${widget.theme.toUpperCase()}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              const Text(
                'RESPOSTA DE:',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              Text(
                currentPlayer.name.toUpperCase(),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'ESCREVA SUA DICA...',
                  hintText: 'BASEIE SUA RESPOSTA NA SUA NOTA SECRETA',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _saveAnswer,
                  child: const Text('SALVAR E PRÓXIMO', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
