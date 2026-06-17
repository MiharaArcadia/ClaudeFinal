const { app, BrowserWindow, ipcMain, shell, session } = require('electron');
const path = require('path');
const Store = require('electron-store');

const store = new Store();

// Chromium needs these switches to allow microphone access from file:// pages
app.commandLine.appendSwitch('allow-file-access-from-files');
app.commandLine.appendSwitch('enable-features', 'WebSpeechAPI');
app.commandLine.appendSwitch('disable-features', 'AudioServiceSandbox');

function createWindow() {
  const win = new BrowserWindow({
    width: 1280,
    height: 800,
    minWidth: 900,
    minHeight: 600,
    backgroundColor: '#0D0D0D',
    titleBarStyle: 'default',
    title: 'Carby',
    icon: path.join(__dirname, 'assets', 'icon.ico'),
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      nodeIntegration: false,
      contextIsolation: true,
      webSecurity: false,
    },
  });

  win.loadFile(path.join(__dirname, 'renderer', 'index.html'));

  if (app.isPackaged) {
    win.setMenuBarVisibility(false);
  }
}

app.whenReady().then(() => {
  // setPermissionCheckHandler: Chromium's SpeechRecognition checks FIRST whether
  // microphone permission is already granted. Without this returning true the
  // recognition fires onend immediately without ever capturing audio.
  session.defaultSession.setPermissionCheckHandler((webContents, permission) => {
    return permission === 'microphone' || permission === 'media';
  });

  // setPermissionRequestHandler: handles the actual permission grant when asked.
  session.defaultSession.setPermissionRequestHandler((webContents, permission, callback) => {
    callback(permission === 'media' || permission === 'microphone');
  });

  createWindow();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});

// ── IPC: electron-store ──────────────────────────────────────────────────────
ipcMain.handle('store-get', (_event, key) => store.get(key));
ipcMain.handle('store-set', (_event, key, value) => { store.set(key, value); });
ipcMain.handle('store-delete', (_event, key) => { store.delete(key); });
ipcMain.handle('store-clear', () => { store.clear(); });

// ── IPC: Open external links safely ─────────────────────────────────────────
ipcMain.handle('open-external', (_event, url) => shell.openExternal(url));
