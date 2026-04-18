import 'dart:math';
import '../models/player.dart';

class GameLogic {
  static final GameLogic _instance = GameLogic._internal();
  factory GameLogic() => _instance;
  GameLogic._internal();

  bool isManualTheme = false;

  final List<String> _themes = [
    'Coisas úteis em um apocalipse zumbi',
    'Profissões mais estressantes',
    'Melhores superpoderes',
    'Comidas de festa',
    'Lugares para um primeiro encontro',
    'Hobbies estranhos',
    'Itens indispensáveis em uma ilha deserta',
    'Armas medievais mais letais',
    'Piores maneiras de morrer (em um filme)',
    'Animais mais mortais e perigosos',
    'Superpoderes mais inúteis',
    'Criaturas mitológicas mais assustadoras',
    'Coisas que dão mais medo no escuro',
    'Piores lugares para ficar preso',
    'Piores lugares para ter dor de barriga',
    'Coisas mais perigosas para fazer de olhos vendados',
    'Piores fobias de se ter',
    'Piores desculpas para chegar atrasado',
    'Coisas irritantes no trânsito',
    'Piores trabalhos domésticos',
    'Coisas mais difíceis de limpar',
    'Piores cheiros do dia a dia',
    'Coisas mais embaraçosas para acontecer em público',
    'Piores coisas para dizer em um velório',
    'Coisas que você esquece de levar na viagem',
    'Piores formas de terminar um relacionamento',
    'Coisas mais frustrantes da vida adulta',
    'Piores conselhos para se dar a alguém',
    'Piores mentiras para contar',
    'Coisas que dão mais preguiça de fazer',
    'Piores lugares para perder as chaves',
    'Piores formas de chamar a atenção',
    'Piores cortes de cabelo',
    'Coisas que ocupam muito espaço na casa',
    'Melhores invenções da humanidade',
    'Piores presentes para se receber no Natal',
    'Coisas mais inúteis que as pessoas compram',
    'Coisas mais difíceis de consertar',
    'Melhores aplicativos de celular',
    'Coisas que consomem mais bateria do celular',
    'Coisas que quebram mais fácil',
    'Piores coisas para deixar cair no chão',
    'Melhores coisas para comprar com o primeiro salário',
    'Piores presentes de amigo secreto',
    'Coisas mais caras no supermercado',
    'Coisas mais barulhentas',
    'Melhores filmes de todos os tempos',
    'Melhores jogos de videogame',
    'Supervilões mais assustadores do cinema',
    'Melhores séries de TV',
    'Talentos inúteis',
    'Melhores músicas para cantar no chuveiro',
    'Melhores heróis de quadrinhos',
    'Piores filmes já feitos',
    'Melhores consoles de videogame de todos os tempos',
    'Melhores brinquedos de infância',
    'Melhores jogos de tabuleiro',
    'Melhores estilos musicais',
    'Melhores canais ou tipos de vídeo no YouTube',
    'Melhores momentos da época de escola',
    'Sobremesas mais gostosas',
    'Piores ingredientes para colocar na pizza',
    'Coisas mais nojentas de comer',
    'Melhores sabores de sorvete',
    'Melhores refeições do dia',
    'Melhores doces de infância',
    'Piores coisas para esquecer no fogão',
    'Melhores bebidas quentes',
    'Coisas que você não deve misturar na cozinha',
    'Piores coisas para achar na comida',
    'Melhores petiscos de boteco',
    'Comidas que mais sujam as mãos',
    'Melhores tipos de queijo',
    'Piores sabores de refrigerante',
    'Coisas mais dolorosas de se pisar',
    'Melhores sentimentos do mundo',
    'Piores dores físicas',
    'Coisas mais grudentas',
    'Coisas que dão mais alergia',
    'Coisas mais difíceis de perdoar',
    'Melhores formas de relaxar',
    'Coisas que te fazem chorar de rir',
    'Coisas mais chatas de se esperar',
    'Sensações físicas mais agoniantes',
    'Animais mais fofos',
    'Piores animais de estimação para ter em um apartamento',
    'Melhores raças de cachorro',
    'Insetos mais irritantes',
    'Melhores destinos de férias na natureza',
    'Coisas para fazer em um dia de chuva',
    'Melhores estações do ano para viajar',
    'Coisas mais frias que existem',
    'Melhores lugares para acampar',
    'Esportes mais radicais',
    'Formas mais desconfortáveis de viajar',
    'Melhores atividades para o fim de semana',
    'Piores lugares para dormir',
    'Melhores marcas de caros',
    'Coisas mais pesadas de carregar',
    'Piores vizinhos possíveis',
    'Melhores esportes para assistir com os amigos',
    'Coisas mais difíceis de esconder',
    'Coisas mais difíceis de desenhar',
    'Piores nomes para se dar a um bebê',
    'Melhores fantasias de Halloween',
    'Profissões mais bem pagas no mundo dos sonhos',
    'Piores coisas para se encontrar no bolso',
  ];

  List<String> get allThemes => _themes;

  String getRandomTheme() {
    isManualTheme = false;
    return _themes[Random().nextInt(_themes.length)];
  }

  void assignUniqueScores(List<Player> players) {
    if (players.isEmpty) return;
    List<int> possibleScores = List.generate(100, (index) => index + 1);
    possibleScores.shuffle();
    for (int i = 0; i < players.length; i++) {
      if (i < possibleScores.length) {
        players[i].score = possibleScores[i];
      }
    }
  }
}
