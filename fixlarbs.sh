#!/bin/bash

### OPTIONS AND VARIABLES ###

error() { echo "ERROR: $1" ; exit 1;}

welcomemsg() { \
	dialog --title "Welcome!" --msgbox "Welcome to Lowie's LARBS Fix Script!\\n\\nThis script changes some things in the LARBS install, e.g. making everything compatible with an AZERTY keyboard layout.\\n\\n-Lowie" 10 60
	}

homelocation() { \
	homeloc=$(dialog --inputbox "First, please enter the full path of your home directory." 10 60 3>&1 1>&2 2>&3 3>&1) || exit 1
	}

dwmlocation() { \
	dwmloc=$(dialog --inputbox "First, please enter the full path of your dwm rice." 10 60 3>&1 1>&2 2>&3 3>&1) || exit 1
	}

stlocation() { \
	stloc=$(dialog --inputbox "First, please enter the full path of your st rice." 10 60 3>&1 1>&2 2>&3 3>&1) || exit 1
	}

preinstallmsg() { \
	dialog --title "Let's get this party started!" --yes-label "Let's go!" --no-label "No, nevermind!" --yesno "The rest of the script will now be totally automated, so you can sit back and relax.\\n\\nIt will take some time, but when done, you can relax even more with your complete system.\\n\\nNow just press <Let's go!> and the system will begin the LARBS fixing!" 13 60 || { clear; exit 1; }
	}

finalize(){ \
	dialog --title "All done!" --msgbox "Congrats! Provided there were no hidden errors, the script completed successfully and all the programs and configuration files should be fixed." 12 80
	}

# Check if user is root on Arch distro. Install dialog.
pacman --noconfirm --needed -Sy dialog || error "Are you sure you're running this as the root user, are on an Arch-based distribution and have an internet connection?"

# Welcome user.
welcomemsg || error "User exited."

# Ask for home directory location.
homelocation || error "User exited."

# Ask for dwm location.
dwmlocation || error "User exited."

# Ask for st location.
stlocation || error "User exited."

# Last chance for user to back out before system fixing.
preinstallmsg || error "User exited."

### ACTUAL SCRIPT ###

# Go to dwm directory and modify workspace navigation keys.
cd $dwmloc
sed -i 's/XK_1/XK_ampersand/g' config.h
sed -i 's/XK_2/XK_eacute/g' config.h
sed -i 's/XK_3/XK_quotedbl/g' config.h
sed -i 's/XK_4/XK_apostrophe/g' config.h
sed -i 's/XK_5/XK_parenleft/g' config.h
sed -i 's/XK_6/XK_section/g' config.h
sed -i 's/XK_7/XK_egrave/g' config.h
sed -i 's/XK_8/XK_exclam/g' config.h
sed -i 's/XK_9/XK_ccedilla/g' config.h
sed -i 's/XK_0/XK_agrave/g' config.h

# Go to st directory and modify font size.
cd $stloc
sed -i 's/mono:pixelsize=12/mono:pixelsize=16/g' config.h

# Go to home directory and remove unnecessary things.
cd $homeloc
if [ -d "$homeloc/.git" ] ; then
	rm -rf "$homeloc/.git"
fi
if [ -f "$homeloc/.gitmodules" ] ; then
	rm "$homeloc/.gitmodules"
fi

# Change and add line in important system files.
sed -i 's/#export GNUPGHOME/export GNUPGHOME/g' $homeloc/.config/shell/profile
sed -i '/sh/a setxkbmap be' $homeloc/.local/bin/remaps

dialog --title "LARBS Installation" --infobox "One more thing to do, installing \`noto-fonts\` to have nice fonts!" 5 70

# Install font package.
pacman -Sy noto-fonts --noconfirm

# Last message! LARBS fixing complete!
finalize
clear
