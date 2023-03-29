{
  gtest,
  gmp,
  lib,
  zqfield-default,
  stdenv,
  ffiasm-src,
}: let
  ffiasm = "${ffiasm-src}/lib/node_modules/ffiasm";
in
  stdenv.mkDerivation rec {
    pname = "ffiasm";
    inherit (ffiasm-src) version meta;

    phases = ["checkPhase" "installPhase"];

    installPhase = ''
      mkdir -p $out
      cp -r ${ffiasm-src}/* $out
    '';

    doCheck = true;
    checkInputs = [gtest gmp zqfield-default];
    checkPhase = ''
      function run_test {
        echo -e "┌─── \033[1mstart \033[34m$1\033[0m ────╌╌╌"
        {
          c++ \
            -I${ffiasm}/c \
            ''${sources[*]} \
            -L${gtest}/lib -lgtest \
            ''${extra_cppflags[*]} \
            -pthread -std=c++11 -Wl,-z,noexecstack \
            -o ./$1

          ./$1 ''${test_args[@]}

        } 2>&1 | sed 's/^/│ /'
        echo -e "└────╼ \033[1mend \033[34m$1\033[0m ────╌╌╌"
      }

      sources=(${ffiasm}/c/splitparstr{,_test}.cpp)
      extra_cppflags=()
      test_args=()
      run_test splitparsestr_test

      zq_files=(${zqfield-default}/lib/{fq,fr}.{cpp,o})
      default_sources=(${ffiasm}/c/{naf,splitparstr,alt_bn128,misc}.cpp ''${zq_files[*]})
      default_extra_cppflags=(-L${gmp}/lib -lgmp -fopenmp -I${zqfield-default}/lib)

      sources=(${ffiasm}/c/alt_bn128_test.cpp ''${default_sources[*]})
      extra_cppflags=(''${default_extra_cppflags[*]})
      run_test altbn128_test

      sources=(${ffiasm}/benchmark/multiexp_g1.cpp ''${default_sources[*]})
      extra_cppflags=(-DCOUNT_OPS ''${default_extra_cppflags[*]})
      test_args=(100)
      run_test multiexp_g1_benchmark

      sources=(${ffiasm}/benchmark/multiexp_g2.cpp ''${default_sources[*]})
      run_test multiexp_g2_benchmark
    '';
  }