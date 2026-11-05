'use strict';

// Echte Band-URLs hier eintragen. Leere Werte bleiben sichtbar als ausstehend.
// Keine erfundenen Profile, Songs oder Booking-Adressen verwenden.
const SITE = Object.freeze({
  bookingEmail: '',
  audio: { src: '', title: '', description: '' },
  socials: { instagram: '', spotify: '', soundcloud: '', bandcamp: '' },
  spotifyEmbed: '', // https://open.spotify.com/embed/artist/...
  soundcloudEmbed: '', // https://w.soundcloud.com/player/?url=...
  youtubeId: '' // Nur die 11-stellige Video-ID
});

const $ = selector => document.querySelector(selector);
const $$ = selector => [...document.querySelectorAll(selector)];
const menu = $('.menu-toggle');
const nav = $('#navigation');
const header = $('.header');
let headerHeight = 0;
function syncHeaderHeight() {
  const height = Math.ceil(header.getBoundingClientRect().height);
  if (height > 0 && height !== headerHeight) {
    headerHeight = height;
    document.documentElement.style.setProperty('--header-height', `${height}px`);
  }
}
syncHeaderHeight();
if (typeof ResizeObserver !== 'undefined') {
  new ResizeObserver(syncHeaderHeight).observe(header);
}
window.addEventListener('resize', syncHeaderHeight, { passive: true });
if (document.fonts) document.fonts.ready.then(syncHeaderHeight);

menu.addEventListener('click', () => {
  const open = menu.getAttribute('aria-expanded') !== 'true';
  menu.setAttribute('aria-expanded', String(open));
  nav.classList.toggle('open', open);
  menu.querySelector('span').textContent = open ? '−' : '+';
});
nav.addEventListener('click', event => {
  if (!event.target.closest('a')) return;
  nav.classList.remove('open');
  menu.setAttribute('aria-expanded', 'false');
  menu.querySelector('span').textContent = '+';
});
document.addEventListener('keydown', event => {
  if (event.key === 'Escape') {
    nav.classList.remove('open');
    menu.setAttribute('aria-expanded', 'false');
    menu.querySelector('span').textContent = '+';
  }
});

function safeHttps(value, allowedHosts) {
  if (!value) return null;
  try {
    const url = new URL(value);
    if (url.protocol !== 'https:' || url.username || url.password) return null;
    if (allowedHosts && !allowedHosts.some(host => url.hostname === host || url.hostname.endsWith('.' + host))) return null;
    return url.href;
  } catch { return null; }
}
const socialHosts = {instagram:['instagram.com'],spotify:['open.spotify.com'],soundcloud:['soundcloud.com'],bandcamp:['bandcamp.com']};
$$('[data-social]').forEach(node => {
  const name = node.dataset.social;
  const href = safeHttps(SITE.socials[name], socialHosts[name]);
  if (!href) return;
  const link = document.createElement('a');
  link.href = href;
  link.target = '_blank';
  link.rel = 'noopener noreferrer';
  link.textContent = {instagram:'Instagram ↗',spotify:'Spotify ↗',soundcloud:'SoundCloud ↗',bandcamp:'Bandcamp ↗'}[name];
  node.replaceWith(link);
});

// Der grafische Player bleibt ohne echte Audiodatei ausdrücklich inaktiv.
const audio = $('#audio');
const play = $('#play-button');
const progress = $('#audio-progress');
const wave = $('.waveform');
let localAudioURL;
for (let i = 0; i < 72; i++) {
  const bar = document.createElement('span');
  bar.style.height = `${12 + Math.abs(Math.sin(i * 1.73) * Math.cos(i * .29)) * 88}%`;
  wave.append(bar);
}
const time = seconds => Number.isFinite(seconds) ? `${Math.floor(seconds / 60)}:${String(Math.floor(seconds % 60)).padStart(2,'0')}` : '--:--';
function updateTime() {
  $('#audio-time').textContent = `${time(audio.currentTime)} / ${time(audio.duration)}`;
  if (Number.isFinite(audio.duration) && audio.duration > 0) progress.value = String(audio.currentTime / audio.duration * 100);
}
function setTrack(src, title, description, isLocal) {
  audio.src = src;
  play.disabled = false;
  progress.disabled = false;
  play.setAttribute('aria-label','Audio abspielen');
  $('#track-title').textContent = title;
  $('#track-description').textContent = description;
  $('#track-state').textContent = isLocal ? 'DEINE LOKALE AUDIODATEI' : 'THE REBELS´DUST / AUDIO';
  $('#player-note').textContent = isLocal ? 'LOKALE VORSCHAU' : 'AUDIO';
  updateTime();
}
const configuredAudio = SITE.audio.src.startsWith('assets/') ? SITE.audio.src : safeHttps(SITE.audio.src);
if (configuredAudio) {
  setTrack(configuredAudio, SITE.audio.title || 'The Rebels´Dust', SITE.audio.description || 'Jetzt anhören.', false);
  $('.audio-demo').hidden = true;
}
play.addEventListener('click', async () => {
  if (!audio.src) return;
  if (!audio.paused) { audio.pause(); return; }
  try { await audio.play(); $('#audio-feedback').textContent = ''; }
  catch { $('#audio-feedback').textContent = 'Die Datei konnte nicht abgespielt werden. Bitte eine andere Audiodatei wählen.'; }
});
audio.addEventListener('play', () => {
  play.innerHTML = '<svg width="20" height="20" viewBox="0 0 24 24" aria-hidden="true"><path fill="currentColor" d="M6 4h4v16H6zM14 4h4v16h-4z"/></svg>';
  play.setAttribute('aria-label','Audio pausieren');
  wave.classList.add('playing');
  $('.music-section').classList.add('music-active');
});
audio.addEventListener('pause', () => {
  play.innerHTML = '<svg width="20" height="20" viewBox="0 0 24 24" aria-hidden="true"><path fill="currentColor" d="m8 4 13 8-13 8z"/></svg>';
  play.setAttribute('aria-label','Audio abspielen');
  wave.classList.remove('playing');
  $('.music-section').classList.remove('music-active');
});
audio.addEventListener('error', () => { $('#audio-feedback').textContent = 'Diese Audiodatei ist nicht verfügbar oder wird vom Browser nicht unterstützt.'; play.disabled = true; progress.disabled = true; });
audio.addEventListener('timeupdate', updateTime);
audio.addEventListener('loadedmetadata', updateTime);
progress.addEventListener('input', () => { if(Number.isFinite(audio.duration)) audio.currentTime = Number(progress.value) / 100 * audio.duration; });
$('#audio-file').addEventListener('change', event => {
  const file = event.target.files[0];
  if (!file) return;
  if (!file.type.startsWith('audio/') && !/\.(mp3|wav|ogg|m4a|flac|aac)$/i.test(file.name)) { $('#audio-feedback').textContent = 'Bitte eine Audiodatei auswählen.'; return; }
  audio.pause();
  if (localAudioURL) URL.revokeObjectURL(localAudioURL);
  localAudioURL = URL.createObjectURL(file);
  setTrack(localAudioURL, file.name.replace(/\.[^.]+$/, ''), 'Lokale Hörprobe. Diese Datei wird nicht hochgeladen.', true);
  $('#audio-feedback').textContent = 'Datei bereit. Mit der Play-Taste starten.';
});

// Externe Player werden erst nach einem bewussten Klick geladen.
function consentEmbed(target, label, src, title, height) {
  const wrap = document.createElement('div'); wrap.className = 'embed-consent';
  const button = document.createElement('button'); button.type = 'button'; button.textContent = `${label} laden ↗`;
  const note = document.createElement('p'); note.textContent = `Beim Laden wird eine Verbindung zu ${label} hergestellt.`; note.className = 'small-copy';
  wrap.append(button,note); target.append(wrap);
  button.addEventListener('click', () => {
    const iframe = document.createElement('iframe'); iframe.src=src; iframe.title=title; iframe.height=String(height); iframe.allow='encrypted-media; fullscreen; picture-in-picture'; iframe.referrerPolicy='strict-origin-when-cross-origin'; iframe.allowFullscreen=true;
    wrap.replaceChildren(iframe);
  },{once:true});
}
const spotify = safeHttps(SITE.spotifyEmbed,['open.spotify.com']);
if(spotify && new URL(spotify).pathname.startsWith('/embed/')) consentEmbed($('#embeds'),'Spotify',spotify,'The Rebels´Dust auf Spotify',352);
const soundcloud = safeHttps(SITE.soundcloudEmbed,['w.soundcloud.com']);
if(soundcloud && new URL(soundcloud).pathname.startsWith('/player/')) consentEmbed($('#embeds'),'SoundCloud',soundcloud,'The Rebels´Dust auf SoundCloud',166);
if(/^[a-zA-Z0-9_-]{11}$/.test(SITE.youtubeId)) {
  const target = $('#video-card'); target.replaceChildren();
  const heading=document.createElement('h3');heading.textContent='The Rebels´Dust / Video'; target.append(heading);
  consentEmbed(target,'YouTube',`https://www.youtube-nocookie.com/embed/${SITE.youtubeId}`,'Musikvideo von The Rebels´Dust',300);
}

// Native Dialoge liefern Tastaturbedienung und Fokus-Rückgabe.
$$('[data-close]').forEach(button => button.addEventListener('click', () => button.closest('dialog').close()));
$$('dialog').forEach(dialog => dialog.addEventListener('click', event => {
  if (event.target !== dialog) return;
  const bounds = dialog.getBoundingClientRect();
  if (event.clientX < bounds.left || event.clientX > bounds.right || event.clientY < bounds.top || event.clientY > bounds.bottom) dialog.close();
}));
$$('[data-gallery]').forEach(button => button.addEventListener('click', () => {
  const target = $('#gallery-content'); target.replaceChildren();
  if (button.dataset.gallery === 'logo') {
    const img = document.createElement('img'); img.src='assets/logo.png'; img.alt='Originallogo von The Rebels Dust'; target.append(img);
  } else { const poster=$('.poster-art').cloneNode(true);poster.querySelector('.media-plus').remove();target.append(poster); }
  const caption=document.createElement('p');caption.className='gallery-caption';caption.textContent=button.dataset.gallery==='logo'?'The Rebels´Dust / Originallogo':'Show-Artwork / Designentwurf für Neuss-Now';target.append(caption);
  $('#gallery-dialog').showModal();
}));

const validBookingEmail = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(SITE.bookingEmail) && !/[\r\n]/.test(SITE.bookingEmail);
if (validBookingEmail) $('#booking-note').textContent = 'Die Anfrage wird für dein E-Mail-Programm vorbereitet. Du prüfst und sendest sie dort selbst.';
let draft = '';
$('#booking-form').addEventListener('submit', event => {
  event.preventDefault();
  const form = event.currentTarget;
  if (!form.reportValidity()) return;
  const values = Object.fromEntries(new FormData(form));
  const eventDate = values.date ? new Date(values.date + 'T12:00:00').toLocaleDateString('de-DE') : 'Noch offen';
  draft=`Booking-Anfrage: The Rebels´Dust\n\nName: ${values.name.trim()}\nE-Mail: ${values.email.trim()}\nVeranstaltung / Ort: ${values.event.trim()}\nWunschtermin: ${eventDate}\n\n${values.message.trim()}\n\nViele Grüße\n${values.name.trim()}`;
  $('#draft-text').value=draft; $('#copy-status').textContent='';
  if(validBookingEmail){$('#send-mail').href=`mailto:${SITE.bookingEmail}?subject=${encodeURIComponent('Booking-Anfrage: The Rebels´Dust')}&body=${encodeURIComponent(draft)}`;$('#send-mail').hidden=false;}
  $('#booking-dialog').showModal();
});
$('#copy-draft').addEventListener('click', async () => {
  try { await navigator.clipboard.writeText(draft); $('#copy-status').textContent='Anfrage kopiert. Es wurde nichts versendet.'; }
  catch { $('#draft-text').focus();$('#draft-text').select();$('#copy-status').textContent='Bitte den markierten Text manuell kopieren.'; }
});
$('#download-draft').addEventListener('click', () => {
  const url=URL.createObjectURL(new Blob([draft],{type:'text/plain;charset=utf-8'}));const link=document.createElement('a');link.href=url;link.download='Booking-Anfrage-The-Rebels-Dust.txt';link.click();setTimeout(()=>URL.revokeObjectURL(url),1000);
});
$$('[data-legal]').forEach(button => button.addEventListener('click', () => {
  const isPrivacy=button.dataset.legal==='datenschutz';
  $('#legal-title').textContent=isPrivacy?'DATENSCHUTZ':'IMPRESSUM';
  $('#legal-content').replaceChildren();
  const p=document.createElement('p');
  p.textContent=isPrivacy?'Entwurfsvorschau: Die endgültigen Datenschutzangaben werden nach Festlegung des Betreibers, der Kontaktadresse und der eingebundenen Dienste ergänzt. Das aktuelle Formular versendet und speichert keine Anfragen auf einem Server. Lokale Audiodateien bleiben im Browser. Drittanbieter-Player werden nur nach einem Klick geladen. Der Hosting-Anbieter kann technische Zugriffsdaten verarbeiten.':'Entwurfsvorschau: Betreiber, ladungsfähige Anschrift und Kontaktadresse sind noch einzutragen. Dieser Hinweis ist ein Platzhalter für das endgültige Impressum.';
  $('#legal-content').append(p);$('#legal-dialog').showModal();
}));
