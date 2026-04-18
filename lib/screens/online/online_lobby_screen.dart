import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/player.dart';
import '../../services/backend_service.dart';
import 'online_room_screen.dart';

class OnlineLobbyScreen extends StatefulWidget {
  const OnlineLobbyScreen({super.key});

  @override
  State<OnlineLobbyScreen> createState() => _OnlineLobbyScreenState();
}

class _OnlineLobbyScreenState extends State<OnlineLobbyScreen> {
  final TextEditingController _createNameController = TextEditingController();
  final TextEditingController _joinNameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final BackendService _backendService = BackendService();
  bool _isLoading = false;

  void _showCustomSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message.toUpperCase(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.white, width: 2),
          borderRadius: BorderRadius.zero,
        ),
      ),
    );
  }

  void _createRoom() async {
    final name = _createNameController.text.trim().toUpperCase();
    
    if (name.isEmpty) {
      _showCustomSnackBar('Por favor, digite seu nome para criar a sala.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final roomCode = await _backendService.createRoom(name);
      final player = Player(name: name, isLeader: true);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OnlineRoomScreen(
              currentPlayer: player,
              roomCode: roomCode,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showCustomSnackBar('Erro: Não foi possível criar a sala. Tente novamente.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _joinRoom() async {
    final name = _joinNameController.text.trim().toUpperCase();
    final code = _codeController.text.trim().toUpperCase();
    
    if (name.isEmpty) {
      _showCustomSnackBar('Por favor, digite seu nome para entrar na sala.');
      return;
    }
    if (code.isEmpty) {
      _showCustomSnackBar('Por favor, digite o código da sala.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _backendService.joinRoom(code, name);
      final player = Player(name: name, isLeader: false);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OnlineRoomScreen(
              currentPlayer: player,
              roomCode: code,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showCustomSnackBar('Erro: Sala não encontrada ou indisponível. Verifique o código.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _createNameController.dispose();
    _joinNameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LOBBY ONLINE')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CRIAR SALA',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _createNameController,
                  decoration: const InputDecoration(
                    labelText: 'SEU NOME',
                    hintText: 'COMO DESEJA SER CHAMADO',
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createRoom,
                    child: const Text('CRIAR NOVA SALA'),
                  ),
                ),

                const SizedBox(height: 48),
                const Divider(color: Colors.white, thickness: 2),
                const SizedBox(height: 48),

                const Text(
                  'ENTRAR EM SALA',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _joinNameController,
                  decoration: const InputDecoration(
                    labelText: 'SEU NOME',
                    hintText: 'COMO DESEJA SER CHAMADO',
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'CÓDIGO DA SALA',
                    hintText: 'EX: 123456',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _joinRoom,
                    child: const Text('ENTRAR NA SALA'),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
