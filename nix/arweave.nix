{ pkgs }:


let
  gitignoreSrc = fetchFromGitHub {
    owner = "hercules-ci";
    repo = "gitignore.nix";
    rev = "a20de23b925fd8264fd7fad6454652e142fd7f73";
    sha256 = "sha256-8DFJjXG8zqoONA1vXtgeKXy68KdJL5UaXR8NtVMUbx8=";
  };

  inherit (import gitignoreSrc { inherit (pkgs) lib; }) gitignoreFilterWith;
  inherit (pkgs) stdenv lib beamPackages fetchFromGitHub fetchFromGitLab fetchHex;

  randomx = fetchFromGitHub {
    owner = "arweaveteam";
    repo = "RandomX";
    rev = "d64fce8329f85bbafe43ffbfd03284242b13fb1c";
    sha256 = "sha256-+SrRGAasQcwo5gJm646Ci+31y6tJ0lgIAlzaeEez1CU=";
    fetchSubmodules = true;
  };

  buildRebar = beamPackages.buildRebar3.override { openssl = pkgs.openssl_1_1; };

  b64fast = buildRebar rec {
    name = "b64fast";
    version = "0.2.2";
    beamDeps = [ beamPackages.pc ];
    compilePort = true;

    src = fetchFromGitHub {
      owner = "arweaveteam";
      repo = name;
      rev = "a0ef55ec66ecf705848716c195bf45665f78818a";
      sha256 = "sha256-CSBsTRqkrQWwX7oxPZWERss5Pk0mE1ETe7s4fhZEUaA=";
      fetchSubmodules = true;
    };

    postBuild = ''
      env rebar3 pc compile
    '';
  };

  erlang-rocksdb = buildRebar rec {
    name = "erlang-rocksdb";
    version = "ed4d05d58d174485f883b5cd3e057c64d9e7ff3a";
    beamDeps = [ beamPackages.pc ];
    nativeBuildInputs = [ pkgs.cmake ];
    buildInputs = [ pkgs.getconf ];
    configurePhase = "true";
    src = fetchFromGitLab {
      owner = "arweave1";
      repo = name;
      rev = version;
      sha256 = "1avgvqwnk780db6z2l66dk73ly3abvh2qqf357al60bzky4545yv";
    };
    postInstall = ''
      mv $out/lib/erlang/lib/erlang-rocksdb-${version} $out/lib/erlang/lib/rocksdb-1.6.0
    '';
  };

  meck = buildRebar rec {
    name = "meck";
    version = "0.8.13";
    src = fetchHex {
      inherit version;
      pkg = name;
      sha256 = "sha256-008BPBVttRrVfMVWiRuXIOahwd9f4uFa+ZnITWzr6xo=";
    };
  };


  rebar3_hex = buildRebar {
    name = "rebar3_hex";
    version = "none";
    src = fetchFromGitHub {
      owner = "erlef";
      repo = "rebar3_hex";
      rev = "203466094b98fcbed9251efa1deeb69fefd8eb0a";
      sha256 = "gVmoRzinc4MgcdKtqgUBV5/TGeWulP5Cm1pTsSWa07c=";
      fetchSubmodules = true;
    };
  };

  geas_rebar3 = buildRebar {
    name = "geas_rebar3";
    version = "none";
    src = fetchFromGitHub {
      owner = "crownedgrouse";
      repo = "geas_rebar3";
      rev = "e3170a36af491b8c427652c0c57290011190b1fb";
      sha256 = "ooMalh8zZ94WlCBcvok5xb7a+7fui4/b+gnEEYpn7fE=";
    };
  };

  graphql = buildRebar {
    name = "graphql-erlang";
    version = "none";
    beamDeps = [ beamPackages.pc geas_rebar3 rebar3_hex ];

    patchPhase = ''
      substituteInPlace src/graphql.erl \
        --replace 'graphql/include/graphql.hrl' 'include/graphql.hrl'
      substituteInPlace src/graphql_ast.erl \
        --replace 'graphql/include/graphql.hrl' 'include/graphql.hrl'
      substituteInPlace src/graphql_err.erl \
        --replace 'graphql/include/graphql.hrl' 'include/graphql.hrl'
      substituteInPlace src/graphql_parser.yrl \
        --replace 'graphql/include/graphql.hrl' 'include/graphql.hrl'
      substituteInPlace src/graphql_introspection.erl \
        --replace 'graphql/include/graphql.hrl' 'include/graphql.hrl'
      substituteInPlace src/graphql_execute.erl \
        --replace 'graphql/include/graphql.hrl' 'include/graphql.hrl'
      substituteInPlace src/graphql_check.erl \
        --replace 'graphql/include/graphql.hrl' 'include/graphql.hrl'
    '';
    src = fetchFromGitHub {
      owner = "jlouis";
      repo = "graphql-erlang";
      rev = "4fd356294c2acea42a024366bc5a64661e4862d7";
      sha256 = "lJ6mEP5ab4GbFzlnbf9U9bAlZ+HGFZLbOZNvTUO1Dhw=";
    };
    postInstall = ''
      mv $out/lib/erlang/lib/graphql-erlang-none $out/lib/erlang/lib/graphql_erl-0.16.1
    '';
  };

  accept = buildRebar rec {
    name = "accept";
    version = "0.3.5";
    src = fetchHex {
      inherit version;
      pkg = name;
      sha256 = "sha256-EbGMIgvMLqtjtUcMA47xDrZ4O8sfzbEapBN976WsG7g=";
    };
  };

  double-conversion = fetchFromGitHub {
    owner = "google";
    repo = "double-conversion";
    rev = "32bc443c60c860eb6b4843533a614766d611172e";
    sha256 = "sha256-ysWwhvcVSWnF5HoJW0WB3MYpJ+dvqz3068G/uX9aBlU=";
  };

  jiffy = buildRebar rec {
    name = "jiffy";
    version = "1.0.8";
    nativeBuildInputs = with pkgs; [ gnumake pkg-config ];
    buildInputs = [ pkgs.gnumake ];
    configureFlags = [ "-fno-lto" ];
    hardeningDisable = [ "all" ];

    src = fetchFromGitHub {
      owner = "ArweaveTeam";
      repo = name;
      rev = "82792758e61be7d303a11290f859a7b3b20eaf95";
      sha256 = "R7kbdMh5wOIN/aA7KFrICjlFAym3OJs9sYWrfdU06GM=";
    };

    patchPhase = ''
      sed -i -e 's|-compile.*||g' rebar.config
      rm -rf c_src/double-conversion
      cp -rf ${double-conversion}/double-conversion c_src/double-conversion
      chmod -R +rw c_src/double-conversion
    '';
  };

  quantile_estimator = buildRebar rec {
    name = "quantile_estimator";
    version = "0.2.1";
    src = fetchHex {
      inherit version;
      pkg = name;
      sha256 = "sha256-KCqKMjyiqEXJ5veH0WY0j3dsHUpB7eYwRtctQi49qUY=";
    };
  };

  prometheus = buildRebar rec {
    name = "prometheus";
    version = "4.10.0";
    buildInputs = [ quantile_estimator ];
    src = fetchHex {
      inherit version;
      pkg = name;
      sha256 = "sha256-Kpm7bc6F4jjHI2/eawBk+YNNxCDdvZYqrE6io8PVk4Q=";
    };
  };

  prometheus_httpd = buildRebar rec {
    name = "prometheus_httpd";
    version = "2.1.11";
    src = fetchHex {
      inherit version;
      pkg = name;
      sha256 = "sha256-C76DFFLP35WIU46y9XCybzDDSK2uXpWn2H81pZELz5I=";
    };
  };

  prometheus_cowboy = buildRebar rec {
    name = "prometheus_cowboy";
    version = "0.1.8";
    src = fetchHex {
      inherit version;
      pkg = name;
      sha256 = "sha256-uihr7KkwJhhBiJLTe81dxmmmzAAfTrbWr4X/gfP080w=";
    };
  };

  prometheus_process_collector = buildRebar rec {
    name = "prometheus_process_collector";
    version = "1.6.0";
    buildInputs = [ rebar3_archive_plugin rebar3_hex ];
    patchPhase = ''
      rm -rf .git
    '';

    src = fetchFromGitHub {
      owner = "deadtrickster";
      repo = name;
      rev = "78697537f01a858959a26a9c74db5aad2971b244";
      sha256 = "sha256-3Bb4d63JMdexzAI68Q+ASsj4FfNxQ9OUlG41fhFkMds=";
    };

    postInstall = ''
      mv $out/lib/erlang/lib/prometheus_process_collector-${version}/priv/source.so \
        $out/lib/erlang/lib/prometheus_process_collector-${version}/priv/prometheus_process_collector.so
    '';
  };

  rebar3_archive_plugin = buildRebar rec {
    name = "rebar3_archive_plugin";
    version = "0.0.2";
    src = fetchHex {
      inherit version;
      pkg = name;
      sha256 = "sha256-hMa0F1EdeazKg3WrLHXSD+zG0OK0C/puDz1i3OsyBYQ=";
    };
  };

  rebar3_elvis_plugin = buildRebar rec {
    name = "rebar3_elvis_plugin";
    version = "0b7dd1a3808dbe2e2e916ecf3afd1ff24e723021";
    src = fetchFromGitHub {
      owner = "deadtrickster";
      repo = name;
      rev = version;
      sha256 = "zM3WPLlbi05aYqMR5AhlNejBaPa6/nSIlq6CG7uNBoo=";
    };
  };

  cowlib = buildRebar rec {
    name = "cowlib";
    version = "e9448e5628c8c1d9083223ff973af8de31a566d1";
    src = fetchFromGitHub {
      owner = "ninenines";
      repo = "cowlib";
      rev = version;
      sha256 = "1j7b602hq9ndh0w3s7jcs923jclmiwfdmbfxaljcra5sl23ydwgf";
    };
  };

  cowboy = buildRebar rec {
    name = "cowboy";
    version = "2.9.0";
    buildInputs = [ cowlib rebar3_archive_plugin ranch ];
    beamDeps = [ cowlib rebar3_archive_plugin ranch ];
    plugins = [ beamPackages.pc ];
    src = fetchHex {
      inherit version;
      pkg = name;
      sha256 = "sha256-LHKfk0tOGqFJr/iC9XxjcsFTmaINVPZcjWe+9YMCG94=";
    };
  };

  gun = buildRebar rec {
    name = "gun";
    version = "1.3.3";
    beamDeps = [ beamPackages.pc geas_rebar3 rebar3_hex cowlib ];
    src = fetchHex {
      inherit version;
      pkg = name;
      sha256 = "sha256-MQbOFn+clyP4SeT7VOpKTYFOOZauJDocgoslbnSQQeA=";
    };
  };

  ranch = buildRebar rec {
    name = "ranch";
    version = "2.1.0";
    src = fetchFromGitHub {
      owner = "ninenines";
      repo = name;
      rev = version;
      sha256 = "sha256-Uchp4bE39rWSprNYYdVDE9uk0IZWznsLt9it5dYZQNQ=";
    };
  };

  stopScript = pkgs.writeTextFile {
    name = "stop-nix";
    text = ''
      #! ${pkgs.stdenv.shell} -e

      PATH=
      ROOT_DIR=
      PROFILE_DIR=

      cd $ROOT_DIR
      export ERL_EPMD_ADDRESS=127.0.0.1

      erl -pa $(echo $PROFILE_DIR/lib/*/ebin) \
        -noshell \
        -config config/sys.config \
        -name stopper@127.0.0.1 \
        -setcookie arweave \
        -s ar shutdown arweave@127.0.0.1 -s init stop
    '';
  };

  startScript = pkgs.writeTextFile {
    name = "start-nix";
    text = ''
      #! ${pkgs.stdenv.shell} -e

      PATH=
      ROOT_DIR=
      PROFILE_DIR=

      ERL_CRASH_DUMP=$(pwd)/erl_crash.dump
      cd $ROOT_DIR
      $ROOT_DIR/bin/check-nofile
      if [ $# -gt 0 ] && [ `uname -s` == "Darwin" ]; then
        RANDOMX_JIT="disable randomx_jit"
      else
        RANDOMX_JIT=
      fi

      : "''${ERL_EPMD_ADDRESS:=127.0.0.1}"
      export ERL_EPMD_ADDRESS

      erl +MBas aobf +MBlmbcs 512 +A100 +SDio100 +A100 +SDio100 +Bi -pa $(echo $PROFILE_DIR/lib/*/ebin) \
       -config $ROOT_DIR/config/sys.config \
       -args_file $ROOT_DIR/config/vm.args.dev \
       -run ar main $RANDOMX_JIT "$@"
    '';
  };

  startScriptForeground = pkgs.writeTextFile {
    name = "start-nix-foreground";
    text = ''
      #! ${pkgs.stdenv.shell} -e

      PATH=
      ROOT_DIR=
      PROFILE_DIR=

      ERL_CRASH_DUMP=$(pwd)/erl_crash.dump
      cd $PROFILE_DIR
      $ROOT_DIR/bin/check-nofile
      if [ $# -gt 0 ] && [ `uname -s` == "Darwin" ]; then
        RANDOMX_JIT="disable randomx_jit"
      else
        RANDOMX_JIT=
      fi

      : "''${ERL_EPMD_ADDRESS:=127.0.0.1}"
      : "''${ERL_EPMD_PATH:=${pkgs.erlang}/bin}"
      export ERL_EPMD_ADDRESS
      export ERL_EPMD_PATH

      export BINDIR=$ROOT_DIR/erts/bin
      export EMU="beam"
      export TERM="dumb"
      BOOTFILE=$(echo $PROFILE_DIR/releases/*/start.boot | sed -e "s/\.boot$//")

      erlexec -noinput +Bd -boot "$BOOTFILE" \
       -config $ROOT_DIR/config/sys.config \
       -mode embedded \
       +MBas aobf +MBlmbcs 512 +A100 +SDio100 +A100 +SDio100 +Bi -pa $(echo $PROFILE_DIR/lib/*/ebin) \
       -args_file $ROOT_DIR/config/vm.args.dev \
       -run ar main $RANDOMX_JIT "$@"
    '';
  };

  arweaveSources = ../.;
  sourcesFilter = src:
    let
      srcIgnored = gitignoreFilterWith {
        basePath = src;
        extraRules = ''
          .github/*
          doc
        '';
      };
    in
    path: type:
      srcIgnored path type;

  arweaveVersion = "2.6.10";

  mkArweaveApp = { installPhase, profile, releaseType }:
    beamPackages.rebar3Relx {
      inherit profile releaseType;
      pname = "arweave-${profile}";
      version = arweaveVersion;
      src = lib.cleanSourceWith {
        filter = sourcesFilter arweaveSources;
        src = arweaveSources;
        name = "arweave-source";
      };
      plugins = [
        pkgs.beamPackages.pc
        rebar3_archive_plugin
        rebar3_elvis_plugin
      ];

      doStrip = false;

      nativeBuildInputs = with pkgs; [ clang-tools cmake pkg-config ];

      beamDeps = [
        beamPackages.pc
        geas_rebar3
        rebar3_hex
        b64fast
        erlang-rocksdb
        jiffy
        accept
        gun
        ranch
        cowlib
        meck
        cowboy
        quantile_estimator
        prometheus
        prometheus_process_collector
        prometheus_cowboy
        prometheus_httpd
      ];

      buildInputs = with pkgs; [
        darwin.sigtool
        erlang
        git
        gmp
        beamPackages.pc
        ncurses
        which
      ];

      postConfigure = ''
        rm -rf apps/arweave/lib/RandomX
        mkdir -p apps/arweave/lib/RandomX
        cp -rf ${randomx}/* apps/arweave/lib/RandomX
        cp -rf ${jiffy}/lib/erlang/lib/* apps/jiffy
        cp -rf ${graphql}/lib/erlang/lib/* apps/graphql
      '';

      postPatch = ''
        sed -i -e 's|-arch x86_64|-arch ${pkgs.stdenv.targetPlatform.linuxArch}|g' \
          apps/arweave/c_src/Makefile \
          apps/ar_sqlite3/c_src/Makefile

        sed -i -e 's|{b64fast,.*|{b64fast, "0.2.2"},|g' rebar.config
        sed -i -e 's|{graphql,.*|{graphql_erl, "0.16.1"},|g' rebar.config
        sed -i -e 's|{meck, "0.8.13"}||g' rebar.config
      '';

      installPhase = ''
        mkdir -p $out/bin
        cp -rf ./bin/* $out/bin
        ${installPhase}
        # broken symlinks fixup
        rm -f $out/${profile}/rel/arweave/releases/*/{sys.config,vm.args.src}
        ln -s $out/config/{sys.config,vm.args.src} $out/${profile}/rel/arweave/releases/*/

        rm -f $out/${profile}/lib/arweave/{include,priv,src}
        ln -s $out/${profile}/rel/arweave/lib/arweave-*/{include,priv,src} $out/${profile}/lib/arweave

        rm -f $out/${profile}/lib/ar_sqlite3/{include,priv,src}
        ln -s $out/${profile}/rel/arweave/lib/ar_sqlite3-*/{include,priv,src} $out/${profile}/lib/ar_sqlite3

        rm -f $out/${profile}/lib/graphql/{include,priv,src}
        ln -s $out/${profile}/rel/arweave/lib/graphql-*/{include,priv,src} $out/${profile}/lib/graphql

        rm -f $out/${profile}/lib/jiffy/{include,priv,src}
        ln -s $out/${profile}/rel/arweave/lib/jiffy-*/{include,priv,src} $out/${profile}/lib/jiffy

        rm -rf $out/${profile}/rel/arweave/lib/jiffy-*/priv
        cp -rf ${jiffy}/lib/erlang/lib/jiffy-*/priv $out/${profile}/rel/arweave/lib/jiffy-*

        rm -rf $out/${profile}/rel/arweave/lib/arweave-*/priv
        cp -rf ./apps/arweave/priv $out/${profile}/rel/arweave/lib/arweave-*

        rm -rf $out/${profile}/rel/arweave/lib/ar_sqlite3-*/priv
        cp -rf ./apps/ar_sqlite3/priv $out/${profile}/rel/arweave/lib/ar_sqlite3-*
      '';
    };

  arweaveTestProfile = mkArweaveApp {
    profile = "test";
    releaseType = "release";
    installPhase = ''
      mkdir -p $out; cp -rf ./_build/test $out
      cp -r ./config $out
      ln -s ${meck}/lib/erlang/lib/meck-${meck.version} $out/test/rel/arweave/lib/

      ARWEAVE_LIB_PATH=$(basename $(echo $out/test/rel/arweave/lib/arweave-*))
      AR_SQLITE_LIB_PATH=$(basename $(echo $out/test/rel/arweave/lib/ar_sqlite3-*))
      GRAPHQL_LIB_PATH=$(basename $(echo $out/test/rel/arweave/lib/graphql-*))
      JIFFY_LIB_PATH=$(basename $(echo $out/test/rel/arweave/lib/jiffy-*))

      rm -f $out/test/rel/arweave/lib/arweave-*
      rm -f $out/test/rel/arweave/lib/ar_sqlite3-*
      rm -f $out/test/rel/arweave/lib/graphql-*
      rm -f $out/test/rel/arweave/lib/jiffy-*

      ln -s $out/test/lib/arweave $out/test/rel/arweave/lib/$ARWEAVE_LIB_PATH
      ln -s $out/test/lib/ar_sqlite3 $out/test/rel/arweave/lib/$AR_SQLITE_LIB_PATH
      ln -s $out/test/lib/graphql $out/test/rel/arweave/lib/$GRAPHQL_LIB_PATH
      ln -s $out/test/lib/jiffy $out/test/rel/arweave/lib/$JIFFY_LIB_PATH
    '';
  };
  arweaveProdProfile = mkArweaveApp {
    profile = "prod";
    releaseType = "release";
    installPhase = ''
      mkdir -p $out/bin; cp -rf ./_build/prod $out
      cp ${startScript.outPath} $out/bin/start-nix
      cp ${startScriptForeground.outPath} $out/bin/start-nix-foreground
      cp ${stopScript.outPath} $out/bin/stop-nix

      chmod +xw $out/bin/start-nix
      chmod +xw $out/bin/start-nix-foreground
      chmod +xw $out/bin/stop-nix

      sed -i -e "s|ROOT_DIR=|ROOT_DIR=$out|g" $out/bin/start-nix
      sed -i -e "s|PROFILE_DIR=|PROFILE_DIR=$out/prod/rel/arweave|g" $out/bin/start-nix
      sed -i -e "s|PATH=|PATH=$PATH:$out/erts/bin|g" $out/bin/start-nix

      sed -i -e "s|ROOT_DIR=|ROOT_DIR=$out|g" $out/bin/start-nix-foreground
      sed -i -e "s|PROFILE_DIR=|PROFILE_DIR=$out/prod/rel/arweave|g" $out/bin/start-nix-foreground
      sed -i -e "s|PATH=|PATH=$PATH:$out/erts/bin|g" $out/bin/start-nix-foreground

      sed -i -e "s|ROOT_DIR=|ROOT_DIR=$out|g" $out/bin/stop-nix
      sed -i -e "s|PROFILE_DIR=|PROFILE_DIR=$out/prod/rel/arweave|g" $out/bin/stop-nix
      sed -i -e "s|PATH=|PATH=$PATH:$out/erts/bin|g" $out/bin/stop-nix

      cp -r ./config $out
      ln -s $out/prod/rel/arweave/erts* $out/erts
    '';
  };
in
pkgs.symlinkJoin {
  name = "arweave";
  version = arweaveVersion;
  paths = [
    arweaveTestProfile
    arweaveProdProfile
  ];
}


