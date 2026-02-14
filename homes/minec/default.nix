{ pkgs, ... }:
{
	# Define a user account. Don't forget to set a password with ‘passwd’.
	hjem.users.minec.files = {
		# Cursors & icons & themes
		".blerc".source = ./blesh-config.sh;
	};
	users.users.minec = {
		isNormalUser = true;
		description = "Minec";
		extraGroups = [ "networkmanager" "wheel" "adbusers" "kvm" "dialout" "flashrom" ];
	};
}
