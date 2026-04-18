class Player {
  final String? id; // UUID do banco
  final String name;
  int? score;
  String? answer;
  bool isLeader;
  String status;
  bool? vote;

  Player({
    this.id,
    required this.name,
    this.score,
    this.answer,
    this.isLeader = false,
    this.status = 'aguardando',
    this.vote,
  });
}
