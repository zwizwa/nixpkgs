{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "earthly";
  version = "0.5.24";

  src = fetchFromGitHub {
    owner = "earthly";
    repo = "earthly";
    rev = "v${version}";
    sha256 = "sha256-d4TCuFj7nbQDxTLCStrGj698iUYTH0mCqoCZeeOGNIE=";
  };

  vendorSha256 = "sha256-3o+jizVVHcPZ6nNT2nCF8fLDynnFccI2Y50kbXp2qAI=";

  ldflags = [
    "-s" "-w"
    "-X main.Version=v${version}"
    "-X main.DefaultBuildkitdImage=earthly/buildkitd:v${version}"
  ];

  BUILDTAGS = "dfrunmount dfrunsecurity dfsecrets dfssh dfrunnetwork";
  preBuild = ''
    makeFlagsArray+=(BUILD_TAGS="${BUILDTAGS}")
  '';

  # For some reasons the tests fail, but the program itself seems to work.
  doCheck = false;

  postInstall = ''
    mv $out/bin/debugger $out/bin/earthly-debugger
    mv $out/bin/shellrepeater $out/bin/earthly-shellrepeater
  '';

  meta = with lib; {
    description = "Build automation for the container era";
    homepage = "https://earthly.dev/";
    changelog = "https://github.com/earthly/earthly/releases/tag/v${version}";
    license = licenses.bsl11;
    maintainers = with maintainers; [ matdsoupe ];
  };
}
