const { contextBridge, ipcRenderer } = require('electron');

// Expose a safe API to the renderer process
contextBridge.exposeInMainWorld('electronAPI', {
  // Persistent store
  storeGet: (key) => ipcRenderer.invoke('store-get', key),
  storeSet: (key, value) => ipcRenderer.invoke('store-set', key, value),
  storeDelete: (key) => ipcRenderer.invoke('store-delete', key),
  storeClear: () => ipcRenderer.invoke('store-clear'),

  // Open links in default browser
  openExternal: (url) => ipcRenderer.invoke('open-external', url),

  // App info
  platform: process.platform,
  isPackaged: process.env.NODE_ENV === 'production',
});
