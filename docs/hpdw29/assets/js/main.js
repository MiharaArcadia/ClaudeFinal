/* ============================================================================
   GRILLPALAST NEUSS — Demo  ·  Interaktionen
   Mobile-Menü · Scroll-Reveal · Menü-Navigation · Warenkorb-Feedback · Formular
   Alles rein visuell/Frontend — keine echte Bestell- oder Zahlungslogik.
   ========================================================================== */
(function () {
  'use strict';
  var reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var $  = function (s, c) { return (c || document).querySelector(s); };
  var $$ = function (s, c) { return Array.prototype.slice.call((c || document).querySelectorAll(s)); };

  /* ------------------------------------------------- Footer-Jahr */
  $$('[data-year]').forEach(function (el) { el.textContent = new Date().getFullYear(); });

  /* ------------------------------------------------- Sticky-Header Schatten */
  var header = $('.site-header');
  if (header) {
    var onScroll = function () { header.classList.toggle('is-stuck', window.scrollY > 8); };
    onScroll();
    window.addEventListener('scroll', onScroll, { passive: true });
  }

  /* ------------------------------------------------- Mobile-Drawer */
  var drawer = $('#drawer');
  var scrim  = $('#drawer-scrim');
  var burger = $('#burger');
  var lastFocus = null;

  function openDrawer() {
    if (!drawer) return;
    lastFocus = document.activeElement;
    drawer.classList.add('is-open');
    scrim.classList.add('is-open');
    drawer.setAttribute('aria-hidden', 'false');
    if (burger) burger.setAttribute('aria-expanded', 'true');
    document.body.style.overflow = 'hidden';
    var first = drawer.querySelector('a, button');
    if (first) first.focus();
  }
  function closeDrawer() {
    if (!drawer) return;
    drawer.classList.remove('is-open');
    scrim.classList.remove('is-open');
    drawer.setAttribute('aria-hidden', 'true');
    if (burger) burger.setAttribute('aria-expanded', 'false');
    document.body.style.overflow = '';
    if (lastFocus) lastFocus.focus();
  }
  if (burger) burger.addEventListener('click', openDrawer);
  if (scrim)  scrim.addEventListener('click', closeDrawer);
  $$('[data-close-drawer]').forEach(function (b) { b.addEventListener('click', closeDrawer); });
  if (drawer) $$('a', drawer).forEach(function (a) { a.addEventListener('click', closeDrawer); });
  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape' && drawer && drawer.classList.contains('is-open')) closeDrawer();
  });

  /* ------------------------------------------------- Scroll-Reveal */
  var reveals = $$('.reveal');
  if (reduce || !('IntersectionObserver' in window)) {
    reveals.forEach(function (el) { el.classList.add('in'); });
  } else {
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (en) {
        if (en.isIntersecting) { en.target.classList.add('in'); io.unobserve(en.target); }
      });
    }, { rootMargin: '0px 0px -8% 0px', threshold: 0.08 });
    reveals.forEach(function (el) { io.observe(el); });
  }

  /* ------------------------------------------------- Speisekarte: Kategorie-Tabs + Scrollspy */
  var tabs = $$('.tab[data-target]');
  if (tabs.length) {
    var cats = tabs.map(function (t) { return document.getElementById(t.getAttribute('data-target')); })
                   .filter(Boolean);

    tabs.forEach(function (tab) {
      tab.addEventListener('click', function () {
        var target = document.getElementById(tab.getAttribute('data-target'));
        if (!target) return;
        var top = target.getBoundingClientRect().top + window.scrollY - 150;
        window.scrollTo({ top: top, behavior: reduce ? 'auto' : 'smooth' });
      });
    });

    // Deterministischer Scrollspy: aktive Kategorie = letzte, deren Oberkante die
    // Linie (unter Header + Tabs) bereits passiert hat. Vermeidet IO-Race beim Laden.
    var lastId = null;
    var syncActive = function () {
      if (!cats.length) return;
      var line = 175, current = cats[0];
      for (var i = 0; i < cats.length; i++) {
        if (cats[i].getBoundingClientRect().top <= line) current = cats[i];
      }
      if (!current || current.id === lastId) return;
      lastId = current.id;
      tabs.forEach(function (t) {
        var on = t.getAttribute('data-target') === current.id;
        t.classList.toggle('is-active', on);
        if (on) t.scrollIntoView({ block: 'nearest', inline: 'center' });
      });
    };
    var ticking = false;
    window.addEventListener('scroll', function () {
      if (ticking) return;
      ticking = true;
      requestAnimationFrame(function () { syncActive(); ticking = false; });
    }, { passive: true });
    syncActive();
  }

  /* ------------------------------------------------- Personen-Stepper */
  $$('[data-stepper]').forEach(function (st) {
    var out = $('[data-stepper-val]', st);
    var min = parseInt(st.getAttribute('data-min') || '1', 10);
    var max = parseInt(st.getAttribute('data-max') || '20', 10);
    var val = parseInt(out.textContent, 10) || min;
    var input = $('input[type=hidden]', st);
    var render = function () { out.textContent = val; if (input) input.value = val; };
    $$('[data-step]', st).forEach(function (b) {
      b.addEventListener('click', function () {
        val = Math.min(max, Math.max(min, val + parseInt(b.getAttribute('data-step'), 10)));
        render();
      });
    });
    render();
  });

  /* ------------------------------------------------- Warenkorb-Feedback (visuell) */
  var cartCount = 0;
  var counters  = $$('[data-cart-count]');
  function bumpCart(name) {
    cartCount++;
    counters.forEach(function (c) {
      c.textContent = cartCount;
      c.classList.add('is-on');
      c.classList.remove('is-on'); void c.offsetWidth; c.classList.add('is-on'); // restart pop
    });
    toast('„' + name + '" hinzugefügt · Demo – keine echte Bestellung');
  }
  $$('[data-add]').forEach(function (btn) {
    btn.addEventListener('click', function () { bumpCart(btn.getAttribute('data-add') || 'Gericht'); });
  });

  /* ------------------------------------------------- Toast */
  var toastWrap;
  function toast(msg) {
    if (!toastWrap) {
      toastWrap = document.createElement('div');
      toastWrap.className = 'toast-wrap';
      document.body.appendChild(toastWrap);
    }
    var t = document.createElement('div');
    t.className = 'toast';
    t.innerHTML = '<span class="ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6L9 17l-5-5"/></svg></span><span></span>';
    t.querySelector('span:last-child').textContent = msg;
    toastWrap.appendChild(t);
    setTimeout(function () {
      t.classList.add('is-out');
      setTimeout(function () { if (t.parentNode) t.parentNode.removeChild(t); }, 320);
    }, 3200);
  }

  /* ------------------------------------------------- Reservierungs-/Kontaktformular (Demo) */
  $$('form[data-demo-form]').forEach(function (form) {
    var success = $('.form-success', form.parentNode) || $('.form-success', form);
    form.addEventListener('submit', function (e) {
      e.preventDefault();
      // einfache Validierung der Pflichtfelder
      var ok = true;
      $$('[required]', form).forEach(function (field) {
        var wrap = field.closest('.field');
        var valid = field.value && field.value.trim().length > 0;
        if (field.type === 'email') valid = valid && /.+@.+\..+/.test(field.value);
        if (wrap) wrap.classList.toggle('has-error', !valid);
        if (!valid && ok) { field.focus(); ok = false; }
        else if (!valid) ok = false;
      });
      if (!ok) return;

      var btn = $('button[type=submit]', form);
      if (btn) { btn.disabled = true; btn.dataset.label = btn.textContent; btn.textContent = 'Wird gesendet …'; }
      setTimeout(function () {
        var card = form.closest('.form') || form;
        card.classList.add('is-submitted');
        if (success) success.classList.add('is-on');
        if (success) success.scrollIntoView({ block: 'nearest', behavior: reduce ? 'auto' : 'smooth' });
      }, 650);
    });
    // Fehler beim Tippen aufheben
    $$('[required]', form).forEach(function (field) {
      field.addEventListener('input', function () {
        var wrap = field.closest('.field');
        if (wrap) wrap.classList.remove('has-error');
      });
    });
  });

  // „Neue Reservierung" – Formular zurücksetzen
  $$('[data-reset-form]').forEach(function (b) {
    b.addEventListener('click', function () {
      var card = b.closest('.form') || document;
      var form = $('form[data-demo-form]', card);
      var success = $('.form-success', card);
      if (form) { form.reset(); var btn = $('button[type=submit]', form); if (btn) { btn.disabled = false; if (btn.dataset.label) btn.textContent = btn.dataset.label; } }
      if (card.classList) card.classList.remove('is-submitted');
      if (success) success.classList.remove('is-on');
    });
  });

  /* ------------------------------------------------- Jahr-/Datum-Vorbelegung Reservierung */
  $$('input[type=date][data-default-today]').forEach(function (inp) {
    var d = new Date(); d.setDate(d.getDate() + 1); // morgen
    inp.value = d.toISOString().slice(0, 10);
    inp.min = new Date().toISOString().slice(0, 10);
  });

  /* ------------------------------------------------- Öffnungszeiten: heute hervorheben */
  $$('[data-hours] tr[data-day]').forEach(function (row) {
    var days = row.getAttribute('data-day').split(',').map(Number);
    if (days.indexOf(new Date().getDay()) !== -1) row.classList.add('is-today');
  });
})();
