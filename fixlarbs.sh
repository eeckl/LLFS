#!/bin/sh
# Checking if LLFS is run as root.
if [[ $EUID -ne 0 ]]; then echo "This script must be run as root!"; exit 1; fi

# Install dialog.
pacman --noconfirm --needed -Sy dialog >/dev/null 2>&1 || { echo "Are you on Arch? Do you have an internet connection?"; exit 1; }

# Welcoming user.
dialog --title "LLFS" --msgbox "Welcome to Lowie's LARBS Fix Script!\\n\\nThis script changes some things in the LARBS install, e.g. making everything compatible with an AZERTY keyboard layout. For more information on what this script does, just look into it.\\n\\n-Lowie" 10 60

# Asking for directory locations.
homeloc=$(dialog --title "LLFS" --inputbox "Please enter the full path of your home directory. Only \`/home/...\` is allowed!" 10 60 3>&1 1>&2 2>&3 3>&1) || exit 1
dwmloc=$(dialog --title "LLFS" --inputbox "Please enter the full path of your \`dwm\` rice." 10 60 3>&1 1>&2 2>&3 3>&1) || exit 1
stloc=$(dialog --title "LLFS" --inputbox "Please enter the full path of your \`st\` rice." 10 60 3>&1 1>&2 2>&3 3>&1) || exit 1

# Last chance for user to back out before the actual script runs.
dialog --title "LLFS" --yes-label "Let's go!" --no-label "No, nevermind!" --yesno "The rest of the script will now be totally automated, so you can sit back and relax.\\n\\nNow just press <Let's go!> and the script will run!" 13 60 || { clear; exit 1; }

# A status message.
dialog --title "LLFS" --infobox "Busy manipulating files ..." 5 70

# Go to dwm directory and change some values.
cd $dwmloc
sed -i 's/monospace:size=10/monospace:size=11/g' config.h # Modify font size.
sed -i 's/XK_1/XK_ampersand/g ; s/XK_2/XK_eacute/g ; s/XK_3/XK_quotedbl/g ; s/XK_4/XK_apostrophe/g ; s/XK_5/XK_parenleft/g ; s/XK_6/XK_section/g ; s/XK_7/XK_egrave/g ; s/XK_8/XK_exclam/g ; s/XK_9/XK_ccedilla/g ; s/XK_0/XK_agrave/g' config.h # Modify workspace navigation.
sed -i 's/MODKEY,			XK_q/MODKEY|ShiftMask,		XK_c/g' config.h # Make kill keybind M-Shift-c.
sed -i 's/MODKEY,			XK_Return/MODKEY|ShiftMask,		XK_Return/g' config.h # Make terminal M-Shift-Return.
sed -i 's/MODKEY|ShiftMask,		XK_Return/MODKEY,			XK_twosuperior/g' config.h # Make scratchpad keybind M-twosuperior.
sed -i 's/{ MODKEY,			XK_apostrophe,	togglescratch,	{.ui = 1} },/\/* { MODKEY,			XK_apostrophe,	togglescratch,	{.ui = 1} }, *\//g' config.h # Disable calculator scratchpad keybind due to compatibility issues.
make install clean >/dev/null 2>&1

# Go to st directory and modify font size.
cd $stloc
sed -i 's/mono:pixelsize=12/mono:pixelsize=18/g' config.h
make install clean >/dev/null 2>&1

# Go to home directory and remove unnecessary things.
cd $homeloc
if [ -d "$homeloc/.git" ]; then rm -rf "$homeloc/.git"; fi
if [ -f "$homeloc/.gitmodules" ]; then rm "$homeloc/.gitmodules"; fi

# Change and add lines in important system files.
sed -i 's/#export GNUPGHOME/export GNUPGHOME/g' $homeloc/.config/shell/profile
sed -i '/sh/a setxkbmap be' $homeloc/.local/bin/remaps
sed -i 's/Music/mus/g' $homeloc/.config/mpd/mpd.conf
sed -i 's/Music/mus/g' $homeloc/.config/ncmpcpp/config

# Making some directories and changing the ownership to the user.
directories=(dox mus pix vids)
mkdir $directories
username=$(echo "$homeloc" | cut -d / -f 3)
chown "$username":wheel $directories
mkdir $homeloc/.config/mpd/playlists

# A status message.
dialog --title "LLFS" --infobox "Installing \`noto-fonts\` to have nice fonts ..." 5 70

# Install font package.
pacman -Sy noto-fonts --noconfirm --needed >/dev/null 2>&1

# Last message and clearing screen. LARBS fixing complete!
dialog --title "All done!" --msgbox "Congrats! Provided there were no hidden errors, the script completed successfully and all the programs and configuration files should be fixed." 12 80
clear
