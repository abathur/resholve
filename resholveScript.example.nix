resholvedScript = resholveScript "name" {
    inputs = [ file ];
    interpreter = "${bash}/bin/bash";
  } ''
    echo "Hello"
    file .
  '';
resholvedScriptBin = resholveScriptBin "name" {
    inputs = [ file ];
    interpreter = "${bash}/bin/bash";
  } ''
    echo "Hello"
    file .
  '';
