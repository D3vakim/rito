import 'package:flutter/material.dart';
import '../models/player.dart';
import '../widgets/nav_confirm_dialog.dart';
import '../logic/game_logic.dart';
import 'answers_screen.dart';

class SecretDrawScreen extends StatefulWidget {
  final List<Player> players;
  final String theme;

  const SecretDrawScreen({super.key, required this.players, required this.theme});

  @override
  State<SecretDrawScreen> createState() => _SecretDrawScreenState();
}

class _SecretDrawScreenState extends State<SecretDrawScreen> {
  late String _currentTheme;
  int _currentPlayerIndex = 0;
  bool _revealed = false;
  final GameLogic _gameLogic = GameLogic();

  @override
  void initState() {
    super.initState();
    _currentTheme = widget.theme;
  }

  void _refreshTheme() {
    setState(() {
      _currentTheme = _gameLogic.getRandomTheme();
    });
  }

  void _showThemePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.white, width: 2)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: const Text(
                  'ESCOLHER TEMA',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
              ),
              const Divider(color: Colors.white),
              Expanded(
                child: ListView.separated(
                  itemCount: _gameLogic.allThemes.length,
                  separatorBuilder: (context, index) => const Divider(color: Colors.white38),
                  itemBuilder: (context, index) {
                    final theme = _gameLogic.allThemes[index];
                    return ListTile(
                      title: Text(
                        theme.toUpperCase(),
                        style: const TextStyle(fontSize: 14),
                      ),
                      onTap: () {
                        setState(() {
                          _currentTheme = theme;
                          _gameLogic.isManualTheme = true;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCustomThemeDialog() {
    final TextEditingController themeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('TEMA PERSONALIZADO'),
        content: TextField(
          controller: themeController,
          decoration: const InputDecoration(
            labelText: 'DIGITE O TEMA',
            hintText: 'Ex: Melhores piores filmes',
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              if (themeController.text.trim().isNotEmpty) {
                setState(() {
                  _currentTheme = themeController.text.trim();
                  _gameLogic.isManualTheme = true;
                });
                Navigator.pop(context);
              }
            },
            child: const Text('CONFIRMAR'),
          ),
        ],
      ),
    );
  }

  void _handleButtonPress() {
    if (!_revealed) {
      setState(() => _revealed = true);
    } else {
      if (_currentPlayerIndex < widget.players.length - 1) {
        setState(() {
          _currentPlayerIndex++;
          _revealed = false;
        });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnswersScreen(players: widget.players, theme: _currentTheme),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPlayer = widget.players[_currentPlayerIndex];

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
          title: const Text('NOTAS SECRETAS'),
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'TEMA: ${_currentTheme.toUpperCase()}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: _refreshTheme,
                    ),
                  ],
                ),
                Wrap(
                  spacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    TextButton(
                      onPressed: _showThemePicker,
                      child: const Text('LISTA'),
                    ),
                    TextButton(
                      onPressed: _showCustomThemeDialog,
                      child: const Text('CUSTOM'),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Text(
                  'VEZ DO JOGADOR:',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  currentPlayer.name.toUpperCase(),
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
                const SizedBox(height: 50),
                Container(
                  height: 180,
                  width: 180,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: _revealed
                      ? Text(
                          '${currentPlayer.score}',
                          style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
                        )
                      : const Icon(Icons.lock_outline, size: 80, color: Colors.white),
                ),
                const SizedBox(height: 50),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _handleButtonPress,
                    child: Text(
                      _revealed ? 'ESCONDER E PASSAR' : 'REVELAR MINHA NOTA',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
