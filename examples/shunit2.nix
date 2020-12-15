{ stdenv, fetchFromGitHub, resholve }:

resholve.resholvePackage {
  pname = "shunit2";
  version = "2019-08-10";

  src = fetchFromGitHub {
    owner = "kward";
    repo = "shunit2";
    rev = "ba130d69bbff304c0c6a9c5e8ab549ae140d6225";
    sha256 = "1bsn8dhxbjfmh01lq80yhnld3w3fw1flh7nwx12csrp58zsvlmgk";
  };

  installPhase = ''
    mkdir -p $out/bin/
    cp ./shunit2 $out/bin/shunit2
    chmod +x $out/bin/shunit2
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/shunit2
  '';

  scripts = [ "bin/shunit2" ];
  inputs = [ coreutils gnused gnugrep findutils ];

  # resholve's Nix API is analogous to the CLI flags
  # documented in 'man resholve'
  fake = {
    # "missing" functions shunit2 expects the user to declare
    function = [
      "oneTimeSetUp"
      "oneTimeTearDown"
      "setUp"
      "tearDown"
      "suite"
      "noexec"
    ];
    # shunit2 is both bash and zsh compatible, and in
    # some zsh-specific code it uses this non-bash builtin
    builtin = [ "setopt" ];
  };
  fix = {
    # stray absolute path; make it resolve from coreutils
    "/usr/bin/od" = true;
  };
  keep = {
    # dynamically defined in shunit2:_shunit_mktempFunc
    eval = [ "shunit_condition_" "_shunit_test_" ];

    # variables invoked as commands; long-term goal is to
    # resolve the *variable*, but that is complexish, so
    # this is where we are...
    "$__SHUNIT_CMD_ECHO_ESC" = true;
    "$_SHUNIT_LINENO_" = true;
    "$SHUNIT_CMD_TPUT" = true;
  };

  meta = with stdenv.lib; {
    homepage = "https://github.com/kward/shunit2";
    description = "A xUnit based unit test framework for Bourne based shell scripts";
    maintainers = with maintainers; [ cdepillabout utdemir ];
    license = licenses.asl20;
    platforms = platforms.unix;
  };
}
