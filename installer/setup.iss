; Carby Windows Installer Script
; Requires Inno Setup 6.x - https://jrsoftware.org/isinfo.php
;
; Build steps:
;   1. flutter build windows --release
;   2. Open this .iss in Inno Setup or run build_installer.bat
;   3. Output: installer\Carby_Setup.exe

#define MyAppName      "Carby"
#define MyAppVersion   "1.0.0"
#define MyAppPublisher "Carby"
#define MyAppURL       "https://github.com/MiharaArcadia/ClaudeFinal"
#define MyAppExeName   "carby.exe"
#define MyAppId        "{A3F2C1D4-8B5E-4F9A-BC7D-12345678ABCD}"

; Source: Flutter Windows release build output folder (relative to this .iss file)
#define SourceDir "..\build\windows\x64\runner\Release"

[Setup]
AppId={{#MyAppId}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
LicenseFile=license.txt
OutputDir=.
OutputBaseFilename=Carby_Setup
SetupIconFile=..\windows\runner\resources\app_icon.ico
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
WizardSizePercent=120
DisableWelcomePage=no
DisableDirPage=no
DisableProgramGroupPage=no

; Windows 10 minimum requirement
MinVersion=10.0.17763

; Architecture: 64-bit only
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

; Uninstaller
UninstallDisplayName={#MyAppName}
UninstallDisplayIcon={app}\{#MyAppExeName}
CreateUninstallRegKey=yes

; Visual style
WizardImageFile=compiler:WizModernImage-IS.bmp
WizardSmallImageFile=compiler:WizModernSmallImage-IS.bmp

[Languages]
Name: "german";   MessagesFile: "compiler:Languages\German.isl"
Name: "english";  MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; Main executable
Source: "{#SourceDir}\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion

; Flutter Windows DLLs
Source: "{#SourceDir}\flutter_windows.dll";          DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\msvcp140.dll";                 DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#SourceDir}\vcruntime140.dll";             DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#SourceDir}\vcruntime140_1.dll";           DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist

; Plugin DLLs (Flutter plugins)
Source: "{#SourceDir}\cloud_firestore_plugin.dll";           DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#SourceDir}\firebase_auth_plugin.dll";             DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#SourceDir}\firebase_core_plugin.dll";             DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#SourceDir}\speech_to_text_windows_plugin.dll";    DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#SourceDir}\window_manager_plugin.dll";            DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#SourceDir}\url_launcher_windows_plugin.dll";      DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#SourceDir}\shared_preferences_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist

; All other DLLs in the release folder (catch-all for any additional plugins)
Source: "{#SourceDir}\*.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist

; Flutter data assets (fonts, images, app bundle)
Source: "{#SourceDir}\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
; Start Menu shortcut
Name: "{group}\{#MyAppName}";                    Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{app}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"

; Desktop shortcut (optional, user must tick the checkbox)
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{app}"; Tasks: desktopicon

[Run]
; Launch app after install (optional checkbox)
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
; Clean up any files created at runtime
Type: filesandordirs; Name: "{app}\data\flutter_assets\cache"

[Registry]
; Register app in Windows "Apps & Features"
Root: HKLM; Subkey: "Software\Microsoft\Windows\CurrentVersion\App Paths\carby.exe"; ValueType: string; ValueName: ""; ValueData: "{app}\{#MyAppExeName}"; Flags: uninsdeletekey
Root: HKLM; Subkey: "Software\Microsoft\Windows\CurrentVersion\App Paths\carby.exe"; ValueType: string; ValueName: "Path"; ValueData: "{app}"; Flags: uninsdeletekey

[Code]
// Check Windows version at install time
function InitializeSetup(): Boolean;
var
  Version: TWindowsVersion;
begin
  GetWindowsVersionEx(Version);
  if Version.Major < 10 then
  begin
    MsgBox('Carby benötigt Windows 10 oder höher.' + #13#10 +
           'Carby requires Windows 10 or higher.', mbError, MB_OK);
    Result := False;
  end
  else
    Result := True;
end;
