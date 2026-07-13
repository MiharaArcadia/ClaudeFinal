// Standalone live check for the food-search ranking.
//
// Runs the REAL OpenFoodFactsService.searchFood() against ~100 German terms
// and prints the top result for each, flagging any that look processed.
// The pure/raw product (vegetable, fruit, plain meat, staple) should be #1.
//
// Run locally (needs internet — the OpenFoodFacts API):
//   dart run tool/search_ranking_check.dart
//
// Optionally show the top 3 per term:
//   dart run tool/search_ranking_check.dart --top3

import 'package:carby/services/open_food_facts_service.dart';

const terms = <String>[
  // Gemüse
  'Paprika', 'Tomate', 'Gurke', 'Karotte', 'Möhre', 'Zwiebel', 'Kartoffel',
  'Brokkoli', 'Blumenkohl', 'Spinat', 'Zucchini', 'Aubergine', 'Lauch',
  'Sellerie', 'Kürbis', 'Rote Bete', 'Rettich', 'Radieschen', 'Fenchel',
  'Spargel', 'Erbsen', 'Bohnen', 'Mais', 'Champignon', 'Knoblauch',
  'Rosenkohl', 'Grünkohl', 'Chinakohl', 'Weißkohl', 'Rotkohl',
  // Obst
  'Apfel', 'Banane', 'Birne', 'Orange', 'Zitrone', 'Erdbeere', 'Himbeere',
  'Blaubeere', 'Kirsche', 'Traube', 'Pfirsich', 'Nektarine', 'Aprikose',
  'Ananas', 'Mango', 'Kiwi', 'Wassermelone', 'Melone', 'Pflaume', 'Feige',
  'Granatapfel', 'Grapefruit', 'Mandarine', 'Avocado', 'Dattel',
  // Fleisch & Fisch
  'Hähnchen', 'Hähnchenbrust', 'Rindfleisch', 'Hackfleisch',
  'Schweinefleisch', 'Pute', 'Putenbrust', 'Lachs', 'Thunfisch', 'Forelle',
  'Garnelen', 'Ei', 'Speck', 'Schinken', 'Steak', 'Kabeljau', 'Hering',
  'Ente', 'Lamm',
  // Grundnahrung & Milchprodukte
  'Reis', 'Nudeln', 'Haferflocken', 'Quinoa', 'Linsen', 'Kichererbsen',
  'Milch', 'Joghurt', 'Quark', 'Butter', 'Käse', 'Frischkäse', 'Mozzarella',
  'Brot', 'Mehl', 'Zucker', 'Honig', 'Mandeln', 'Walnüsse', 'Cashew',
  'Olivenöl', 'Tofu', 'Couscous', 'Bulgur', 'Dinkel', 'Hirse',
];

const _processedHints = <String>[
  'chips', 'snack', 'sauce', 'soße', 'frikassee', 'nuggets', 'gewürz',
  'würz', 'pulver', 'riegel', 'sticks', 'wurst', 'aufstrich', 'creme',
  'paniert', ' mit ', ' & ', '+',
];

Future<void> main(List<String> args) async {
  final showTop3 = args.contains('--top3');
  final api = OpenFoodFactsService();
  var flagged = 0;
  var empty = 0;

  for (final term in terms) {
    final res = await api.searchFood(term);
    if (res.isEmpty) {
      empty++;
      print('${term.padRight(16)} -> (keine Ergebnisse)');
      continue;
    }
    final top = res.first.name;
    final low = top.toLowerCase();
    final suspicious = _processedHints.any(low.contains);
    if (suspicious) flagged++;
    final flag = suspicious ? '  <-- PRUEFEN' : '';
    print('${term.padRight(16)} -> $top$flag');
    if (showTop3) {
      for (final f in res.take(3).skip(1)) {
        print('${' '.padRight(19)}$f');
      }
    }
  }

  print('\n${terms.length} Begriffe getestet.');
  print('$flagged Top-Treffer wirken verarbeitet (bitte pruefen).');
  if (empty > 0) print('$empty Begriffe ohne Ergebnis.');
}
