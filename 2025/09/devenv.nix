{
  pkgs,
  lib,
  # config,
  # inputs,
  ...
}:

{
  packages = [ ];

  languages.python = {
    enable = true;
    uv.enable = true;
    package = pkgs.python314;
  };

  env.LD_LIBRARY_PATH = lib.makeLibraryPath (
    with pkgs;
    [
      zlib
      zstd
      stdenv.cc.cc
      curl
      openssl
      attr
      libssh
      bzip2
      libxml2
      acl
      libsodium
      util-linux
      xz
      systemd
    ]
  );
}
