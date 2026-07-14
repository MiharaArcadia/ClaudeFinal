import 'package:carby/models/food_model.dart';

/// A curated entry: German name, search aliases (plurals/synonyms) and
/// per-100 g macros. Values are standard reference values (USDA/BLS-typical).
class _CF {
  final String name;
  final List<String> aliases;
  final double kcal, protein, carbs, fat, fiber, sugar, salt, portion;
  const _CF(this.name, this.aliases, this.kcal, this.protein, this.carbs,
      this.fat, this.fiber, this.sugar, this.salt, this.portion);
}

/// Curated database of the most common German foods, searched BEFORE the API
/// so everyday terms always resolve instantly with clean names and correct
/// nutrition — offline included.
class CommonFoods {
  static Food _toFood(_CF c) => Food(
        id: 'curated:${c.name.toLowerCase()}',
        name: c.name,
        imageUrl: '',
        brand: '',
        calories: c.kcal,
        protein: c.protein,
        carbs: c.carbs,
        fat: c.fat,
        fiber: c.fiber,
        sugar: c.sugar,
        salt: c.salt,
        defaultPortionGrams: c.portion,
      );

  /// Relevance-ranked curated matches for [query]. Empty if nothing matches.
  static List<Food> search(String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return [];

    int rankOf(_CF c) {
      var best = 0;
      for (final raw in [c.name, ...c.aliases]) {
        final t = raw.toLowerCase();
        final words = t.split(RegExp(r'[^a-z0-9äöüß]+'));
        var r = 0;
        if (t == q) {
          r = 100;
        } else if (words.contains(q)) {
          r = 60;
        } else if (t.startsWith(q)) {
          r = 40;
        } else if (t.contains(q)) {
          r = 20;
        } else if (q.length >= 4 && q.contains(t)) {
          r = 15;
        }
        if (r > best) best = r;
      }
      return best;
    }

    final scored = <(_CF, int)>[];
    for (final c in items) {
      final r = rankOf(c);
      if (r > 0) scored.add((c, r));
    }
    scored.sort((a, b) => b.$2.compareTo(a.$2));
    return scored.map((e) => _toFood(e.$1)).toList();
  }

  // name, aliases, kcal, protein, carbs, fat, fiber, sugar, salt(g), portion(g)
  static const List<_CF> items = [
    // ---------------- Gemüse ----------------
    _CF('Paprika', ['paprikas', 'paprikaschote', 'gemüsepaprika'], 31, 1.0, 6.0, 0.3, 2.1, 4.2, 0.01, 120),
    _CF('Tomate', ['tomaten', 'cherrytomaten', 'cherrytomate'], 18, 0.9, 3.9, 0.2, 1.2, 2.6, 0.01, 100),
    _CF('Gurke', ['gurken', 'salatgurke'], 15, 0.7, 3.6, 0.1, 0.5, 1.7, 0.0, 100),
    _CF('Karotte', ['karotten', 'möhre', 'möhren', 'mohrrübe', 'mohrrüben'], 41, 0.9, 10.0, 0.2, 2.8, 4.7, 0.07, 80),
    _CF('Zwiebel', ['zwiebeln'], 40, 1.1, 9.3, 0.1, 1.7, 4.2, 0.0, 60),
    _CF('Knoblauch', ['knoblauchzehe'], 149, 6.4, 33.0, 0.5, 2.1, 1.0, 0.02, 5),
    _CF('Kartoffel', ['kartoffeln', 'erdapfel'], 77, 2.0, 17.0, 0.1, 2.2, 0.8, 0.0, 150),
    _CF('Süßkartoffel', ['süßkartoffeln', 'batate'], 86, 1.6, 20.0, 0.1, 3.0, 4.2, 0.05, 150),
    _CF('Brokkoli', [], 34, 2.8, 7.0, 0.4, 2.6, 1.7, 0.03, 100),
    _CF('Blumenkohl', [], 25, 1.9, 5.0, 0.3, 2.0, 1.9, 0.03, 100),
    _CF('Spinat', ['blattspinat'], 23, 2.9, 3.6, 0.4, 2.2, 0.4, 0.08, 100),
    _CF('Zucchini', [], 17, 1.2, 3.1, 0.3, 1.0, 2.5, 0.01, 150),
    _CF('Aubergine', ['auberginen'], 25, 1.0, 6.0, 0.2, 3.0, 3.5, 0.0, 120),
    _CF('Lauch', ['porree'], 61, 1.5, 14.0, 0.3, 1.8, 3.9, 0.02, 100),
    _CF('Sellerie', ['staudensellerie', 'knollensellerie'], 16, 0.7, 3.0, 0.2, 1.6, 1.8, 0.08, 80),
    _CF('Kürbis', ['hokkaido'], 26, 1.0, 6.5, 0.1, 0.5, 2.8, 0.0, 200),
    _CF('Rote Bete', ['rote beete', 'rande'], 43, 1.6, 10.0, 0.2, 2.8, 6.8, 0.08, 100),
    _CF('Rettich', [], 14, 0.6, 3.4, 0.1, 1.6, 1.9, 0.02, 100),
    _CF('Radieschen', [], 16, 0.7, 3.4, 0.1, 1.6, 1.9, 0.04, 30),
    _CF('Fenchel', [], 31, 1.2, 7.3, 0.2, 3.1, 3.9, 0.05, 100),
    _CF('Spargel', [], 20, 2.2, 3.9, 0.1, 2.1, 1.9, 0.0, 150),
    _CF('Erbsen', ['erbse'], 81, 5.4, 14.0, 0.4, 5.1, 5.7, 0.0, 80),
    _CF('Grüne Bohnen', ['bohnen', 'buschbohnen'], 31, 1.8, 7.0, 0.1, 3.4, 3.3, 0.0, 100),
    _CF('Mais', ['zuckermais'], 86, 3.2, 19.0, 1.2, 2.7, 3.2, 0.0, 80),
    _CF('Champignon', ['champignons', 'pilze', 'pilz'], 22, 3.1, 3.3, 0.3, 1.0, 2.0, 0.01, 80),
    _CF('Rosenkohl', [], 43, 3.4, 9.0, 0.3, 3.8, 2.2, 0.03, 100),
    _CF('Grünkohl', [], 49, 4.3, 9.0, 0.9, 4.1, 2.3, 0.09, 100),
    _CF('Chinakohl', [], 16, 1.2, 3.2, 0.2, 1.2, 1.4, 0.01, 100),
    _CF('Weißkohl', ['weisskohl'], 25, 1.3, 5.8, 0.1, 2.5, 3.2, 0.02, 100),
    _CF('Rotkohl', ['blaukraut'], 31, 1.4, 7.0, 0.2, 2.5, 3.8, 0.06, 100),
    _CF('Wirsing', [], 27, 2.0, 6.1, 0.1, 3.0, 2.3, 0.05, 100),
    _CF('Kohlrabi', [], 27, 1.7, 6.2, 0.1, 3.6, 2.6, 0.02, 100),
    _CF('Kopfsalat', ['salat', 'blattsalat'], 14, 1.4, 2.9, 0.2, 1.3, 0.8, 0.03, 50),
    _CF('Eisbergsalat', [], 14, 0.9, 3.0, 0.1, 1.2, 2.0, 0.02, 50),
    _CF('Rucola', ['rauke'], 25, 2.6, 3.7, 0.7, 1.6, 2.1, 0.07, 30),
    _CF('Ingwer', [], 80, 1.8, 18.0, 0.8, 2.0, 1.7, 0.03, 10),
    _CF('Chili', ['chilischote', 'peperoni'], 40, 1.9, 9.0, 0.4, 1.5, 5.3, 0.02, 15),
    // ---------------- Obst ----------------
    _CF('Apfel', ['äpfel'], 52, 0.3, 14.0, 0.2, 2.4, 10.4, 0.0, 150),
    _CF('Banane', ['bananen'], 89, 1.1, 23.0, 0.3, 2.6, 12.0, 0.0, 120),
    _CF('Birne', ['birnen'], 57, 0.4, 15.0, 0.1, 3.1, 9.8, 0.0, 150),
    _CF('Orange', ['orangen', 'apfelsine'], 47, 0.9, 12.0, 0.1, 2.4, 9.4, 0.0, 130),
    _CF('Zitrone', ['zitronen'], 29, 1.1, 9.0, 0.3, 2.8, 2.5, 0.0, 60),
    _CF('Limette', ['limetten'], 30, 0.7, 11.0, 0.2, 2.8, 1.7, 0.0, 60),
    _CF('Traube', ['trauben', 'weintrauben'], 69, 0.7, 18.0, 0.2, 0.9, 16.0, 0.0, 100),
    _CF('Erdbeere', ['erdbeeren'], 32, 0.7, 7.7, 0.3, 2.0, 4.9, 0.0, 100),
    _CF('Himbeere', ['himbeeren'], 52, 1.2, 12.0, 0.7, 6.5, 4.4, 0.0, 100),
    _CF('Blaubeere', ['blaubeeren', 'heidelbeere', 'heidelbeeren'], 57, 0.7, 14.0, 0.3, 2.4, 10.0, 0.0, 100),
    _CF('Kirsche', ['kirschen'], 63, 1.1, 16.0, 0.2, 2.1, 13.0, 0.0, 100),
    _CF('Pfirsich', ['pfirsiche'], 39, 0.9, 10.0, 0.3, 1.5, 8.4, 0.0, 150),
    _CF('Nektarine', ['nektarinen'], 44, 1.1, 11.0, 0.3, 1.7, 8.0, 0.0, 140),
    _CF('Aprikose', ['aprikosen', 'marille'], 48, 1.4, 11.0, 0.4, 2.0, 9.2, 0.0, 40),
    _CF('Pflaume', ['pflaumen', 'zwetschge', 'zwetschgen'], 46, 0.7, 11.0, 0.3, 1.4, 10.0, 0.0, 60),
    _CF('Ananas', [], 50, 0.5, 13.0, 0.1, 1.4, 10.0, 0.0, 150),
    _CF('Mango', ['mangos'], 60, 0.8, 15.0, 0.4, 1.6, 14.0, 0.0, 150),
    _CF('Kiwi', ['kiwis'], 61, 1.1, 15.0, 0.5, 3.0, 9.0, 0.0, 75),
    _CF('Wassermelone', [], 30, 0.6, 8.0, 0.2, 0.4, 6.2, 0.0, 200),
    _CF('Melone', ['honigmelone', 'cantaloupe'], 34, 0.8, 8.0, 0.2, 0.9, 8.0, 0.0, 200),
    _CF('Feige', ['feigen'], 74, 0.8, 19.0, 0.3, 2.9, 16.0, 0.0, 50),
    _CF('Dattel', ['datteln'], 282, 2.5, 75.0, 0.4, 8.0, 63.0, 0.0, 25),
    _CF('Grapefruit', ['pampelmuse'], 42, 0.8, 11.0, 0.1, 1.6, 7.0, 0.0, 150),
    _CF('Mandarine', ['mandarinen', 'clementine', 'clementinen'], 53, 0.8, 13.0, 0.3, 1.8, 11.0, 0.0, 80),
    _CF('Granatapfel', [], 83, 1.7, 19.0, 1.2, 4.0, 14.0, 0.0, 150),
    _CF('Avocado', ['avocados'], 160, 2.0, 9.0, 15.0, 6.7, 0.7, 0.0, 150),
    _CF('Kaki', ['sharon'], 70, 0.6, 18.0, 0.2, 3.6, 13.0, 0.0, 150),
    _CF('Rhabarber', [], 21, 0.9, 4.5, 0.2, 1.8, 1.1, 0.0, 100),
    _CF('Stachelbeere', ['stachelbeeren'], 44, 0.9, 10.0, 0.6, 4.3, 8.0, 0.0, 100),
    _CF('Johannisbeere', ['johannisbeeren'], 56, 1.4, 14.0, 0.2, 4.3, 8.0, 0.0, 100),
    _CF('Physalis', [], 53, 1.9, 11.0, 0.7, 2.4, 4.0, 0.0, 50),
    // ---------------- Fleisch (roh) ----------------
    _CF('Hähnchenbrust', ['hähnchen', 'hühnerbrust', 'hähnchenbrustfilet'], 165, 31.0, 0.0, 3.6, 0.0, 0.0, 0.07, 150),
    _CF('Hähnchenschenkel', ['hühnerschenkel'], 209, 18.0, 0.0, 15.0, 0.0, 0.0, 0.09, 150),
    _CF('Putenbrust', ['pute', 'truthahn'], 135, 29.0, 0.0, 1.7, 0.0, 0.0, 0.05, 150),
    _CF('Rindfleisch', ['rind'], 217, 26.0, 0.0, 12.0, 0.0, 0.0, 0.07, 150),
    _CF('Rinderhack', ['rinderhackfleisch'], 254, 17.0, 0.0, 20.0, 0.0, 0.0, 0.1, 125),
    _CF('Hackfleisch', ['gemischtes hackfleisch', 'gehacktes'], 250, 18.0, 0.0, 20.0, 0.0, 0.0, 0.1, 125),
    _CF('Schweinehack', ['schweinehackfleisch'], 263, 17.0, 0.0, 22.0, 0.0, 0.0, 0.1, 125),
    _CF('Schweinefleisch', ['schwein', 'schweinefilet'], 242, 27.0, 0.0, 14.0, 0.0, 0.0, 0.06, 150),
    _CF('Rindersteak', ['steak', 'rumpsteak'], 271, 25.0, 0.0, 19.0, 0.0, 0.0, 0.07, 200),
    _CF('Schnitzel', ['schweineschnitzel'], 172, 30.0, 0.0, 5.0, 0.0, 0.0, 0.1, 150),
    _CF('Gulasch', [], 190, 20.0, 2.0, 11.0, 0.0, 0.5, 0.4, 200),
    _CF('Ente', ['entenbrust'], 337, 19.0, 0.0, 28.0, 0.0, 0.0, 0.08, 150),
    _CF('Lamm', ['lammfleisch'], 294, 25.0, 0.0, 21.0, 0.0, 0.0, 0.07, 150),
    // ---------------- Fisch (roh) ----------------
    _CF('Lachs', ['lachsfilet'], 208, 20.0, 0.0, 13.0, 0.0, 0.0, 0.05, 150),
    _CF('Thunfisch', [], 144, 23.0, 0.0, 5.0, 0.0, 0.0, 0.05, 150),
    _CF('Forelle', [], 119, 20.0, 0.0, 3.5, 0.0, 0.0, 0.05, 150),
    _CF('Kabeljau', ['dorsch'], 82, 18.0, 0.0, 0.7, 0.0, 0.0, 0.2, 150),
    _CF('Scholle', [], 86, 17.0, 0.0, 1.9, 0.0, 0.0, 0.2, 150),
    _CF('Hering', [], 158, 18.0, 0.0, 9.0, 0.0, 0.0, 0.1, 100),
    _CF('Makrele', [], 205, 19.0, 0.0, 14.0, 0.0, 0.0, 0.16, 150),
    _CF('Sardine', ['sardinen'], 208, 25.0, 0.0, 11.0, 0.0, 0.0, 0.5, 100),
    _CF('Garnelen', ['garnele', 'shrimps', 'scampi'], 99, 24.0, 0.2, 0.3, 0.0, 0.0, 0.5, 100),
    // ---------------- Eier ----------------
    _CF('Ei', ['eier', 'hühnerei'], 155, 13.0, 1.1, 11.0, 0.0, 1.1, 0.4, 60),
    // ---------------- Grundnahrung ----------------
    _CF('Reis', ['basmatireis', 'jasminreis', 'langkornreis'], 130, 2.7, 28.0, 0.3, 0.4, 0.1, 0.0, 180),
    _CF('Nudeln', ['pasta', 'spaghetti', 'penne', 'makkaroni'], 158, 6.0, 31.0, 0.9, 1.8, 0.6, 0.0, 200),
    _CF('Haferflocken', ['haferflocke', 'oats'], 372, 13.0, 59.0, 7.0, 10.0, 1.0, 0.0, 60),
    _CF('Müsli', ['muesli'], 360, 9.0, 60.0, 8.0, 8.0, 18.0, 0.1, 60),
    _CF('Cornflakes', [], 378, 7.0, 84.0, 0.9, 3.0, 8.0, 1.1, 40),
    _CF('Mehl', ['weizenmehl'], 341, 10.0, 72.0, 1.0, 2.7, 0.7, 0.0, 100),
    _CF('Zucker', ['haushaltszucker'], 400, 0.0, 100.0, 0.0, 0.0, 100.0, 0.0, 10),
    _CF('Salz', ['kochsalz', 'speisesalz'], 0, 0.0, 0.0, 0.0, 0.0, 0.0, 100.0, 2),
    _CF('Linsen', ['linse', 'rote linsen'], 116, 9.0, 20.0, 0.4, 8.0, 1.8, 0.0, 60),
    _CF('Kichererbsen', ['kichererbse'], 164, 8.9, 27.0, 2.6, 7.6, 4.8, 0.0, 60),
    _CF('Bohnen', ['kidneybohnen', 'weiße bohnen'], 127, 8.7, 23.0, 0.5, 6.4, 0.3, 0.0, 60),
    _CF('Couscous', [], 112, 3.8, 23.0, 0.2, 1.4, 0.1, 0.0, 60),
    _CF('Bulgur', [], 83, 3.1, 19.0, 0.2, 4.5, 0.1, 0.0, 60),
    _CF('Quinoa', [], 120, 4.4, 21.0, 1.9, 2.8, 0.9, 0.0, 60),
    _CF('Grieß', ['hartweizengrieß'], 360, 12.0, 73.0, 1.0, 3.9, 1.0, 0.0, 60),
    _CF('Hirse', [], 378, 11.0, 73.0, 4.2, 8.5, 0.0, 0.0, 60),
    _CF('Dinkel', ['dinkelkorn'], 338, 15.0, 70.0, 2.4, 11.0, 0.0, 0.0, 60),
    _CF('Mandeln', ['mandel'], 579, 21.0, 22.0, 50.0, 12.0, 4.4, 0.0, 25),
    _CF('Walnüsse', ['walnuss'], 654, 15.0, 14.0, 65.0, 6.7, 2.6, 0.0, 25),
    _CF('Cashewkerne', ['cashew', 'cashews'], 553, 18.0, 30.0, 44.0, 3.3, 5.9, 0.0, 25),
    _CF('Erdnüsse', ['erdnuss'], 567, 26.0, 16.0, 49.0, 8.5, 4.7, 0.01, 25),
    _CF('Haselnüsse', ['haselnuss'], 628, 15.0, 17.0, 61.0, 10.0, 4.3, 0.0, 25),
    _CF('Rosinen', ['rosine'], 299, 3.1, 79.0, 0.5, 3.7, 59.0, 0.02, 25),
    _CF('Tofu', [], 76, 8.0, 1.9, 4.8, 0.3, 0.6, 0.0, 100),
    // ---------------- Milch & Käse (Basis) ----------------
    _CF('Milch', ['vollmilch', 'kuhmilch'], 64, 3.4, 4.8, 3.6, 0.0, 4.8, 0.1, 200),
    _CF('Fettarme Milch', ['magermilch'], 47, 3.4, 4.9, 1.5, 0.0, 4.9, 0.1, 200),
    _CF('Hafermilch', ['haferdrink'], 45, 1.0, 6.7, 1.5, 0.8, 3.3, 0.1, 200),
    _CF('Mandelmilch', ['mandeldrink'], 24, 0.5, 3.0, 1.1, 0.4, 2.5, 0.1, 200),
    _CF('Sojamilch', ['sojadrink', 'soja'], 42, 3.3, 1.6, 1.8, 0.6, 1.0, 0.1, 200),
    _CF('Joghurt', ['naturjoghurt', 'joghurt natur'], 61, 3.5, 4.7, 3.3, 0.0, 4.7, 0.1, 150),
    _CF('Griechischer Joghurt', ['grieche'], 97, 9.0, 4.0, 5.0, 0.0, 4.0, 0.1, 150),
    _CF('Skyr', [], 63, 11.0, 4.0, 0.2, 0.0, 4.0, 0.1, 150),
    _CF('Quark', ['magerquark', 'speisequark'], 67, 12.0, 4.0, 0.3, 0.0, 4.0, 0.1, 150),
    _CF('Sahne', ['schlagsahne', 'schlagobers'], 292, 2.4, 3.3, 30.0, 0.0, 3.3, 0.1, 30),
    _CF('Saure Sahne', ['schmand'], 162, 2.8, 3.6, 15.0, 0.0, 3.6, 0.1, 30),
    _CF('Crème fraîche', ['creme fraiche'], 292, 2.4, 3.0, 30.0, 0.0, 3.0, 0.1, 30),
    _CF('Butter', [], 717, 0.7, 0.7, 81.0, 0.0, 0.7, 1.1, 15),
    _CF('Margarine', [], 720, 0.2, 0.4, 80.0, 0.0, 0.4, 1.0, 15),
    _CF('Frischkäse', ['streichkäse'], 253, 6.0, 3.5, 24.0, 0.0, 3.0, 0.7, 30),
    _CF('Gouda', [], 356, 25.0, 2.2, 27.0, 0.0, 2.2, 1.8, 30),
    _CF('Emmentaler', [], 380, 29.0, 0.0, 29.0, 0.0, 0.0, 0.7, 30),
    _CF('Edamer', [], 330, 26.0, 0.0, 25.0, 0.0, 0.0, 1.8, 30),
    _CF('Mozzarella', [], 253, 18.0, 1.0, 20.0, 0.0, 1.0, 0.7, 50),
    _CF('Feta', [], 264, 14.0, 4.1, 21.0, 0.0, 4.1, 3.0, 30),
    _CF('Parmesan', [], 431, 38.0, 4.1, 29.0, 0.0, 0.9, 1.6, 15),
    _CF('Camembert', [], 300, 20.0, 0.5, 24.0, 0.0, 0.5, 1.9, 30),
    // ---------------- Öle & Gewürze (pur) ----------------
    _CF('Olivenöl', ['olivenoel'], 884, 0.0, 0.0, 100.0, 0.0, 0.0, 0.0, 10),
    _CF('Sonnenblumenöl', [], 884, 0.0, 0.0, 100.0, 0.0, 0.0, 0.0, 10),
    _CF('Rapsöl', [], 884, 0.0, 0.0, 100.0, 0.0, 0.0, 0.0, 10),
    _CF('Pfeffer', ['schwarzer pfeffer'], 251, 10.0, 64.0, 3.3, 25.0, 0.6, 0.0, 1),
    _CF('Zimt', [], 247, 4.0, 81.0, 1.2, 53.0, 2.2, 0.0, 1),
    _CF('Honig', [], 304, 0.3, 82.0, 0.0, 0.2, 82.0, 0.0, 20),
    // ---------------- Softdrinks & Getränke ----------------
    _CF('Cola', ['coca-cola', 'coca cola', 'coke'], 42, 0.0, 10.6, 0.0, 0.0, 10.6, 0.0, 330),
    _CF('Fanta', ['orangenlimonade'], 46, 0.0, 11.0, 0.0, 0.0, 11.0, 0.0, 330),
    _CF('Sprite', [], 37, 0.0, 9.0, 0.0, 0.0, 9.0, 0.0, 330),
    _CF('Pepsi', [], 43, 0.0, 11.0, 0.0, 0.0, 11.0, 0.0, 330),
    _CF('Spezi', ['cola-mix'], 44, 0.0, 11.0, 0.0, 0.0, 11.0, 0.0, 330),
    _CF('Energy Drink', ['energydrink', 'red bull', 'monster'], 45, 0.0, 11.0, 0.0, 0.0, 11.0, 0.1, 250),
    _CF('Eistee', ['ice tea'], 30, 0.0, 7.5, 0.0, 0.0, 7.0, 0.0, 330),
    _CF('Limonade', ['limo'], 38, 0.0, 9.0, 0.0, 0.0, 9.0, 0.0, 330),
    _CF('Apfelschorle', [], 22, 0.1, 5.3, 0.0, 0.0, 5.0, 0.0, 330),
    _CF('Orangensaft', ['o-saft'], 45, 0.7, 10.0, 0.2, 0.2, 8.4, 0.0, 200),
    _CF('Apfelsaft', [], 46, 0.1, 11.0, 0.1, 0.1, 10.0, 0.0, 200),
    _CF('Traubensaft', [], 60, 0.4, 15.0, 0.1, 0.0, 15.0, 0.0, 200),
    _CF('Multivitaminsaft', ['multivitamin'], 52, 0.4, 12.0, 0.1, 0.2, 11.0, 0.0, 200),
    _CF('Mineralwasser', ['wasser', 'sprudel'], 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 500),
    _CF('Bier', ['pils', 'lager', 'helles'], 43, 0.5, 3.6, 0.0, 0.0, 0.0, 0.0, 500),
    _CF('Weizenbier', ['hefeweizen'], 45, 0.5, 3.8, 0.0, 0.0, 0.0, 0.0, 500),
    _CF('Radler', [], 40, 0.3, 5.0, 0.0, 0.0, 4.0, 0.0, 500),
    _CF('Rotwein', [], 85, 0.1, 2.6, 0.0, 0.0, 0.6, 0.0, 150),
    _CF('Weißwein', ['weisswein'], 82, 0.1, 2.6, 0.0, 0.0, 1.0, 0.0, 150),
    _CF('Sekt', ['prosecco', 'champagner'], 80, 0.2, 1.5, 0.0, 0.0, 1.0, 0.0, 100),
    _CF('Kaffee', ['schwarzkaffee', 'filterkaffee'], 2, 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 200),
    _CF('Kaffeebohnen', ['kaffee gemahlen', 'espresso'], 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 8),
    _CF('Schwarztee', ['tee'], 1, 0.0, 0.2, 0.0, 0.0, 0.0, 0.0, 200),
    _CF('Grüntee', ['grüner tee'], 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 200),
    _CF('Kakaopulver', ['kakao'], 343, 20.0, 55.0, 11.0, 33.0, 0.8, 0.2, 10),
    _CF('Buttermilch', [], 37, 3.5, 4.0, 0.5, 0.0, 4.0, 0.1, 200),
    _CF('Kefir', [], 66, 3.3, 4.0, 3.5, 0.0, 4.0, 0.1, 200),
    // ---------------- Süßwaren & Snacks ----------------
    _CF('Nutella', ['nuss-nougat-creme', 'schoko-aufstrich'], 539, 6.3, 57.0, 31.0, 0.0, 56.0, 0.1, 15),
    _CF('Schokolade', ['tafel schokolade', 'vollmilchschokolade'], 535, 7.7, 59.0, 30.0, 3.4, 52.0, 0.2, 25),
    _CF('Chips', ['kartoffelchips'], 536, 6.6, 50.0, 34.0, 4.4, 0.6, 1.5, 30),
    _CF('Gummibärchen', ['fruchtgummi', 'gummibaerchen'], 343, 6.9, 77.0, 0.2, 0.0, 46.0, 0.1, 30),
    _CF('Lakritze', ['lakritz'], 375, 3.9, 82.0, 1.5, 0.0, 55.0, 1.5, 30),
    _CF('Kekse', ['keks', 'butterkekse'], 480, 6.0, 68.0, 20.0, 2.0, 25.0, 0.5, 30),
    _CF('Salzstangen', ['brezeln', 'salzbrezel'], 380, 10.0, 78.0, 2.5, 3.0, 2.0, 3.5, 30),
    _CF('Popcorn', [], 387, 12.0, 78.0, 4.5, 14.0, 0.9, 1.0, 30),
    _CF('Studentenfutter', [], 484, 14.0, 38.0, 30.0, 6.0, 30.0, 0.0, 30),
    _CF('Müsliriegel', [], 400, 6.0, 65.0, 12.0, 5.0, 30.0, 0.3, 25),
    _CF('Schokoriegel', [], 480, 5.0, 60.0, 24.0, 2.0, 50.0, 0.3, 50),
    _CF('Pralinen', ['praline'], 520, 6.0, 55.0, 30.0, 2.5, 48.0, 0.1, 25),
    _CF('Kaugummi', [], 268, 0.0, 65.0, 0.3, 0.0, 60.0, 0.0, 3),
    // ---------------- Backwaren ----------------
    _CF('Toastbrot', ['toast'], 273, 8.0, 50.0, 4.0, 3.0, 4.0, 1.0, 25),
    _CF('Mischbrot', ['graubrot'], 250, 7.0, 48.0, 1.2, 4.5, 1.5, 1.1, 50),
    _CF('Vollkornbrot', [], 200, 7.0, 36.0, 3.4, 7.4, 2.0, 1.1, 50),
    _CF('Roggenbrot', [], 219, 6.0, 44.0, 1.3, 6.0, 1.4, 1.1, 50),
    _CF('Baguette', [], 274, 9.0, 55.0, 1.5, 3.0, 2.5, 1.2, 50),
    _CF('Brötchen', ['semmel', 'weckle'], 265, 9.0, 52.0, 1.5, 3.0, 2.0, 1.2, 60),
    _CF('Croissant', [], 406, 8.0, 46.0, 21.0, 2.6, 11.0, 0.9, 60),
    _CF('Laugenbrezel', ['brezel'], 289, 9.0, 55.0, 3.5, 2.5, 2.0, 3.0, 80),
    _CF('Knäckebrot', [], 334, 10.0, 65.0, 2.5, 15.0, 1.0, 1.3, 20),
    _CF('Zwieback', [], 374, 10.0, 74.0, 4.0, 4.0, 12.0, 0.8, 15),
    _CF('Dinkelbrot', [], 223, 8.0, 41.0, 1.9, 6.5, 2.0, 1.1, 50),
    // ---------------- Wurst & verarbeitetes Fleisch ----------------
    _CF('Bratwurst', [], 297, 12.0, 1.0, 27.0, 0.0, 0.5, 1.8, 100),
    _CF('Currywurst', [], 280, 11.0, 6.0, 23.0, 0.0, 4.0, 1.6, 150),
    _CF('Wiener Würstchen', ['würstchen', 'wiener'], 270, 11.0, 1.0, 24.0, 0.0, 0.5, 2.0, 100),
    _CF('Salami', [], 336, 20.0, 1.5, 28.0, 0.0, 0.5, 3.7, 30),
    _CF('Schinken', ['kochschinken', 'kochschinken'], 107, 18.0, 0.5, 3.5, 0.0, 0.5, 2.3, 30),
    _CF('Rohschinken', ['serrano', 'parmaschinken'], 241, 25.0, 0.5, 15.0, 0.0, 0.0, 4.5, 30),
    _CF('Speck', ['bacon'], 541, 9.0, 0.0, 57.0, 0.0, 0.0, 1.8, 30),
    _CF('Leberkäse', [], 280, 12.0, 1.0, 25.0, 0.0, 0.5, 2.0, 100),
    _CF('Mortadella', [], 311, 16.0, 1.0, 27.0, 0.0, 0.5, 2.2, 30),
    _CF('Leberwurst', [], 326, 14.0, 2.0, 29.0, 0.0, 0.5, 1.9, 30),
    _CF('Fleischwurst', ['lyoner'], 290, 12.0, 1.0, 26.0, 0.0, 0.5, 2.2, 30),
    _CF('Frikadelle', ['frikadellen', 'bulette'], 250, 15.0, 6.0, 18.0, 0.5, 1.0, 1.2, 80),
    // ---------------- Fisch verarbeitet ----------------
    _CF('Fischstäbchen', [], 200, 12.0, 18.0, 9.0, 1.0, 1.0, 0.9, 90),
    _CF('Räucherlachs', [], 177, 18.0, 0.0, 12.0, 0.0, 0.0, 3.0, 50),
    _CF('Matjes', [], 232, 16.0, 0.0, 18.0, 0.0, 0.0, 2.5, 80),
    _CF('Surimi', [], 99, 8.0, 15.0, 1.0, 0.0, 5.0, 1.5, 100),
    // ---------------- Tiefkühl ----------------
    _CF('Pizza', ['tk-pizza', 'tiefkühlpizza'], 250, 11.0, 30.0, 9.0, 2.0, 3.0, 1.2, 350),
    _CF('Pommes', ['tk-pommes', 'ofenpommes', 'pommes frites'], 165, 3.0, 25.0, 6.0, 3.0, 0.5, 0.5, 150),
    _CF('Chicken Nuggets', ['nuggets'], 296, 15.0, 16.0, 19.0, 1.0, 0.5, 1.2, 100),
    _CF('Vanilleeis', ['eis', 'eiscreme'], 207, 3.5, 24.0, 11.0, 0.0, 21.0, 0.1, 100),
    _CF('Schokoeis', [], 216, 3.8, 28.0, 11.0, 1.0, 25.0, 0.1, 100),
    // ---------------- Konserven & Eingelegtes ----------------
    _CF('Tomatenmark', [], 82, 4.3, 15.0, 0.5, 3.0, 12.0, 0.2, 20),
    _CF('Passierte Tomaten', ['tomaten passiert', 'passata'], 35, 1.6, 6.0, 0.2, 1.5, 5.0, 0.1, 100),
    _CF('Sauerkraut', [], 19, 1.1, 3.0, 0.1, 2.2, 1.8, 0.7, 100),
    _CF('Saure Gurken', ['gewürzgurken'], 11, 0.5, 2.0, 0.1, 0.7, 1.5, 1.5, 50),
    _CF('Oliven', ['olive'], 145, 1.0, 6.0, 15.0, 3.3, 0.0, 3.3, 30),
    _CF('Pesto', [], 450, 6.0, 6.0, 45.0, 2.0, 3.0, 2.5, 25),
    // ---------------- Saucen & Fertig ----------------
    _CF('Ketchup', [], 112, 1.2, 26.0, 0.1, 0.4, 22.0, 2.0, 20),
    _CF('Mayonnaise', ['mayo'], 680, 1.1, 2.0, 74.0, 0.0, 1.5, 1.2, 20),
    _CF('Senf', [], 100, 5.0, 9.0, 5.0, 3.0, 3.0, 3.0, 10),
    _CF('Sojasauce', ['sojasoße'], 60, 8.0, 6.0, 0.1, 0.8, 1.0, 16.0, 10),
    _CF('Gemüsebrühe', ['brühe'], 20, 1.0, 3.0, 0.5, 0.0, 1.0, 6.0, 250),
    // ---------------- Aufstriche & Frühstück ----------------
    _CF('Marmelade', ['konfitüre', 'fruchtaufstrich'], 250, 0.4, 62.0, 0.1, 0.8, 58.0, 0.0, 20),
    _CF('Erdnussbutter', ['erdnussmus'], 588, 25.0, 20.0, 50.0, 6.0, 9.0, 0.4, 20),
    _CF('Ahornsirup', [], 260, 0.0, 67.0, 0.1, 0.0, 60.0, 0.0, 20),
    _CF('Porridge', ['haferbrei'], 71, 2.5, 12.0, 1.5, 1.7, 0.3, 0.0, 250),
  ];
}
