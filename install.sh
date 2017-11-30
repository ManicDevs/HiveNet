#!/bin/bash
############

echo
echo "##################################"
echo "#                                #"
echo "# Hivenet Build System Installer #"
echo "#                                #"
echo "#       ~ HBSInstaller ~         #"
echo "#                                #"
echo "##################################"
echo

install_exit ()
{
	echo
	echo "##################################"
	echo "#                                #"
	echo "# Stopping installer for Hivenet #"
	echo "#                                #"
	echo "##################################"
	echo
	exit
}

[ $(uname) != "Linux" ] &&
{
	echo "Not on a Linux system. Exiting..."
	install_exit
}

[ $(id -u) != 0 ] &&
{
	echo "Not on a Root userid. Exiting..."
	install_exit
}

[ ! -e /proc ] &&
{
    echo "We're in a horrible jail as /proc doesn't exist. Exiting..."
    install_exit
}

CHATTR_OUTPUT=$(touch children; chattr +ia children &>output; cat output)
[[ $CHATTR_OUTPUT == *"Inappropriate ioctl"* ]] &&
{
    read -p "Warning: You're attempting to install on a weird/alien filesystem, This is bad. Exiting..."
    install_exit
}
chattr -ia children &>/dev/null
rm -f children output

mkdir -p logs/setup

install_prerequisites ()
{
    if [ -f /usr/bin/yum ]; then
        yum install -y -q -e 0 attr make gcc libgcc glibc-devel glibc-static &>/dev/null
    elif [ -f /usr/bin/apt-get ]; then
        apt-get --yes --force-yes update &>/dev/null
        apt-get --yes --force-yes install attr gcc-multilib build-essential &>/dev/null
    elif [ -f /usr/bin/pacman ]; then
        pacman -Syy &>/dev/null
        pacman -S --noconfirm attr base-devel &>/dev/null
    fi
}

build_hivenet ()
{
	make clean
	make clean-obj
	{ MAKE_OUTPUT=$(make all &>logs/setup/hivenet.build.log; cat logs/setup/hivenet.build.log 2>&1 1>&3-); } 3>&1
	[[ $MAKE_OUTPUT == *"Error"* ]] &&
	{
		read -p "Error: Hivenet was unable to build, check logs. Exiting..."
		install_exit
	}
}

echo
echo "##################################"
echo "#                                #"
echo "#  Continuing build for Hivenet  #"
echo "#                                #"
echo "##################################"
echo

echo "Installing prerequisite packages."
#install_prerequisites
echo "Prerequisite packages installed!"

echo "Building Hivenet environment."
build_hivenet
echo "Hivenet environment built."

echo
echo "##################################"
echo "#                                #"
echo "# Successfully Installed Hivenet #"
echo "#                                #"
echo "##################################"
echo
exit