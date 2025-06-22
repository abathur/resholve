{
  stdenv,
  resholve,
  module1,
}:

stdenv.mkDerivation {
  # pname = "testmod3";
  # version = "unreleased";
  # src = ...;

  installPhase = ''
    mkdir -p $out/bin
    install conjure.sh $out/bin/conjure.sh
    ${resholve.phraseSolution "conjure" {
      scripts = [ "bin/conjure.sh" ];
      interpreter = "${bash}/bin/bash";
      inputs = [ module1 ];
      fake = {
        external = [
          "jq"
          "openssl"
        ];
      };
    }}
  '';
}
