# --fake 'f:setUp;tearDown builtin:setopt source:/etc/bashrc'
fake = {
  # fake accepts the initial of valid identifier types as a CLI convenience.
  # Use full names in the Nix API.
  function = [ "setUp" "tearDown" ];
  builtin = [ "setopt" ];
  source = [ "/etc/bashrc" ];
};

# --fix 'aliases $GIT:gix /bin/bash'
fix = {
  # all single-word directives use `true` as value
  aliases = true;
  "$GIT" = [ "gix" ];
  "/bin/bash";
};

# --keep 'source:$HOME /etc/bashrc ~/.bashrc'
keep = {
  source = [ "$HOME" ];
  "/etc/bashrc" = true;
  "~/.bashrc" = true;
};
