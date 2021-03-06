{ stdenv, fetchFromGitHub, automake, autoconf, libtool, gettext
, utillinux, openisns, openssl, kmod, perl, systemd, pkgconf
}:

stdenv.mkDerivation rec {
  pname = "open-iscsi";
  version = "2.1.0";

  nativeBuildInputs = [ autoconf automake gettext libtool perl pkgconf ];
  buildInputs = [ kmod openisns.lib openssl systemd utillinux ];

  src = fetchFromGitHub {
    owner = "open-iscsi";
    repo = "open-iscsi";
    rev = version;
    sha256 = "0z7rnbfa48j3r4ij7335xgjfb835gnnp10v7q6lvwg7bq6v5xvih";
  };

  DESTDIR = "$(out)";

  NIX_LDFLAGS = "-lkmod -lsystemd";
  NIX_CFLAGS_COMPILE = "-DUSE_KMOD";

  preConfigure = ''
    sed -i 's|/usr|/|' Makefile
  '';

  postInstall = ''
    cp usr/iscsistart $out/sbin/
    $out/sbin/iscsistart -v
  '';

  postFixup = ''
    sed -i "s|/sbin/iscsiadm|$out/bin/iscsiadm|" $out/bin/iscsi_fw_login
  '';

  meta = with stdenv.lib; {
    description = "A high performance, transport independent, multi-platform implementation of RFC3720";
    license = licenses.gpl2;
    homepage = https://www.open-iscsi.com;
    platforms = platforms.linux;
    maintainers = with maintainers; [ cleverca22 zaninime ];
  };
}
