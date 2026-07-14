// Live check for the food-search ranking against the everyday grocery list.
//
// Runs the REAL OpenFoodFactsService.searchFood() over the terms below and
// prints the top result per term. Groups are tagged RAW or BRAND:
//   RAW   -> a raw/whole product should be #1 (vegetables, fruit, plain meat…)
//   BRAND -> the searched brand / prepared product should be #1 (Nutella, Cola…)
// Only RAW groups get a "<-- PRUEFEN" flag when the top hit looks processed
// (for BRAND groups a processed top hit is exactly what we want).
//
// Run locally (needs internet — makes ~200 API calls, ~2-3 min):
//   dart run tool/search_ranking_check.dart          // top-1 + flags
//   dart run tool/search_ranking_check.dart --top3   // top-3 details

import 'package:carby/services/open_food_facts_service.dart';

/// (label, expectRaw, terms)
const groups = <(String, bool, List<String>)>[
  ('Gemüse', true, [
    'Paprika', 'Tomaten', 'Cherrytomaten', 'Zwiebeln', 'Knoblauch',
    'Kartoffeln', 'Süßkartoffeln', 'Brokkoli', 'Blumenkohl', 'Zucchini',
    'Aubergine', 'Champignons', 'Kopfsalat', 'Eisbergsalat', 'Rucola',
    'Spinat', 'Lauch', 'Sellerie', 'Rote Bete', 'Radieschen', 'Kohlrabi',
    'Weißkohl', 'Rotkohl', 'Wirsing', 'Spargel', 'Fenchel', 'Grüne Bohnen',
    'Chinakohl', 'Ingwer', 'Chili', 'Gurken', 'Karotten', 'Möhren',
    'Rosenkohl', 'Grünkohl', 'Mais',
  ]),
  ('Obst', true, [
    'Apfel', 'Banane', 'Birne', 'Orange', 'Zitrone', 'Limetten', 'Trauben',
    'Erdbeeren', 'Himbeeren', 'Blaubeeren', 'Pflaumen', 'Pfirsiche',
    'Aprikosen', 'Honigmelone', 'Wassermelone', 'Ananas', 'Feigen', 'Datteln',
    'Grapefruit', 'Clementinen', 'Mandarinen', 'Kirschen', 'Nektarinen',
    'Zwetschgen', 'Kaki', 'Granatapfel', 'Kiwi', 'Mango', 'Physalis',
    'Rhabarber', 'Stachelbeeren', 'Johannisbeeren', 'Avocado',
  ]),
  ('Fleisch (roh)', true, [
    'Hähnchenbrust', 'Hähnchenschenkel', 'Rinderhack', 'Schweinehack',
    'Gulasch', 'Schnitzel', 'Rindersteak', 'Steak', 'Ente', 'Pute',
    'Putenbrust', 'Rindfleisch', 'Schweinefleisch',
  ]),
  ('Fisch (roh)', true, [
    'Lachs', 'Thunfisch', 'Forelle', 'Kabeljau', 'Scholle', 'Hering',
    'Garnelen', 'Makrele', 'Sardinen',
  ]),
  ('Grundnahrung', true, [
    'Reis', 'Basmatireis', 'Spaghetti', 'Penne', 'Nudeln', 'Mehl', 'Zucker',
    'Salz', 'Haferflocken', 'Linsen', 'Kichererbsen', 'Couscous', 'Bulgur',
    'Quinoa', 'Grieß', 'Mandeln', 'Walnüsse', 'Cashew', 'Hirse', 'Dinkel',
  ]),
  ('Milch & Käse (Basis)', true, [
    'Vollmilch', 'Milch', 'Fettarme Milch', 'Joghurt Natur',
    'Griechischer Joghurt', 'Skyr', 'Quark', 'Butter', 'Gouda', 'Emmentaler',
    'Edamer', 'Mozzarella', 'Feta', 'Parmesan', 'Camembert', 'Frischkäse',
    'Sahne', 'Eier',
  ]),
  ('Öle & Gewürze (pur)', true, [
    'Olivenöl', 'Sonnenblumenöl', 'Rapsöl', 'Pfeffer', 'Zimt', 'Muskat',
    'Honig',
  ]),
  // ---- BRAND / processed: the searched product should be #1 (not flagged) ----
  ('Softdrinks', false, [
    'Energy Drink', 'Cola', 'Spezi', 'Fanta', 'Sprite', 'Pepsi',
    'Tonic Water', 'Ginger Ale', 'Eistee', 'Limonade', 'Apfelschorle',
    'Orangensaft', 'Multivitaminsaft', 'Traubensaft', 'Mineralwasser',
  ]),
  ('Kaffee & Tee', false, [
    'Kaffee gemahlen', 'Kaffeebohnen', 'Instantkaffee', 'Kaffeepads',
    'Schwarztee', 'Grüntee', 'Kräutertee', 'Früchtetee', 'Kakaopulver',
  ]),
  ('Alkohol', false, [
    'Bier', 'Pils', 'Weizenbier', 'Radler', 'Alkoholfreies Bier', 'Rotwein',
    'Weißwein', 'Sekt',
  ]),
  ('Milchgetränke/verarbeitet', false, [
    'Müllermilch', 'Buttermilch', 'Kefir', 'Hafermilch', 'Mandelmilch',
    'Sojamilch', 'Fruchtjoghurt', 'Schlagsahne', 'Saure Sahne',
    'Crème fraîche', 'Margarine', 'Schmand', 'Kondensmilch',
  ]),
  ('Süßwaren & Snacks', false, [
    'Nutella', 'Schokolade', 'Chips', 'Maxi King', 'Toffifee', 'Kinder Bueno',
    'Fruchtgummi', 'Lakritze', 'Gummibärchen', 'Kekse', 'Butterkekse',
    'Salzstangen', 'Erdnussflips', 'Popcorn', 'Studentenfutter', 'Müsliriegel',
    'Schokoriegel', 'Pralinen', 'Spekulatius', 'Erdnüsse', 'Rosinen',
    'Kaugummi',
  ]),
  ('Backwaren', false, [
    'Toastbrot', 'Mischbrot', 'Vollkornbrot', 'Roggenbrot', 'Baguette',
    'Brötchen', 'Croissant', 'Laugenbrezel', 'Zwieback', 'Knäckebrot',
    'Muffins', 'Donuts', 'Waffeln', 'Tortilla-Wraps', 'Pita-Brot', 'Ciabatta',
    'Dinkelbrot',
  ]),
  ('Tiefkühl', false, [
    'TK-Pizza', 'TK-Pommes', 'Ofenpommes', 'TK-Gemüsemischung', 'TK-Erbsen',
    'TK-Spinat', 'TK-Lasagne', 'Vanilleeis', 'Schokoeis', 'Chicken Nuggets',
    'TK-Rösti', 'Fischstäbchen',
  ]),
  ('Wurst/verarbeitet', false, [
    'Bratwurst', 'Currywurst', 'Wiener Würstchen', 'Salami', 'Kochschinken',
    'Rohschinken', 'Schinken', 'Speck', 'Bacon', 'Leberkäse', 'Mortadella',
    'Frikadellen', 'Kabanossi', 'Lyoner', 'Fleischwurst', 'Mettwurst',
  ]),
  ('Konserven', false, [
    'Tomatenmark', 'Tomaten passiert', 'Kidneybohnen', 'Sauerkraut',
    'Saure Gurken', 'Oliven', 'Pesto', 'Ravioli Dose', 'Mais Dose',
    'Ananas Dose', 'Räucherlachs', 'Surimi', 'Matjes', 'Rollmops',
  ]),
  ('Saucen & Fertig', false, [
    'Ketchup', 'Mayonnaise', 'Senf', 'Sojasauce', 'Sriracha',
    'Barbecue-Sauce', 'Gemüsebrühe', 'Instant-Nudeln', 'Fertigsuppe',
    'Kartoffelsalat', 'Currypulver', 'Paprikapulver',
  ]),
  ('Aufstriche & Frühstück', false, [
    'Marmelade', 'Erdnussbutter', 'Schoko-Aufstrich', 'Leberwurst',
    'Ahornsirup', 'Müsli', 'Cornflakes', 'Porridge',
  ]),
];

const _processedHints = <String>[
  'chips', 'snack', 'sauce', 'soße', 'frikassee', 'nuggets', 'gewürz',
  'würz', 'pulver', 'riegel', 'sticks', 'wurst', 'aufstrich', 'creme',
  'paniert', 'saft', 'getrocknet', ' mit ', ' & ', '+',
];

Future<void> main(List<String> args) async {
  final showTop3 = args.contains('--top3');
  final api = OpenFoodFactsService();
  var totalFlagged = 0;
  var totalEmpty = 0;
  var totalTerms = 0;

  for (final (label, expectRaw, terms) in groups) {
    print('\n=== $label  (${expectRaw ? 'RAW' : 'BRAND'}) ===');
    var flagged = 0;
    var empty = 0;
    for (final term in terms) {
      totalTerms++;
      final res = await api.searchFood(term);
      if (res.isEmpty) {
        empty++;
        totalEmpty++;
        print('${term.padRight(20)} -> (keine Ergebnisse)');
        continue;
      }
      final top = res.first.name;
      final low = top.toLowerCase();
      final suspicious = expectRaw && _processedHints.any(low.contains);
      if (suspicious) flagged++;
      print('${term.padRight(20)} -> $top${suspicious ? '   <-- PRUEFEN' : ''}');
      if (showTop3) {
        for (final f in res.take(3).skip(1)) {
          print('${''.padRight(23)}$f');
        }
      }
    }
    totalFlagged += flagged;
    if (expectRaw) {
      print('  [$label] $flagged verdächtig, $empty leer von ${terms.length}');
    } else {
      print('  [$label] $empty leer von ${terms.length}');
    }
  }

  print('\n================ ZUSAMMENFASSUNG ================');
  print('$totalTerms Begriffe getestet.');
  print('$totalFlagged RAW-Top-Treffer wirken verarbeitet (bitte pruefen).');
  print('$totalEmpty Begriffe ohne Ergebnis.');
}
