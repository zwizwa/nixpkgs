{ lib
, stdenv
, fetchFromGitHub
, nix-update-script
, pantheon
, substituteAll
, meson
, ninja
, pkg-config
, vala
, libgee
, gnome-settings-daemon
, granite
, gsettings-desktop-schemas
, gtk3
, libhandy
, libxml2
, libgnomekbd
, libxklavier
, ibus
, onboard
, switchboard
}:

stdenv.mkDerivation rec {
  pname = "switchboard-plug-keyboard";
  version = "2.6.0";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = pname;
    rev = version;
    sha256 = "sha256-Bl0T+8upTdBnLs03UIimcAg0LO40KwuMZRNSM+y/3Hc=";
  };

  patches = [
    ./0001-Remove-Install-Unlisted-Engines-function.patch
    (substituteAll {
      src = ./fix-paths.patch;
      inherit ibus onboard;
    })
  ];

  passthru = {
    updateScript = nix-update-script {
      attrPath = "pantheon.${pname}";
    };
  };

  nativeBuildInputs = [
    libxml2
    meson
    ninja
    pkg-config
    vala
  ];

  buildInputs = [
    gnome-settings-daemon # media-keys
    granite
    gsettings-desktop-schemas
    gtk3
    ibus
    libgee
    libgnomekbd
    libhandy
    libxklavier
    switchboard
  ];

  meta = with lib; {
    description = "Switchboard Keyboard Plug";
    homepage = "https://github.com/elementary/switchboard-plug-keyboard";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    maintainers = teams.pantheon.members;
  };
}
