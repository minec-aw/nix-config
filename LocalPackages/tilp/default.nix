{ stdenv
, lib
, fetchFromGitHub
, pkg-config
, intltool
, libusb1
, glib
, gtk2
, libticonv
, libticalcs2
, libtifiles2
, libticables2
, autoreconfHook
}:

stdenv.mkDerivation { name = "tilp";
  src = fetchFromGitHub { 
    owner = "debrouxl"; 
    repo = "tilp_and_gfm"; 
    rev = "1.18"; 
   sha256 = "0k0llxvzw8yp2vj8baixv28a810rgxx7ma4n6fj269mkyl8k2ygx"; 
  }; 
  nativeBuildInputs = [ pkg-config intltool autoreconfHook ];
	buildInputs = [
		glib gtk2
		libusb1
		libticonv libticalcs2 libtifiles2 libticables2
	];
    sourceRoot = "source/tilp/trunk";
} 