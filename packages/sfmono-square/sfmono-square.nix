{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  unzip,
  python3,
  fontforge,
  inputs,
  ...
}:

let
  # fontforge に Python bindings を付与した環境を構築する。
  # nixpkgs には fontforge-fonttools という既製パッケージもあるが、
  # ここでは override で明示的に Python を渡してビルド時依存を整理する。
  pythonEnv = python3.withPackages (ps: [
    ps.fonttools
  ]);

  # fontforge を Python bindings 付きでビルドする
  fontforgeWithPython = fontforge.override {
    withPython = true;
    inherit python3;
  };

  # SF Mono (Apple)
  # ライセンス: Apple プラットフォーム向け開発用途のみ。商用・再配布不可。
  sfmono = fetchFromGitHub {
    owner = "supercomputra";
    repo = "SF-Mono-Font";
    rev = "1409ae79074d204c284507fef9e479248d5367c1";
    hash = "sha256-3wG3M4Qep7MYjktzX9u8d0iDWa17FSXYnObSoTG2I/o=";
  };

  # Migu 1M (IPA Font / M+ Font 派生、日本語グリフ)
  # TTF は git には含まれず release zip のみで提供される
  migu1mZip = fetchurl {
    url = "https://github.com/itouhiro/mixfont-mplus-ipa/releases/download/v2020.0307/migu-1m-20200307.zip";
    hash = "sha256-5IBtKX5Zp/nCNbAHmygZ9EuGINQ2WolVy2Esn/WAkyE=";
  };
in
stdenv.mkDerivation rec {
  pname = "sfmono-square";
  version = "3.3.1";

  src = fetchFromGitHub {
    owner = "delphinus";
    repo = "homebrew-sfmono-square";
    rev = "v${version}";
    hash = "sha256-aXRV11yDxqFtf+CgvIRlcEClFIgUjAX0813lDGTkkGQ=";
  };

  nativeBuildInputs = [
    fontforgeWithPython
    pythonEnv
    unzip
  ];

  buildPhase = ''
    # --- SF Mono OTF をビルドルートへ展開 ---
    cp ${sfmono}/SFMono-Regular.otf    SF-Mono-Regular.otf
    cp ${sfmono}/SFMono-RegularItalic.otf SF-Mono-RegularItalic.otf
    cp ${sfmono}/SFMono-Bold.otf       SF-Mono-Bold.otf
    cp ${sfmono}/SFMono-BoldItalic.otf SF-Mono-BoldItalic.otf

    # --- Migu 1M TTF を zip から展開 ---
    unzip -j ${migu1mZip} "*.ttf" -d .

    # --- Python パス設定 ---
    # fontforge の Python bindings は fontforge パッケージ内の site-packages にある
    FONTFORGE_PYVER=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
    FONTFORGE_PYLIB="${fontforgeWithPython}/lib/python$FONTFORGE_PYVER/site-packages"
    FONTTOOLS_PYLIB="${pythonEnv}/lib/python$FONTFORGE_PYVER/site-packages"
    export PYTHONPATH="$FONTFORGE_PYLIB:$FONTTOOLS_PYLIB:$PYTHONPATH"

    # --- ビルド出力ディレクトリ ---
    mkdir -p build

    # --- sfmono_square ビルドスクリプトを実行 ---
    # src/ ディレクトリにある Python モジュール群を参照する
    python3 -c "
import sys
sys.path.insert(0, 'src')
import build as b
ret = b.build('${version}')
sys.exit(ret)
"
  '';

  installPhase = ''
    install -Dm644 build/*.otf -t $out/share/fonts/opentype/sfmono-square
  '';

  meta = with lib; {
    description = "Square-sized SF Mono + Migu 1M (Japanese) + Nerd Fonts";
    longDescription = ''
      SFMono Square は SF Mono に日本語グリフ (Migu 1M) と
      Nerd Fonts アイコンを合成したプログラミング用フォントです。
      SF Mono は Apple のライセンス下にあり、個人利用のみ可能です。
    '';
    homepage = "https://github.com/delphinus/homebrew-sfmono-square";
    # SF Mono は Apple ライセンス: 個人・開発用途に限り使用可、再配布・商用不可
    license = licenses.unfreeRedistributable;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
