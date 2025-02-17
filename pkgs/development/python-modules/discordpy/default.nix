{ lib
, aiohttp
, buildPythonPackage
, fetchFromGitHub
, libopus
, pynacl
, pythonOlder
, withVoice ? true
}:

buildPythonPackage rec {
  pname = "discord.py";
  version = "1.7.3";
  format = "setuptools";

  disabled = pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "Rapptz";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-eKXCzGFSzxpdZed4/4G6uJ96s5yCm6ci8K8XYR1zQlE=";
  };

  propagatedBuildInputs = [
    aiohttp
  ] ++ lib.optionalString withVoice [
    libopus
    pynacl
  ];

  patchPhase = ''
    substituteInPlace "discord/opus.py" \
      --replace "ctypes.util.find_library('opus')" "'${libopus}/lib/libopus.so.0'"
    substituteInPlace requirements.txt \
      --replace "aiohttp>=3.6.0,<3.8.0" "aiohttp>=3.6.0,<4"
  '';

  # Only have integration tests with discord
  doCheck = false;

  pythonImportsCheck = [
    "discord"
    "discord.file"
    "discord.member"
    "discord.user"
    "discord.state"
    "discord.guild"
    "discord.webhook"
    "discord.ext.commands.bot"
  ];

  meta = with lib; {
    description = "Python wrapper for the Discord API";
    homepage = "https://discordpy.rtfd.org/";
    license = licenses.mit;
    maintainers = with maintainers; [ ivar ];
  };
}
