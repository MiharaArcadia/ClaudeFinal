'use strict';

// ─────────────────────────────────────────────────────────────────
// DESIGN TOKENS
// ─────────────────────────────────────────────────────────────────
const C = {
  orange: '#FF6B35', green: '#4CAF50', teal: '#00BCD4',
  purple: '#9C27B0', blue: '#2196F3', pink: '#E91E63',
  ringEmpty: '#2A2A2A', muted: '#9E9E9E',
};

// ─────────────────────────────────────────────────────────────────
// TRANSLATIONS
// ─────────────────────────────────────────────────────────────────
const T = {
  de: {
    greeting_morning: 'Guten Morgen', greeting_afternoon: 'Guten Tag', greeting_evening: 'Guten Abend',
    dash: 'Dashboard', log: 'Tagebuch', profile: 'Profil',
    cal_today: 'Kalorien heute', remaining: 'kcal verbleibend',
    gaps: 'Nährstoff-Status', reco: 'Was du noch essen solltest',
    protein: 'Protein', carbs: 'Kohlenhydrate', fat: 'Fett', fiber: 'Ballaststoffe',
    per100: 'pro 100g', avg_portion: 'Ø Portion', portion_size: 'Portionsgröße',
    nutr_table: 'Nährwerttabelle', add_btn: '➕ Zum Tagebuch hinzufügen',
    energy: 'Energie', sugar: 'Zucker', salt: 'Salz',
    add_food: 'Lebensmittel hinzufügen', speak: 'Klicken zum Sprechen',
    listening: 'Höre zu...', type_here: 'Lebensmittel eingeben...',
    today_eaten: 'Heute gegessen', no_results: 'Keine Ergebnisse',
    log_title: 'Tagebuch', nothing_logged: 'Noch nichts eingetragen.',
    speak_a_food: 'Sprich oder tippe ein Lebensmittel!',
    lang: 'Sprache', name: 'Name', age: 'Alter', weight: 'Gewicht',
    height: 'Größe', goal: 'Ziel', calgoal: 'Kalorienziel', save: 'Speichern',
    lose: 'Abnehmen', maintain: 'Halten', gain: 'Zunehmen',
    added: 'Hinzugefügt!', saved: 'Gespeichert!',
    back: '← Zurück', years: 'Jahre', kg: 'kg', cm: 'cm',
    mic_not_allowed: 'Mikrofonzugriff verweigert. Bitte in Windows-Einstellungen erlauben.',
    mic_no_audio: 'Kein Mikrofon gefunden.',
    mic_no_speech: 'Nichts verstanden. Bitte erneut versuchen.',
    mic_error: 'Spracherkennung fehlgeschlagen.',
    mic_loading: 'Mikrofon wird geladen...',
    mic_default: 'Standard-Mikrofon',
    support: 'Support',
    support_tagline: 'Carby ist kostenlos und bleibt kostenlos.',
    support_desc: 'Carby wird unabhängig entwickelt. Mit deiner Unterstützung können neue Funktionen, Fehlerbehebungen und zukünftige Updates finanziert werden.',
    support_donate_btn: 'Jetzt via PayPal spenden',
    support_note: 'Öffnet PayPal in deinem Browser. Kein Konto nötig.',
    support_thanks: 'Danke, dass du Carby nutzt! 🦀',
    beta_banner_text: 'Carby befindet sich im Aufbau. Es kann noch zu Fehlern kommen.',
    nav_favorites: 'Favoriten',
    favorites_empty: 'Noch keine Favoriten.\nTippe ☆ auf einem Lebensmittel.',
    fav_add: 'Hinzufügen',
    fav_remove: '✕',
  },
  en: {
    greeting_morning: 'Good morning', greeting_afternoon: 'Good afternoon', greeting_evening: 'Good evening',
    dash: 'Dashboard', log: 'Food log', profile: 'Profile',
    cal_today: 'Today\'s calories', remaining: 'kcal remaining',
    gaps: 'Nutrient status', reco: 'What to eat next',
    protein: 'Protein', carbs: 'Carbohydrates', fat: 'Fat', fiber: 'Fiber',
    per100: 'per 100g', avg_portion: 'Avg. portion', portion_size: 'Portion size',
    nutr_table: 'Nutrition facts', add_btn: '➕ Add to food log',
    energy: 'Energy', sugar: 'Sugar', salt: 'Salt',
    add_food: 'Add food', speak: 'Click to speak',
    listening: 'Listening...', type_here: 'Type food name...',
    today_eaten: 'Eaten today', no_results: 'No results found',
    log_title: 'Food log', nothing_logged: 'Nothing logged yet.',
    speak_a_food: 'Speak or type a food!',
    lang: 'Language', name: 'Name', age: 'Age', weight: 'Weight',
    height: 'Height', goal: 'Goal', calgoal: 'Calorie goal', save: 'Save',
    lose: 'Lose weight', maintain: 'Maintain', gain: 'Gain weight',
    added: 'Added!', saved: 'Saved!',
    back: '← Back', years: 'years', kg: 'kg', cm: 'cm',
    mic_not_allowed: 'Microphone access denied. Please allow it in Windows settings.',
    mic_no_audio: 'No microphone found.',
    mic_no_speech: 'Didn\'t catch that. Please try again.',
    mic_error: 'Speech recognition failed.',
    mic_loading: 'Loading microphones...',
    mic_default: 'Default microphone',
    support: 'Support',
    support_tagline: 'Carby is free and will stay free.',
    support_desc: 'Carby is independently developed. Your support helps fund new features, bug fixes, and future updates.',
    support_donate_btn: 'Donate via PayPal',
    support_note: 'Opens PayPal in your browser. No account needed.',
    support_thanks: 'Thank you for using Carby! 🦀',
    beta_banner_text: 'Carby is still in development. You may encounter bugs.',
    nav_favorites: 'Favorites',
    favorites_empty: 'No favorites yet.\nClick ☆ on a food item.',
    fav_add: 'Add',
    fav_remove: '✕',
  },
};

// ─────────────────────────────────────────────────────────────────
// STATE
// ─────────────────────────────────────────────────────────────────
const State = {
  lang: 'de',
  profile: {
    name: '', age: 25, weight: 70, height: 175,
    goal: 'maintain', dailyCalorieGoal: 2000,
    gender: 'male',
    activity: 'moderate',
  },
  log: [],
  water: 0,
  recentFoods: [],
  favorites: [],
  currentScreen: 'dashboard',
  prevScreen: 'dashboard',
  currentFood: null,
  currentPortion: 100,
  micDeviceId: '',
};

function getRDA(calGoal) {
  return {
    protein: Math.round(calGoal * 0.25 / 4),
    carbs:   Math.round(calGoal * 0.45 / 4),
    fat:     Math.round(calGoal * 0.30 / 9),
    fiber:   25,
  };
}

const RECO = {
  protein: ['🍗 Hähnchenbrust', '🥚 Eier', '🐟 Lachs', '🫘 Linsen', '🥛 Quark'],
  carbs:   ['🌾 Haferflocken', '🍞 Vollkornbrot', '🍠 Süßkartoffeln', '🍚 Reis'],
  fat:     ['🥑 Avocado', '🥜 Nüsse', '🐟 Lachs', '🌿 Olivenöl'],
  fiber:   ['🍎 Äpfel', '🥦 Brokkoli', '🫘 Linsen', '🌾 Haferflocken', '🌱 Chiasamen'],
};

// ─────────────────────────────────────────────────────────────────
// OPEN FOOD FACTS SERVICE
// ─────────────────────────────────────────────────────────────────
const FoodAPI = {
  async search(query, lang = 'de') {
    const results = await FoodAPI._fetch(query);
    if (results.length > 0) return results;
    return FoodAPI.fallback(query);
  },

  async _fetch(query) {
    try {
      const url = `https://world.openfoodfacts.org/cgi/search.pl?` +
        `search_terms=${encodeURIComponent(query)}&search_simple=1&action=process` +
        `&json=1&fields=product_name,nutriments,image_url,serving_size,brands,_id&page_size=30`;
      const res = await fetch(url);
      const data = await res.json();
      return (data.products || [])
        .map(p => FoodAPI.parse(p))
        .filter(f => f.name && f.name.length > 2)
        .sort((a, b) => relevanceScore(b, query) - relevanceScore(a, query))
        .slice(0, 10);
    } catch {
      return [];
    }
  },

  parse(p) {
    const n = p.nutriments || {};
    const d = k => {
      const v = n[k];
      if (v == null) return 0;
      return parseFloat(v) || 0;
    };
    return {
      id: p._id || Math.random().toString(36),
      name: p.product_name || '',
      brand: p.brands || '',
      imageUrl: p.image_url || '',
      calories: d('energy-kcal_100g'),
      protein: d('proteins_100g'),
      carbs: d('carbohydrates_100g'),
      fat: d('fat_100g'),
      fiber: d('fiber_100g'),
      sugar: d('sugars_100g'),
      salt: d('salt_100g'),
      defaultPortion: FoodAPI.servingGrams(p.serving_size),
    };
  },

  servingGrams(s) {
    if (!s) return null;
    const m = s.match(/(\d+(?:\.\d+)?)/);
    return m ? parseFloat(m[1]) : null;
  },

  defaultPortion(name) {
    const n = name.toLowerCase();
    const map = {
      apfel: 182, apple: 182, banane: 120, banana: 120, orange: 130,
      ei: 60, egg: 60, bread: 30, brot: 30, toast: 25, brötchen: 50, bun: 50,
      hähnchen: 150, chicken: 150, lachs: 150, salmon: 150,
      kartoffel: 150, potato: 150, tomate: 100, tomato: 100,
      avocado: 150, joghurt: 150, yogurt: 150, milch: 240, milk: 240,
      käse: 30, cheese: 30, reis: 180, rice: 180, pasta: 220, nudeln: 220,
      haferflocken: 80, oats: 80, mandel: 28, almond: 28,
      pizza: 300, müsli: 50, muesli: 50, cerealien: 40, cereal: 40,
      birne: 178, pear: 178, traube: 92, grape: 92, erdbeere: 152, strawberry: 152,
      pommes: 150, fries: 150, burger: 220, sandwich: 180,
      gurke: 100, cucumber: 100, paprika: 120, pepper: 120,
      schokolade: 25, chocolate: 25, keks: 12, cookie: 12,
    };
    for (const [k, v] of Object.entries(map)) {
      if (n.includes(k)) return v;
    }
    return 100;
  },

  fallback(q) {
    const common = [
      { id: 'apple', name: 'Apfel', brand: '', imageUrl: '', calories: 52, protein: 0.3, carbs: 14, fat: 0.2, fiber: 2.4, sugar: 10, salt: 0, defaultPortion: 182 },
      { id: 'banana', name: 'Banane', brand: '', imageUrl: '', calories: 89, protein: 1.1, carbs: 23, fat: 0.3, fiber: 2.6, sugar: 12, salt: 0, defaultPortion: 120 },
      { id: 'egg', name: 'Ei', brand: '', imageUrl: '', calories: 155, protein: 13, carbs: 1.1, fat: 11, fiber: 0, sugar: 1.1, salt: 0.4, defaultPortion: 60 },
      { id: 'chicken', name: 'Hähnchenbrust', brand: '', imageUrl: '', calories: 165, protein: 31, carbs: 0, fat: 3.6, fiber: 0, sugar: 0, salt: 0.07, defaultPortion: 150 },
      { id: 'oats', name: 'Haferflocken', brand: '', imageUrl: '', calories: 389, protein: 17, carbs: 66, fat: 7, fiber: 10.6, sugar: 1, salt: 0, defaultPortion: 80 },
      { id: 'salmon', name: 'Lachs', brand: '', imageUrl: '', calories: 208, protein: 20, carbs: 0, fat: 13, fiber: 0, sugar: 0, salt: 0.06, defaultPortion: 150 },
    ];
    return common.filter(f => f.name.toLowerCase().includes(q.toLowerCase()) ||
      (q.toLowerCase().includes('apfel') && f.id === 'apple') ||
      (q.toLowerCase().includes('apple') && f.id === 'apple'));
  },

  nutriPer(food, key, grams) {
    return (food[key] || 0) * grams / 100;
  },
};

// ─────────────────────────────────────────────────────────────────
// CALORIE RING (Chart.js)
// ─────────────────────────────────────────────────────────────────
let ringChart = null;

function initRing() {
  const ctx = document.getElementById('calorie-ring').getContext('2d');

  // Gradient
  const grad = ctx.createLinearGradient(0, 0, 200, 0);
  grad.addColorStop(0,    C.orange);
  grad.addColorStop(0.25, C.pink);
  grad.addColorStop(0.5,  C.purple);
  grad.addColorStop(0.75, C.blue);
  grad.addColorStop(1,    C.teal);

  ringChart = new Chart(ctx, {
    type: 'doughnut',
    data: {
      datasets: [{
        data: [0, 2000],
        backgroundColor: [grad, C.ringEmpty],
        borderWidth: 0,
        hoverOffset: 0,
      }],
    },
    options: {
      cutout: '66%',
      rotation: -90,
      circumference: 360,
      animation: { duration: 600, easing: 'easeInOutQuart' },
      plugins: { legend: { display: false }, tooltip: { enabled: false } },
      events: [],
    },
  });
}

function updateRing(eaten, goal) {
  if (!ringChart) return;
  const remaining = Math.max(0, goal - eaten);
  ringChart.data.datasets[0].data = [Math.max(eaten, 0.1), remaining];
  ringChart.update();

  document.getElementById('ring-eaten').textContent = Math.round(eaten);
  document.getElementById('ring-of').textContent = `von ${goal}`;
}

// ─────────────────────────────────────────────────────────────────
// NUTRITION CALCULATIONS
// ─────────────────────────────────────────────────────────────────
function totals() {
  return State.log.reduce((acc, e) => {
    acc.calories += FoodAPI.nutriPer(e.food, 'calories', e.grams);
    acc.protein  += FoodAPI.nutriPer(e.food, 'protein', e.grams);
    acc.carbs    += FoodAPI.nutriPer(e.food, 'carbs', e.grams);
    acc.fat      += FoodAPI.nutriPer(e.food, 'fat', e.grams);
    acc.fiber    += FoodAPI.nutriPer(e.food, 'fiber', e.grams);
    return acc;
  }, { calories: 0, protein: 0, carbs: 0, fat: 0, fiber: 0 });
}

function tdee(p) {
  const bmr = p.gender === 'female'
    ? 10 * p.weight + 6.25 * p.height - 5 * p.age - 161
    : 10 * p.weight + 6.25 * p.height - 5 * p.age + 5;
  const factors = { sedentary: 1.2, light: 1.375, moderate: 1.55, active: 1.725, veryActive: 1.9 };
  const t = Math.round(bmr * (factors[p.activity] || 1.55));
  return p.goal === 'lose' ? t - 500 : p.goal === 'gain' ? t + 300 : t;
}

function bmi(p) {
  const h = p.height / 100;
  return (p.weight / (h * h)).toFixed(1);
}

function bmiLabel(val, lang) {
  if (val < 18.5) return lang === 'de' ? 'Untergewicht' : 'Underweight';
  if (val < 25)   return lang === 'de' ? 'Normalgewicht' : 'Normal weight';
  if (val < 30)   return lang === 'de' ? 'Übergewicht' : 'Overweight';
  return lang === 'de' ? 'Adipositas' : 'Obese';
}

function bmiColor(val) {
  if (val < 18.5) return '#42a5f5';
  if (val < 25)   return '#66bb6a';
  if (val < 30)   return '#ffa726';
  return '#ef5350';
}

function relevanceScore(food, query) {
  const q = query.toLowerCase();
  const n = (food.name || '').toLowerCase();
  let score = 0;
  if (n.startsWith(q)) score += 10;
  else if (n.split(/\s+/).some(w => w === q)) score += 5;
  else if (n.includes(q)) score += 2;
  if (food.calories > 0 && food.calories < 600) score += 3;
  if (food.protein > 0) score += 2;
  if (/sauce|würze|fertig|pulver|mix|extrakt|gewürz/i.test(n)) score -= 3;
  if (food.image) score += 1;
  return score;
}

// ─────────────────────────────────────────────────────────────────
// WATER + RECENTS HELPERS
// ─────────────────────────────────────────────────────────────────
function updateWaterUI() {
  const goal = 2000;
  const el = document.getElementById('water-amount');
  const bar = document.getElementById('water-bar');
  if (!el || !bar) return;
  el.textContent = `${State.water} / ${goal} ml`;
  const pct = Math.min((State.water / goal) * 100, 100);
  bar.style.width = pct + '%';
  bar.style.background = State.water >= goal ? '#66bb6a' : '#1e88e5';
}

function renderRecents() {
  const container = document.getElementById('recents-list');
  const section = document.getElementById('rp-recents');
  if (!container || !section) return;
  if (!State.recentFoods || State.recentFoods.length === 0) {
    section.style.display = 'none';
    return;
  }
  section.style.display = '';
  container.innerHTML = State.recentFoods.map(f =>
    `<button class="recent-chip" onclick="App.openDetail(${JSON.stringify(f).replace(/"/g, '&quot;')})">${f.name}</button>`
  ).join('');
}

// ─────────────────────────────────────────────────────────────────
// UI UPDATE
// ─────────────────────────────────────────────────────────────────
function updateUI() {
  const t = totals();
  const goal = State.profile.dailyCalorieGoal || 2000;
  const lang = State.lang;
  const tx = T[lang];

  // Ring
  updateRing(t.calories, goal);

  // Sidebar
  document.getElementById('sc-eaten').textContent = `${Math.round(t.calories)} kcal`;
  const pct = Math.min((t.calories / goal) * 100, 100);
  document.getElementById('sc-fill').style.width = pct + '%';
  const rem = Math.max(0, goal - t.calories);
  document.getElementById('sc-rem').textContent = `${Math.round(rem)} ${tx.remaining}`;

  // Macros
  const RDA = getRDA(goal);
  const setMacro = (id, barId, val, max) => {
    document.getElementById(id).textContent = `${Math.round(val)}g`;
    document.getElementById(barId).style.width = Math.min((val / max) * 100, 100) + '%';
  };
  setMacro('m-protein', 'm-protein-bar', t.protein, RDA.protein);
  setMacro('m-carbs',   'm-carbs-bar',   t.carbs,   RDA.carbs);
  setMacro('m-fat',     'm-fat-bar',     t.fat,     RDA.fat);

  // Gaps
  const gapColor = (v, max) => v >= max ? C.green : v >= max * 0.5 ? C.orange : C.pink;
  const setGap = (fillId, valId, val, max, unit) => {
    const el = document.getElementById(fillId);
    el.style.width = Math.min((val / max) * 100, 100) + '%';
    el.style.background = gapColor(val, max);
    document.getElementById(valId).textContent = `${Math.round(val)} / ${max}${unit}`;
  };
  setGap('gap-protein', 'gv-protein', t.protein, RDA.protein, 'g');
  setGap('gap-carbs',   'gv-carbs',   t.carbs,   RDA.carbs,   'g');
  setGap('gap-fat',     'gv-fat',     t.fat,     RDA.fat,     'g');
  setGap('gap-fiber',   'gv-fiber',   t.fiber,   RDA.fiber,   'g');

  // Water tracker
  updateWaterUI();

  // Recents
  renderRecents();

  // Recommendations
  const gaps = [
    { key: 'protein', val: t.protein, max: RDA.protein },
    { key: 'carbs',   val: t.carbs,   max: RDA.carbs },
    { key: 'fat',     val: t.fat,     max: RDA.fat },
    { key: 'fiber',   val: t.fiber,   max: RDA.fiber },
  ].filter(g => g.val < g.max).sort((a, b) => (a.val / a.max) - (b.val / b.max));

  const recos = new Set();
  gaps.slice(0, 3).forEach(g => RECO[g.key].slice(0, 2).forEach(r => recos.add(r)));
  const chipRow = document.getElementById('reco-chips');
  chipRow.innerHTML = [...recos].map(r => {
    const query = r.replace(/\p{Emoji_Presentation}/gu, '').trim();
    return `<div class="chip chip-link" onclick="App.searchFood('${query.replace(/'/g, "\\'")}')" title="${query}">${r}</div>`;
  }).join('');

  // Log screen
  renderLog(t, lang);

  // Right panel log
  renderRPLog(t, lang);

  // Translate UI
  translateUI(lang, tx);
}

function translateUI(lang, tx) {
  const set = (id, val) => { const el = document.getElementById(id); if (el) el.textContent = val; };
  const setPlaceholder = (id, val) => { const el = document.getElementById(id); if (el) el.placeholder = val; };

  set('nav-dash', tx.dash);
  set('nav-log', tx.log);
  set('nav-profile', tx.profile);
  set('nav-support', tx.support);
  set('nav-favorites', tx.nav_favorites || 'Favoriten');
  set('support-tagline', tx.support_tagline);
  set('support-desc', tx.support_desc);
  set('donate-btn-text', tx.support_donate_btn);
  set('support-note', tx.support_note);
  set('support-footer-text', tx.support_thanks);
  set('beta-banner-text', tx.beta_banner_text);
  set('sc-lbl', tx.cal_today);
  set('title-gaps', tx.gaps);
  set('title-reco', tx.reco);
  set('lbl-carbs', tx.carbs);
  set('lbl-fat', tx.fat);
  set('lbl-gap-carbs', tx.carbs);
  set('lbl-gap-fat', tx.fat);
  set('lbl-gap-fiber', tx.fiber);
  set('title-log', tx.log_title);
  set('title-profile', tx.profile);
  set('rp-title', tx.add_food);
  set('rp-log-title', tx.today_eaten);
  set('lbl-lang', tx.lang);
  set('lbl-name', tx.name);
  set('lbl-age', tx.age);
  set('lbl-weight', tx.weight);
  set('lbl-height', tx.height);
  set('lbl-goal', tx.goal);
  set('lbl-calgoal', tx.calgoal);
  set('btn-save', tx.save);
  set('lbl-lose', tx.lose);
  set('lbl-maintain', tx.maintain);
  set('lbl-gain', tx.gain);
  set('lbl-per100', tx.per100);
  set('lbl-avg-portion', tx.avg_portion);
  set('lbl-portion-size', tx.portion_size);
  set('lbl-nutr-table', tx.nutr_table);
  set('btn-add', tx.add_btn);
  set('detail-back-btn', tx.back);

  setPlaceholder('rp-search-input', tx.type_here);
  setPlaceholder('pf-name', lang === 'de' ? 'Dein Name' : 'Your name');

  // Greeting
  const h = new Date().getHours();
  const greeting = h < 12 ? tx.greeting_morning : h < 17 ? tx.greeting_afternoon : tx.greeting_evening;
  const name = State.profile.name || '';
  set('dash-greeting', name ? `${greeting}, ${name}!` : `${greeting}!`);

  // Date
  const now = new Date();
  const dateStr = lang === 'de'
    ? now.toLocaleDateString('de-DE', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })
    : now.toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });
  set('dash-date', dateStr);

  // Mic label
  const micLabel = document.getElementById('mic-label');
  if (micLabel && !Voice.listening) micLabel.textContent = tx.speak;

  // Lang buttons
  document.getElementById('lang-de').classList.toggle('active', lang === 'de');
  document.getElementById('lang-en').classList.toggle('active', lang === 'en');
}

function renderLog(t, lang) {
  const tx = T[lang];
  const container = document.getElementById('log-list');
  document.getElementById('log-total').textContent = `${Math.round(t.calories)} kcal`;

  if (State.log.length === 0) {
    container.innerHTML = `
      <div class="log-empty">
        <div class="log-empty-icon">🍽️</div>
        <div style="font-size:15px;margin-bottom:8px">${tx.nothing_logged}</div>
        <div style="font-size:13px;color:var(--muted)">${tx.speak_a_food}</div>
      </div>`;
    return;
  }

  container.innerHTML = State.log.map(entry => {
    const kcal = FoodAPI.nutriPer(entry.food, 'calories', entry.grams);
    const prot = FoodAPI.nutriPer(entry.food, 'protein', entry.grams);
    const carbs = FoodAPI.nutriPer(entry.food, 'carbs', entry.grams);
    return `
      <div class="log-item">
        <div class="log-item-icon">🍽️</div>
        <div class="log-item-info">
          <div class="log-item-name">${entry.food.name}</div>
          <div class="log-item-g">${entry.grams}g</div>
          <div class="log-item-macros">P: ${prot.toFixed(1)}g  K: ${carbs.toFixed(1)}g</div>
        </div>
        <div class="log-item-kcal">${Math.round(kcal)} kcal</div>
        <button class="log-delete" onclick="App.removeFromLog('${entry.id}')">✕</button>
      </div>`;
  }).join('');
}

function renderRPLog(t, lang) {
  const results = document.getElementById('rp-results');
  const logSection = document.getElementById('rp-log-section');

  if (results.children.length === 0 && !document.getElementById('rp-spinner').classList.contains('visible')) {
    logSection.style.display = 'flex';
    logSection.style.flexDirection = 'column';
    results.style.display = 'none';

    document.getElementById('rp-log-total').textContent = `${Math.round(t.calories)} kcal`;
    const items = document.getElementById('rp-log-items');
    items.innerHTML = State.log.length === 0
      ? `<div class="rp-empty">${T[lang].nothing_logged}</div>`
      : State.log.map(e => {
          const kcal = FoodAPI.nutriPer(e.food, 'calories', e.grams);
          return `<div class="rp-log-item">
            <div class="rp-log-item-name">${e.food.name}</div>
            <div class="rp-log-item-g">${e.grams}g</div>
            <div class="rp-log-item-kcal">${Math.round(kcal)}</div>
          </div>`;
        }).join('');
  } else {
    logSection.style.display = 'none';
    results.style.display = '';
  }
}

// ─────────────────────────────────────────────────────────────────
// VOICE  — MediaRecorder + Hugging Face Whisper
//
// webkitSpeechRecognition is permanently broken in Electron because
// Electron has no embedded Google Speech API key (HTTP 403 on every
// request to speech.googleapis.com → onend fires instantly).
//
// This implementation uses:
//   1. navigator.mediaDevices.getUserMedia  — mic access via OS
//   2. MediaRecorder (WebM/Opus)            — audio capture
//   3. HuggingFace Inference API (Whisper)  — free, no key needed
//
// Flow: click → getUserMedia → record → click again → stop →
//       send blob to HF Whisper → fill search field → search
// ─────────────────────────────────────────────────────────────────
const Voice = {
  stream:     null,
  recorder:   null,
  chunks:     [],
  listening:  false,
  processing: false,

  _setUI(state) {
    const btn   = document.getElementById('mic-btn');
    const label = document.getElementById('mic-label');
    const tx    = T[State.lang];
    if (!btn || !label) return;
    btn.classList.remove('listening', 'processing');
    label.classList.remove('active');
    if (state === 'listening') {
      btn.classList.add('listening');
      btn.textContent = '🎙️';
      label.textContent = tx.listening;
      label.classList.add('active');
    } else if (state === 'processing') {
      btn.classList.add('processing');
      btn.textContent = '⏳';
      label.textContent = tx.mic_processing || (State.lang === 'de' ? 'Verarbeite...' : 'Processing...');
    } else {
      btn.textContent = '🎙️';
      label.textContent = tx.speak;
    }
  },

  async start() {
    console.log('[Voice] button pressed — requesting mic access');
    this._setUI('idle');

    try {
      const constraints = State.micDeviceId
        ? { audio: { deviceId: { ideal: State.micDeviceId } }, video: false }
        : { audio: true, video: false };
      this.stream = await navigator.mediaDevices.getUserMedia(constraints);
      console.log('[Voice] mic access granted, tracks:', this.stream.getAudioTracks().map(t => t.label));
    } catch (e) {
      console.error('[Voice] getUserMedia error:', e.name, e.message);
      const tx = T[State.lang];
      showToast(e.name === 'NotFoundError' ? tx.mic_no_audio : tx.mic_not_allowed);
      return;
    }

    this.chunks = [];
    const mimeType = MediaRecorder.isTypeSupported('audio/webm;codecs=opus')
      ? 'audio/webm;codecs=opus'
      : MediaRecorder.isTypeSupported('audio/webm') ? 'audio/webm' : '';
    const opts = mimeType ? { mimeType } : {};
    this.recorder = new MediaRecorder(this.stream, opts);
    this.recorder.ondataavailable = e => { if (e.data && e.data.size > 0) this.chunks.push(e.data); };
    this.recorder.onstop = () => this._transcribe();
    this.recorder.start(200); // collect chunks every 200ms

    // Silence detection — auto-stop after 1.5s of quiet
    try {
      this._audioCtx = new AudioContext();
      this._analyser = this._audioCtx.createAnalyser();
      this._analyser.fftSize = 512;
      const src = this._audioCtx.createMediaStreamSource(this.stream);
      src.connect(this._analyser);
      this._silenceStart = Date.now();
      this._silenceTimer = setInterval(() => {
        if (!this.listening) return;
        const buf = new Uint8Array(this._analyser.frequencyBinCount);
        this._analyser.getByteTimeDomainData(buf);
        const rms = Math.sqrt(buf.reduce((s, v) => s + (v - 128) ** 2, 0) / buf.length);
        if (rms < 6) {
          if (Date.now() - this._silenceStart > 1500) App.toggleMic();
        } else {
          this._silenceStart = Date.now();
        }
      }, 200);
    } catch (e) {
      console.warn('[Voice] silence detection unavailable:', e.message);
    }

    this.listening = true;
    this._setUI('listening');
    console.log('[Voice] recording started, mimeType:', this.recorder.mimeType);
  },

  stop() {
    if (!this.listening) return;
    console.log('[Voice] stopping recorder,', this.chunks.length, 'chunks so far');
    this.listening = false;
    clearInterval(this._silenceTimer);
    try { this._audioCtx?.close(); } catch (_) {}
    this._audioCtx = null;
    try { this.recorder?.stop(); } catch (_) {}
    this.stream?.getTracks().forEach(t => t.stop());
    this.stream = null;
    this._setUI('processing');
  },

  async _transcribe() {
    if (this.chunks.length === 0) {
      console.warn('[Voice] no audio chunks, aborting transcription');
      this._setUI('idle');
      return;
    }

    this.processing = true;
    const mimeType = this.recorder?.mimeType || 'audio/webm';
    const blob = new Blob(this.chunks, { type: mimeType });
    console.log('[Voice] transcribing blob:', blob.size, 'bytes,', mimeType);

    const HF_MODEL = 'openai/whisper-small';
    const HF_URL   = `https://api-inference.huggingface.co/models/${HF_MODEL}`;

    const doFetch = () => fetch(HF_URL, {
      method:  'POST',
      headers: { 'Content-Type': mimeType, 'x-use-cache': 'false' },
      body:    blob,
    });

    try {
      let res = await doFetch();
      console.log('[Voice] HF response status:', res.status);

      // 503 = model cold start — retry once after 8s
      if (res.status === 503) {
        console.warn('[Voice] HF model cold-starting, retrying in 8s...');
        await new Promise(r => setTimeout(r, 8000));
        res = await doFetch();
        console.log('[Voice] HF retry status:', res.status);
      }

      if (!res.ok) {
        const err = await res.text();
        console.error('[Voice] HF error body:', err);
        throw new Error(`HF API ${res.status}`);
      }

      const data = await res.json();
      console.log('[Voice] HF result:', data);
      const text = (data.text || '').trim();

      if (text) {
        console.log('[Voice] transcript:', JSON.stringify(text), '— executing search');
        const input = document.getElementById('rp-search-input');
        if (input) input.value = text;
        const badge = document.getElementById('recognized-badge');
        if (badge) { badge.textContent = `"${text}"`; badge.classList.add('visible'); }
        App.searchFood(text);
      } else {
        console.warn('[Voice] empty transcript from HF');
        showToast(T[State.lang].mic_no_speech);
      }
    } catch (e) {
      console.error('[Voice] transcription error:', e.message);
      showToast(T[State.lang].mic_error);
    } finally {
      this.processing = false;
      this._setUI('idle');
      console.log('[Voice] done');
    }
  },
};

// ─────────────────────────────────────────────────────────────────
// ROUTER
// ─────────────────────────────────────────────────────────────────
const Router = {
  go(screen) {
    document.querySelectorAll('.screen').forEach(s => s.classList.remove('active'));
    document.querySelectorAll('.nav-item').forEach(n => {
      n.classList.toggle('active', n.dataset.screen === screen);
    });
    const el = document.getElementById(`screen-${screen}`);
    if (el) el.classList.add('active');
    State.prevScreen = State.currentScreen;
    State.currentScreen = screen;
    if (screen === 'favorites') App.renderFavorites();
  },
};

// ─────────────────────────────────────────────────────────────────
// APP — public API called from HTML
// ─────────────────────────────────────────────────────────────────
const App = {

  // ── Navigation ──────────────────────────────────────────────
  navigate(screen) {
    Router.go(screen);
    updateUI();
  },

  goBack() {
    Router.go(State.prevScreen || 'dashboard');
    updateUI();
  },

  // ── Support / Donation ───────────────────────────────────────
  _selectedTierAmount: 3,

  selectTier(btn) {
    document.querySelectorAll('.tier-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    this._selectedTierAmount = parseInt(btn.dataset.amount, 10);
  },

  openPayPal() {
    const PAYPAL_URL = 'https://paypal.me/FredericSchroer';
    if (window.electronAPI?.openExternal) {
      window.electronAPI.openExternal(PAYPAL_URL).catch(() => {});
    } else {
      window.open(PAYPAL_URL, '_blank');
    }
  },

  // ── Mic ─────────────────────────────────────────────────────
  toggleMic() {
    if (Voice.processing) return; // ignore clicks while transcribing
    if (Voice.listening) {
      Voice.stop();
    } else {
      document.getElementById('recognized-badge').classList.remove('visible');
      document.getElementById('rp-search-input').value = '';
      App.clearResults();
      Voice.start(); // async — does NOT block, errors handled inside
    }
  },

  selectMicDevice(deviceId) {
    State.micDeviceId = deviceId;
    if (window.electronAPI) window.electronAPI.storeSet('mic_device_id', deviceId);
    else localStorage.setItem('nv_mic_device_id', deviceId);
  },

  // ── Search ──────────────────────────────────────────────────
  searchFromInput() {
    const q = document.getElementById('rp-search-input').value.trim();
    if (q) App.searchFood(q);
  },

  async searchFood(query) {
    const spinner = document.getElementById('rp-spinner');
    const resultsEl = document.getElementById('rp-results');
    const logSection = document.getElementById('rp-log-section');

    spinner.classList.add('visible');
    resultsEl.innerHTML = '';
    logSection.style.display = 'none';
    resultsEl.style.display = '';

    const results = await FoodAPI.search(query, State.lang);
    spinner.classList.remove('visible');

    if (results.length === 0) {
      resultsEl.innerHTML = `<div class="rp-empty">${T[State.lang].no_results}</div>`;
      return;
    }

    resultsEl.innerHTML = results.map((food, i) => `
      <div class="result-card ${i === 0 ? 'highlighted' : ''}" onclick="App.openDetail(${i})" data-idx="${i}">
        <div class="result-thumb">
          ${food.imageUrl
            ? `<img src="${food.imageUrl}" alt="" onerror="this.parentElement.textContent='🍽️'">`
            : '🍽️'}
        </div>
        <div class="result-info">
          <div class="result-name">${food.name}</div>
          ${food.brand ? `<div class="result-brand">${food.brand}</div>` : ''}
        </div>
        <div class="result-kcal">${Math.round(food.calories)} kcal</div>
        <span class="rp-chevron">›</span>
      </div>`).join('');

    // Store results for index access
    App._lastResults = results;
  },

  _lastResults: [],

  clearResults() {
    document.getElementById('rp-results').innerHTML = '';
    App._lastResults = [];
  },

  // ── Food Detail ─────────────────────────────────────────────
  openDetail(idx) {
    const food = App._lastResults[idx];
    if (!food) return;
    State.currentFood = food;
    State.currentPortion = food.defaultPortion || FoodAPI.defaultPortion(food.name);

    // Populate detail screen
    document.getElementById('detail-name').textContent = food.name;
    document.getElementById('detail-brand').textContent = food.brand || '';
    document.getElementById('detail-kcal100').textContent = `${Math.round(food.calories)} kcal`;
    document.getElementById('detail-portion-size').textContent = `${Math.round(State.currentPortion)}g`;

    // Hero image
    const hero = document.getElementById('detail-hero');
    const emoji = document.getElementById('detail-emoji');
    if (food.imageUrl) {
      hero.style.backgroundImage = `url('${food.imageUrl}')`;
      hero.style.backgroundSize = 'cover';
      hero.style.backgroundPosition = 'center';
      emoji.style.display = 'none';
    } else {
      hero.style.backgroundImage = 'none';
      emoji.style.display = '';
    }

    document.getElementById('portion-slider').value = State.currentPortion;
    App.updatePortion(State.currentPortion);

    // Nutrition table rows
    const lang = State.lang;
    const tx = T[lang];
    const rows = [
      { label: tx.energy,  key: 'calories', unit: 'kcal', color: C.orange },
      { label: tx.protein, key: 'protein',  unit: 'g',    color: C.blue },
      { label: tx.carbs,   key: 'carbs',    unit: 'g',    color: C.teal },
      { label: `  ${tx.sugar}`, key: 'sugar', unit: 'g',  color: '#00BCD488' },
      { label: tx.fat,     key: 'fat',      unit: 'g',    color: C.pink },
      { label: tx.fiber,   key: 'fiber',    unit: 'g',    color: C.green },
      { label: tx.salt,    key: 'salt',     unit: 'g',    color: C.muted },
    ];

    document.getElementById('nutr-rows').innerHTML = rows.map(r => {
      const per100 = food[r.key] || 0;
      const perP = FoodAPI.nutriPer(food, r.key, State.currentPortion);
      const fmt = (v, u) => u === 'kcal' ? `${Math.round(v)} ${u}` : `${v.toFixed(r.key === 'salt' ? 2 : 1)}${u}`;
      return `<div class="nutr-row" data-key="${r.key}">
        <div class="nutr-color-bar" style="background:${r.color}"></div>
        <div class="nutr-name">${r.label}</div>
        <div class="nutr-100g">${fmt(per100, r.unit)}</div>
        <div class="nutr-portion-val" id="nutr-p-${r.key}">${fmt(perP, r.unit)}</div>
      </div>`;
    }).join('');

    Router.go('detail');
    App._updateStarBtn(State.currentFood);
  },

  updatePortion(grams) {
    State.currentPortion = parseFloat(grams);
    document.getElementById('portion-display').textContent = `${Math.round(grams)}g`;
    document.getElementById('nutr-head-portion').textContent = `${Math.round(grams)}g`;

    if (!State.currentFood) return;
    const food = State.currentFood;

    const kcal = FoodAPI.nutriPer(food, 'calories', grams);
    document.getElementById('portion-kcal-live').textContent = `= ${Math.round(kcal)} kcal`;

    const rows = [
      { key: 'calories', unit: 'kcal' }, { key: 'protein', unit: 'g' },
      { key: 'carbs', unit: 'g' }, { key: 'sugar', unit: 'g' },
      { key: 'fat', unit: 'g' }, { key: 'fiber', unit: 'g' },
      { key: 'salt', unit: 'g' },
    ];
    rows.forEach(r => {
      const el = document.getElementById(`nutr-p-${r.key}`);
      if (!el) return;
      const v = FoodAPI.nutriPer(food, r.key, grams);
      el.textContent = r.unit === 'kcal' ? `${Math.round(v)} kcal`
        : `${v.toFixed(r.key === 'salt' ? 2 : 1)}g`;
    });
  },

  addToLog() {
    if (!State.currentFood) return;
    const entry = {
      id: Date.now().toString(36),
      food: State.currentFood,
      grams: State.currentPortion,
    };
    State.log.push(entry);
    App.saveLog();
    App.saveRecent(State.currentFood);
    App.checkDonationNudge();
    App.clearResults();
    showToast(T[State.lang].added);
    Router.go('dashboard');
    updateUI();
  },

  removeFromLog(id) {
    State.log = State.log.filter(e => e.id !== id);
    App.saveLog();
    updateUI();
  },

  // ── Profile ─────────────────────────────────────────────────
  setLang(lang) {
    State.lang = lang;
    App.saveProfile(true);
    updateUI();
    populateMicDevices();
  },

  setGoal(goal) {
    State.profile.goal = goal;
    document.querySelectorAll('.goal-card').forEach(c => c.classList.remove('active'));
    document.getElementById(`goal-${goal}`).classList.add('active');
    App.recalcCalGoal();
  },

  updateSlider(field, val) {
    val = parseFloat(val);
    const tx = T[State.lang];
    const units = { age: tx.years, weight: tx.kg, height: tx.cm };
    document.getElementById(`pf-${field}-val`).textContent = `${Math.round(val)} ${units[field]}`;
    State.profile[field] = val;
    App.recalcCalGoal();
  },

  recalcCalGoal() {
    const p = {
      ...State.profile,
      name: document.getElementById('pf-name').value || '',
      age: parseFloat(document.getElementById('pf-age').value),
      weight: parseFloat(document.getElementById('pf-weight').value),
      height: parseFloat(document.getElementById('pf-height').value),
    };
    const goal = tdee(p);
    document.getElementById('pf-cal-preview').textContent = goal;
    State.profile.dailyCalorieGoal = goal;
    const b = parseFloat(bmi(p));
    const bmiEl = document.getElementById('pf-bmi-val');
    const bmiLblEl = document.getElementById('pf-bmi-label');
    if (bmiEl) { bmiEl.textContent = b.toFixed(1); bmiEl.style.color = bmiColor(b); }
    if (bmiLblEl) bmiLblEl.textContent = bmiLabel(b, State.lang);
  },

  setGender(g) {
    State.profile.gender = g;
    document.querySelectorAll('[id^="gender-"]').forEach(c => c.classList.remove('active'));
    document.getElementById(`gender-${g}`)?.classList.add('active');
    App.recalcCalGoal();
  },

  setActivity(a) {
    State.profile.activity = a;
    document.querySelectorAll('.activity-item').forEach(c => c.classList.remove('active'));
    document.getElementById(`act-${a}`)?.classList.add('active');
    App.recalcCalGoal();
  },

  addWater(ml) {
    State.water = Math.min((State.water || 0) + ml, 5000);
    if (window.electronAPI) window.electronAPI.storeSet('water_' + todayKey(), State.water);
    else localStorage.setItem('nv_water_' + todayKey(), State.water);
    if (State.water >= 2000 && State.water - ml < 2000) showToast('Tagesziel erreicht! 💧');
    updateWaterUI();
  },

  resetWater() {
    State.water = 0;
    if (window.electronAPI) window.electronAPI.storeSet('water_' + todayKey(), 0);
    else localStorage.setItem('nv_water_' + todayKey(), 0);
    updateWaterUI();
  },

  dismissBetaBanner() {
    if (window.electronAPI) window.electronAPI.storeSet('beta_dismissed', true);
    else localStorage.setItem('nv_beta_dismissed', 'true');
    const el = document.getElementById('beta-banner');
    if (el) el.style.display = 'none';
  },

  saveRecent(food) {
    let recents = State.recentFoods || [];
    recents = [food, ...recents.filter(f => f.name !== food.name)].slice(0, 5);
    State.recentFoods = recents;
    if (window.electronAPI) window.electronAPI.storeSet('recent_foods', recents);
    else localStorage.setItem('nv_recent_foods', JSON.stringify(recents));
  },

  // ── Favorites ────────────────────────────────────────────────
  isFavorite(food) {
    return State.favorites.some(f => f.name === food.name);
  },

  saveFavorites() {
    if (window.electronAPI) window.electronAPI.storeSet('favorites', State.favorites);
    else localStorage.setItem('nv_favorites', JSON.stringify(State.favorites));
  },

  toggleFavorite() {
    const food = State.currentFood;
    if (!food) return;
    if (App.isFavorite(food)) {
      State.favorites = State.favorites.filter(f => f.name !== food.name);
    } else {
      State.favorites = [food, ...State.favorites];
    }
    App.saveFavorites();
    App._updateStarBtn(food);
    if (State.currentScreen === 'favorites') App.renderFavorites();
  },

  _updateStarBtn(food) {
    const btn = document.getElementById('btn-fav-star');
    if (!btn) return;
    btn.textContent = App.isFavorite(food) ? '★' : '☆';
    btn.classList.toggle('fav-star-active', App.isFavorite(food));
  },

  renderFavorites() {
    const el = document.getElementById('favorites-list');
    if (!el) return;
    const tx = T[State.lang];
    if (!State.favorites.length) {
      el.innerHTML = `<div class="fav-empty">${(tx.favorites_empty || 'Keine Favoriten.').replace('\n','<br>')}</div>`;
      return;
    }
    el.innerHTML = State.favorites.map((food, i) => `
      <div class="fav-card">
        <div class="fav-card-emoji">${food.imageUrl ? `<img src="${food.imageUrl}" class="fav-thumb">` : '🥗'}</div>
        <div class="fav-card-info">
          <div class="fav-card-name">${food.name}</div>
          <div class="fav-card-cal">${Math.round(food.calories)} kcal / 100g</div>
        </div>
        <div class="fav-card-actions">
          <button class="fav-action-btn fav-add-btn" onclick="App.openFavoriteDetail(${i})">${tx.fav_add || 'Add'}</button>
          <button class="fav-action-btn fav-remove-btn" onclick="App.removeFavorite(${i})">${tx.fav_remove || '✕'}</button>
        </div>
      </div>`).join('');
  },

  openFavoriteDetail(idx) {
    const food = State.favorites[idx];
    if (!food) return;
    App._lastResults = [food];
    App.openDetail(0);
  },

  removeFavorite(idx) {
    State.favorites.splice(idx, 1);
    App.saveFavorites();
    App.renderFavorites();
  },

  // ── Donation Nudge ───────────────────────────────────────────
  checkDonationNudge() {
    const count = parseInt(localStorage.getItem('nv_total_entries') || '0') + 1;
    localStorage.setItem('nv_total_entries', count);
    if (window.electronAPI) window.electronAPI.storeSet('total_entries', count);
    const nextTrigger = parseInt(localStorage.getItem('nv_donation_next_trigger') || '5');
    if (count >= nextTrigger) App.showDonationNudge();
  },

  showDonationNudge() {
    localStorage.setItem('nv_donation_next_trigger', '999999');
    if (window.electronAPI) window.electronAPI.storeSet('donation_next_trigger', 999999);
    const el = document.getElementById('donation-nudge');
    if (el) el.style.display = 'flex';
  },

  dismissNudge() {
    const el = document.getElementById('donation-nudge');
    if (el) el.style.display = 'none';
  },

  nudgePayPal() {
    App.openPayPal();
    document.getElementById('donation-nudge').style.display = 'none';
    document.getElementById('donation-thanks').style.display = 'flex';
  },

  setDonationAmount(euros) {
    const offsets = { 1: 50, 3: 150, 5: 1000 };
    const offset = offsets[euros] || 50;
    const count = parseInt(localStorage.getItem('nv_total_entries') || '0');
    const next = count + offset;
    localStorage.setItem('nv_donation_next_trigger', next);
    if (window.electronAPI) window.electronAPI.storeSet('donation_next_trigger', next);
    document.getElementById('donation-thanks').style.display = 'none';
  },

  saveProfile(silent = false) {
    State.profile.name = document.getElementById('pf-name').value.trim();
    State.profile.age = parseFloat(document.getElementById('pf-age').value);
    State.profile.weight = parseFloat(document.getElementById('pf-weight').value);
    State.profile.height = parseFloat(document.getElementById('pf-height').value);
    State.profile.language = State.lang;
    State.profile.dailyCalorieGoal = tdee(State.profile);

    if (window.electronAPI) {
      window.electronAPI.storeSet('profile', State.profile);
      window.electronAPI.storeSet('lang', State.lang);
    } else {
      localStorage.setItem('nv_profile', JSON.stringify(State.profile));
      localStorage.setItem('nv_lang', State.lang);
    }
    if (!silent) showToast(T[State.lang].saved);
    updateUI();
  },

  saveLog() {
    const data = State.log.map(e => ({ id: e.id, food: e.food, grams: e.grams }));
    if (window.electronAPI) {
      window.electronAPI.storeSet('log_' + todayKey(), data);
    } else {
      localStorage.setItem('nv_log_' + todayKey(), JSON.stringify(data));
    }
  },

  async loadData() {
    if (window.electronAPI) {
      const profile = await window.electronAPI.storeGet('profile');
      const lang = await window.electronAPI.storeGet('lang');
      const log = await window.electronAPI.storeGet('log_' + todayKey());
      if (profile) State.profile = { ...State.profile, ...profile };
      if (lang) State.lang = lang;
      if (log) State.log = log;
      const micId = await window.electronAPI.storeGet('mic_device_id');
      if (micId) State.micDeviceId = micId;
      const water = await window.electronAPI.storeGet('water_' + todayKey());
      if (water) State.water = water;
      const recents = await window.electronAPI.storeGet('recent_foods');
      if (recents) State.recentFoods = recents;
      const favs = await window.electronAPI.storeGet('favorites');
      if (favs) State.favorites = favs;
      const donationNext = await window.electronAPI.storeGet('donation_next_trigger');
      if (donationNext) localStorage.setItem('nv_donation_next_trigger', donationNext);
      const totalEntries = await window.electronAPI.storeGet('total_entries');
      if (totalEntries) localStorage.setItem('nv_total_entries', totalEntries);
    } else {
      try {
        const p = localStorage.getItem('nv_profile');
        const l = localStorage.getItem('nv_lang');
        const lg = localStorage.getItem('nv_log_' + todayKey());
        const m = localStorage.getItem('nv_mic_device_id');
        const w = localStorage.getItem('nv_water_' + todayKey());
        const r = localStorage.getItem('nv_recent_foods');
        const fv = localStorage.getItem('nv_favorites');
        if (p) State.profile = { ...State.profile, ...JSON.parse(p) };
        if (l) State.lang = l;
        if (lg) State.log = JSON.parse(lg);
        if (m) State.micDeviceId = m;
        if (w) State.water = parseInt(w);
        if (r) State.recentFoods = JSON.parse(r);
        if (fv) State.favorites = JSON.parse(fv);
      } catch (_) {}
    }
    // Show beta banner if not dismissed
    const dismissed = window.electronAPI
      ? await window.electronAPI.storeGet('beta_dismissed')
      : localStorage.getItem('nv_beta_dismissed') === 'true';
    if (!dismissed) {
      const el = document.getElementById('beta-banner');
      if (el) el.style.display = 'flex';
    }

    return !!State.profile.name;
  },
};

// ─────────────────────────────────────────────────────────────────
// ONBOARDING
// ─────────────────────────────────────────────────────────────────
const Onboarding = {
  step: 0,
  data: { lang: 'de', name: '', age: 25, weight: 70, height: 175, goal: 'maintain' },

  steps: [
    // 0: Language
    (ob) => `
      <div class="ob-title">${ob.data.lang === 'de' ? 'Willkommen!' : 'Welcome!'}</div>
      <div class="ob-sub">${ob.data.lang === 'de' ? 'Wähle deine Sprache' : 'Choose your language'}</div>
      <div class="lang-row" style="margin-top:12px">
        <button class="lang-btn ${ob.data.lang === 'de' ? 'active' : ''}" onclick="Onboarding.data.lang='de';Onboarding.render()">🇩🇪 Deutsch</button>
        <button class="lang-btn ${ob.data.lang === 'en' ? 'active' : ''}" onclick="Onboarding.data.lang='en';Onboarding.render()">🇬🇧 English</button>
      </div>`,

    // 1: Name
    (ob) => {
      const tx = T[ob.data.lang];
      return `<div class="ob-title">${tx.name === 'Name' ? (ob.data.lang === 'de' ? 'Wie heißt du?' : "What's your name?") : ''}</div>
      <input class="ob-input" id="ob-name" placeholder="${ob.data.lang === 'de' ? 'Dein Name' : 'Your name'}" value="${ob.data.name}" oninput="Onboarding.data.name=this.value">`;
    },

    // 2: Stats
    (ob) => {
      const tx = T[ob.data.lang];
      return `<div class="ob-title">${ob.data.lang === 'de' ? 'Deine Daten' : 'Your stats'}</div>
      <div class="slider-field">
        <div class="slider-field-header"><span class="slider-field-label">${tx.age}</span><span id="ob-age-v">${ob.data.age} ${tx.years}</span></div>
        <input type="range" class="portion-slider" min="10" max="100" value="${ob.data.age}" oninput="Onboarding.data.age=+this.value;document.getElementById('ob-age-v').textContent=this.value+' ${tx.years}'">
      </div>
      <div class="slider-field">
        <div class="slider-field-header"><span class="slider-field-label">${tx.weight}</span><span id="ob-w-v">${ob.data.weight} kg</span></div>
        <input type="range" class="portion-slider" min="30" max="200" value="${ob.data.weight}" oninput="Onboarding.data.weight=+this.value;document.getElementById('ob-w-v').textContent=this.value+' kg'">
      </div>
      <div class="slider-field">
        <div class="slider-field-header"><span class="slider-field-label">${tx.height}</span><span id="ob-h-v">${ob.data.height} cm</span></div>
        <input type="range" class="portion-slider" min="100" max="220" value="${ob.data.height}" oninput="Onboarding.data.height=+this.value;document.getElementById('ob-h-v').textContent=this.value+' cm'">
      </div>`;
    },

    // 3: Goal
    (ob) => {
      const tx = T[ob.data.lang];
      const goal = ob.data.goal;
      return `<div class="ob-title">${tx.goal}</div>
      <div class="goal-row" style="margin-top:20px">
        <div class="goal-card ${goal==='lose'?'active':''}" onclick="Onboarding.data.goal='lose';Onboarding.render()"><div class="goal-icon">↘</div>${tx.lose}</div>
        <div class="goal-card ${goal==='maintain'?'active':''}" onclick="Onboarding.data.goal='maintain';Onboarding.render()"><div class="goal-icon">→</div>${tx.maintain}</div>
        <div class="goal-card ${goal==='gain'?'active':''}" onclick="Onboarding.data.goal='gain';Onboarding.render()"><div class="goal-icon">↗</div>${tx.gain}</div>
      </div>`;
    },

    // 4: Summary
    (ob) => {
      const d = ob.data;
      const cal = tdee({ ...d, dailyCalorieGoal: 0 });
      const tx = T[d.lang];
      return `<div class="ob-title">${tx.calgoal}</div>
      <div style="text-align:center;margin:24px 0">
        <div style="font-size:72px;font-weight:900;background:linear-gradient(90deg,var(--orange),var(--pink));-webkit-background-clip:text;-webkit-text-fill-color:transparent">${cal}</div>
        <div style="font-size:18px;color:var(--muted)">kcal / ${d.lang==='de'?'Tag':'day'}</div>
      </div>
      <div style="background:var(--card);border-radius:14px;padding:16px">
        ${[['Name', d.name || '-'], [tx.age, `${d.age} ${tx.years}`], [tx.weight, `${d.weight} kg`], [tx.height, `${d.height} cm`], [tx.goal, T[d.lang][d.goal]]]
          .map(([l,v]) => `<div style="display:flex;justify-content:space-between;padding:6px 0;border-bottom:1px solid var(--ring-empty);font-size:13px"><span style="color:var(--muted)">${l}</span><span style="font-weight:600">${v}</span></div>`).join('')}
      </div>`;
    },
  ],

  render() {
    document.getElementById('ob-content').innerHTML = this.steps[this.step](this);
    // Update step indicators
    for (let i = 0; i < 5; i++) {
      document.getElementById(`ob-s${i}`).classList.toggle('done', i <= this.step);
    }
    const tx = T[this.data.lang];
    document.getElementById('ob-next').textContent = this.step < 4 ? tx.next || 'Weiter' : tx.start || 'Loslegen!';
  },

  next() {
    if (this.step < 4) {
      this.step++;
      this.render();
    } else {
      this.finish();
    }
  },

  finish() {
    const d = this.data;
    State.lang = d.lang;
    State.profile = {
      name: d.name || 'User',
      age: d.age,
      weight: d.weight,
      height: d.height,
      goal: d.goal,
      language: d.lang,
      dailyCalorieGoal: tdee(d),
    };

    // Sync profile UI
    document.getElementById('pf-name').value = State.profile.name;
    document.getElementById('pf-age').value = d.age;
    document.getElementById('pf-weight').value = d.weight;
    document.getElementById('pf-height').value = d.height;
    document.getElementById(`goal-${d.goal}`).classList.add('active');
    document.getElementById('pf-cal-preview').textContent = State.profile.dailyCalorieGoal;

    App.saveProfile(true);
    document.getElementById('onboarding').style.display = 'none';
    document.getElementById('app').style.display = 'flex';
    updateUI();
  },
};

// ─────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────
function todayKey() {
  const d = new Date();
  return `${d.getFullYear()}-${d.getMonth()}-${d.getDate()}`;
}

async function populateMicDevices() {
  const select = document.getElementById('mic-device-select');
  if (!navigator.mediaDevices || !navigator.mediaDevices.enumerateDevices) return;

  try {
    // Unlock device labels (otherwise they show up blank until permission is granted)
    const tmp = await navigator.mediaDevices.getUserMedia({ audio: true });
    tmp.getTracks().forEach(t => t.stop());
  } catch (_) {
    // Permission not granted yet — device list will just show generic labels
  }

  try {
    const devices = await navigator.mediaDevices.enumerateDevices();
    const inputs = devices.filter(d => d.kind === 'audioinput');
    const tx = T[State.lang];
    select.innerHTML = inputs.length
      ? inputs.map((d, i) =>
          `<option value="${d.deviceId}">${d.label || `${tx.mic_default} ${i + 1}`}</option>`).join('')
      : `<option value="">${tx.mic_no_audio}</option>`;

    if (State.micDeviceId && inputs.some(d => d.deviceId === State.micDeviceId)) {
      select.value = State.micDeviceId;
    } else if (inputs[0]) {
      State.micDeviceId = inputs[0].deviceId;
      select.value = inputs[0].deviceId;
    }
  } catch (e) {
    console.error('Could not enumerate audio devices', e);
  }
}

function showToast(msg) {
  const t = document.getElementById('toast');
  t.textContent = msg;
  t.classList.add('show');
  setTimeout(() => t.classList.remove('show'), 2500);
}

// ─────────────────────────────────────────────────────────────────
// INIT
// ─────────────────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', async () => {
  // Nav click handlers
  document.querySelectorAll('.nav-item[data-screen]').forEach(item => {
    item.addEventListener('click', () => App.navigate(item.dataset.screen));
  });

  // Search input enter key
  document.getElementById('rp-search-input').addEventListener('keydown', e => {
    if (e.key === 'Enter') App.searchFromInput();
  });

  // Init Chart.js ring
  initRing();

  // Load saved data
  const hasProfile = await App.loadData();

  if (hasProfile) {
    // Restore profile UI
    const p = State.profile;
    document.getElementById('pf-name').value = p.name || '';
    document.getElementById('pf-age').value = p.age || 25;
    document.getElementById('pf-weight').value = p.weight || 70;
    document.getElementById('pf-height').value = p.height || 175;
    ['lose', 'maintain', 'gain'].forEach(g => {
      document.getElementById(`goal-${g}`).classList.toggle('active', p.goal === g);
    });
    // Gender
    ['male', 'female'].forEach(g => {
      document.getElementById(`gender-${g}`)?.classList.toggle('active', (p.gender || 'male') === g);
    });
    // Activity
    ['sedentary','light','moderate','active','veryActive'].forEach(a => {
      document.getElementById(`act-${a}`)?.classList.toggle('active', (p.activity || 'moderate') === a);
    });
    document.getElementById('pf-cal-preview').textContent = p.dailyCalorieGoal || 2000;
    // BMI
    const b = parseFloat(bmi(p));
    const bmiEl = document.getElementById('pf-bmi-val');
    const bmiLblEl = document.getElementById('pf-bmi-label');
    if (bmiEl) { bmiEl.textContent = b.toFixed(1); bmiEl.style.color = bmiColor(b); }
    if (bmiLblEl) bmiLblEl.textContent = bmiLabel(b, State.lang);
    ['age', 'weight', 'height'].forEach(f => {
      if (p[f]) {
        const tx = T[State.lang];
        const units = { age: tx.years, weight: tx.kg, height: tx.cm };
        const el = document.getElementById(`pf-${f}-val`);
        if (el) el.textContent = `${Math.round(p[f])} ${units[f]}`;
      }
    });

    document.getElementById('onboarding').style.display = 'none';
    document.getElementById('app').style.display = 'flex';
    updateUI();
  } else {
    // Show onboarding
    Onboarding.render();
    document.getElementById('ob-next').addEventListener('click', () => Onboarding.next());
  }

  // Populate mic device dropdown (getUserMedia permission unlocks labels)
  populateMicDevices();
});
