import 'package:flutter/material.dart';
import '../models/player.dart';
import '../logic/game_logic.dart';
import 'secret_draw_screen.dart';

class PlayerSetupScreen extends StatefulWidget {
  const PlayerSetupScreen({super.key});

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  final List<Player> _players = [];
  final TextEditingController _nameController = TextEditingController();
  final GameLogic _gameLogic = GameLogic();

  void _addPlayer() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      setState(() {
        _players.add(Player(name: name));
        _nameController.clear();
      });
    }
  }

  void _removePlayer(int index) {
    setState(() {
      _players.removeAt(index);
    });
  }

  void _editPlayerName(int index) {
    final TextEditingController editController = TextEditingController(text: _players[index].name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Nome'),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(labelText: 'Novo Nome'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (editController.text.trim().isNotEmpty) {
                setState(() {
                  _players[index] = Player(name: editController.text.trim());
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _startGame() {
    String theme = _gameLogic.getRandomTheme();
    _gameLogic.assignUniqueScores(_players);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SecretDrawScreen(players: _players, theme: theme),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rito - Jogadores'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do Jogador',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addPlayer(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _addPlayer, child: const Text('Add')),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _players.isEmpty
                  ? const Center(child: Text('Adicione jogadores para começar'))
                  : ListView.builder(
                      itemCount: _players.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            onTap: () => _editPlayerName(index),
                            title: Text(_players[index].name),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _removePlayer(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _players.length >= 2 ? _startGame : null,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                child: const Text('Iniciar Jogo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
