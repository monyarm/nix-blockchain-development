{
  clangStdenv,
  nodejs,
  fetchFromGitHub,
  pkgs,
  lib,
  xz,
}:
clangStdenv.mkDerivation rec {
  pname = "leap";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "AntelopeIO";
    repo = "leap";
    rev = "v${version}";
    hash = "sha256-X4x8z/xvFrL7I7LRmElYzIWL7Nq9kMkm8VfPzPhVtYk=";
    fetchSubmodules = true;
  };

  prePatch = ''
    find . -type f -name '*.py' -print0 | xargs -0 -I{} sed -i -E 's#/usr/bin/env python3?#${pkgs.python3}/bin/python3#' {}
  '';

  nativeBuildInputs = with pkgs; [pkgconfig cmake clang git python3];

  buildInputs = with pkgs; [
    llvm
    curl.dev
    gmp.dev
    openssl.dev
    libusb1.dev
    bzip2.dev
    (lib.getLib xz)
    (boost.override
      {
        enableShared = false;
        enabledStatic = true;
      })
  ];
}
