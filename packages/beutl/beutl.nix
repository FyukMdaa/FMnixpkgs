{ lib
, stdenv
, fetchurl
, makeWrapper
, autoPatchelfHook
, unzip
, gtk2
, gtk3
, glib
, libGL
, fontconfig
, freetype
, openssl
, icu
, zlib
, ffmpeg
, tesseract
, openexr
, krb5
, lttng-ust_2_12
, libunwind
, libuuid
, libxml2
, librsvg
, libtheora
, twolame
, libgcrypt
, libgpg-error
, libraw1394
, libusb1
, xorg
, libx11
, libxext
, libxrender
, libxrandr
, libxcursor
, libxi
, libxfixes
, libICE
, libSM
}:

stdenv.mkDerivation rec {
  pname = "beutl";
  version = "1.1.0";

  src = fetchurl {
    url = "https://github.com/b-editor/beutl/releases/download/v${version}/Beutl-linux-x64-standalone-${version}.zip";
    sha256 = "6aaf74a0f75a36abcf01365bd1b66953e519452da4f8187205c3ea6e4900e9e9";
  };

  nativeBuildInputs = [
    makeWrapper
    autoPatchelfHook
    unzip
  ];

  buildInputs = [
    gtk2
    gtk3
    glib
    libGL
    fontconfig
    freetype
    openssl
    icu
    zlib
    ffmpeg
    tesseract
    openexr
    krb5
    lttng-ust_2_12
    libunwind
    libuuid
    libxml2
    librsvg
    libtheora
    twolame
    libgcrypt
    libgpg-error
    libraw1394
    libusb1
    libx11
    libxext
    libxrender
    libxrandr
    libxcursor
    libxi
    libxfixes
    libICE
    libSM
  ];

  autoPatchelfIgnoreMissingDeps = [
    "libxml2.so.2"
    "libtheoraenc.so.1"
    "libtheoradec.so.1"
  ];

  unpackPhase = ''
    unzip $src -d unpacked
    sourceRoot="$PWD/unpacked"
  '';

  buildPhase = "true";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/beutl $out/bin
    cp -r $sourceRoot/. $out/opt/beutl/

    chmod +x $out/opt/beutl/Beutl
    chmod +x $out/opt/beutl/createdump

    makeWrapper $out/opt/beutl/Beutl $out/bin/beutl \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Cross-platform video editing (compositing) software";
    homepage = "https://beutl.beditor.net";
    license = licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "beutl";
  };
}
