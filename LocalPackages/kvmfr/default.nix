{ stdenv, lib, fetchFromGitHub, kernel, kmod, looking-glass-client, ... }:

stdenv.mkDerivation rec {
  pname = "kvmfr-${version}-${kernel.version}";
  version = "B7";

  src = fetchFromGitHub {
    owner = "gnif";
    repo = "LookingGlass";
    rev = lib.fakeHash;
    sha256 = lib.fakeHash;
    fetchSubmodules = true;
  };
  sourceRoot = "source/module";
  hardeningDisable = [ "pic" "format" ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = [
    "KVER=${kernel.modDirVersion}"
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  installPhase = ''
    install -D kvmfr.ko -t "$out/lib/modules/${kernel.modDirVersion}/kernel/drivers/misc/"
  '';
  #  substituteInPlace kvmfr.c --replace "vfree" "kvfree"
  meta = with lib; {
    description = "This kernel module implements a basic interface to the IVSHMEM device for LookingGlass";
    homepage = "https://github.com/gnif/LookingGlass";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ j-brn ];
    platforms = [ "x86_64-linux" ];
  };
}