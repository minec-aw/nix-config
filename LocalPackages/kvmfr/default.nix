{ stdenv, lib, fetchFromGitHub, kernel, kmod, looking-glass-client, ... }:

stdenv.mkDerivation rec {
  pname = "kvmfr-${version}-${kernel.version}";
  version = "B7-rc1";

  src = fetchFromGitHub {
    owner = "gnif";
    repo = "LookingGlass";
    rev = "d060e375ea47e4ca38894ea7bf02a85dbe29b1f8";
    sha256 = "sha256-DuCznF2b3kbt6OfoOUD3ijJ1im7anxj25/xcQnIVnWc=";
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