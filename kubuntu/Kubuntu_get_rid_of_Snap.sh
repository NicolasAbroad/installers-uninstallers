#!/bin/bash

################################################################################
#                                                                              #
#                                                                              #
#         $$     $$                                                $$          #
#         $$     $$  $$$$$$$$$  $$         $$          $$$$$$$     $$          #
#         $$     $$  $$         $$         $$         $$     $$    $$          #
#         $$$$$$$$$  $$$$$$$$   $$         $$         $$     $$    $$          #
#         $$     $$  $$         $$         $$         $$     $$    $$          #
#         $$     $$  $$         $$         $$         $$     $$                #
#         $$     $$  $$$$$$$$$  $$$$$$$$$  $$$$$$$$$   $$$$$$$     $$          #
#                                                                              #
#                                                                              #
# This is a little helper script for Kubuntu™ users who want to get rid of     #
# and block Snap entirely (like Linux Mint and TUXEDO OS do), including the    #
# Firefox Snap in 22.04 LTS & later and e.g. the Thunderbird and Firmware      #
# Updater Snaps in 24.04 LTS & later.                                          #
# It has been tested many times with Kubuntu™ 20.04 LTS up to 25.04.           #
#                                                                              #
# -> IMPORTANT:                                                                #
#    This script is best run after a fresh installation of Kubuntu™ but has    #
#    also been written to be run directly after a release-upgrade to the next  #
#    main Kubuntu™ version (e.g. from 24.10 to 25.04).                         #
#    It should also work with a Kubuntu™ installation that has been used for a #
#    while - depending on your own system modifications - but BE AWARE THAT    #
#    ALL PROGRAMS YOU ADDITIONALLY INSTALLED AS SNAPS WILL BE REMOVED TOO!     #
#    It has been designed to be run in combination with the                    #
#    "reinstall_Snap_for_release-upgrade" script.                              #
#                                                                              #
# -> A full upgrade of the system (either with Discover or in Konsole with     #
#    "sudo apt update && sudo apt full-upgrade") AND a reboot is strongly      #
#    recommended prior to running this script!                                 #
#                                                                              #
# You will be asked twice for confirmation before the removal of Snaps and     #
# snapd is started and/or APT pinning to block future installation of Snap is  #
# applied - and if you answer "n" or "N" no changes at all are made to your    #
# system.                                                                      #
#                                                                              #
# For some more information about what is done in detail see the comments      #
# within this script.                                                          #
#                                                                              #
# My scripts are in no way associated with Canonical™, Ubuntu™ or Kubuntu™.    #
# This script comes with ABSOLUTELY NO WARRANTY OF ANY KIND.                   #
# It may be used, shared, copied and modified freely.                          #
#                                                                              #
# You can download my scripts from here: https://gitlab.com/scripts94          #
#                                                                              #
# I hope you find the script useful! Yours respectfully, Schwarzer Kater       #
#                                                                              #
################################################################################

versionnr="2.1.5"

########
## During this session let's make sure no "exotic" or interfering aliases can be
## used in this script
########
shopt -u expand_aliases

########
## Display purpose of this script
########
clear
echo -e "########"
echo -e "## This is a little helper script for Kubuntu™ users who want to get rid of"
echo -e "## and block Snap entirely (like Linux Mint and TUXEDO OS do), including the"
echo -e "## Firefox Snap in 22.04 LTS & later and e.g. the Thunderbird and Firmware"
echo -e "## Updater Snaps in 24.04 LTS & later."
echo -e "## It has been tested many times with Kubuntu™ 20.04 LTS up to 25.04."
echo -e "##"
echo -e "## -> IMPORTANT:"
echo -e "##    This script is best run after a fresh installation of Kubuntu™ but has"
echo -e "##    also been written to be run directly after a release-upgrade to the next"
echo -e "##    main Kubuntu™ version (e.g. from 24.10 to 25.04)."
echo -e "##    It should also work with a Kubuntu™ installation that has been used for a"
echo -e "##    while - depending on your own system modifications - but BE AWARE THAT"
echo -e "##    ALL PROGRAMS YOU ADDITIONALLY INSTALLED AS SNAPS WILL BE REMOVED TOO!"
echo -e "##    It has been designed to be run in combination with the"
echo -e "##    \"reinstall_Snap_for_release-upgrade\" script."
echo -e "## -> A full upgrade of the system (either with Discover or in Konsole with"
echo -e "##    \"sudo apt update && sudo apt full-upgrade\") AND a reboot is strongly"
echo -e "##    recommended prior to running this script!"
echo -e "##"
echo -e "## You will be asked twice for confirmation before the removal of Snaps and"
echo -e "## snapd is started and/or APT pinning to block future installation of Snap is"
echo -e "## applied - and if you answer \"n\" or \"N\" no changes at all are made to your"
echo -e "## system."
echo -e "##"
echo -e "## For some more information about what is done in detail see the comments"
echo -e "## within the script itself."
echo -e "##"
echo -e "## This script comes with ABSOLUTELY NO WARRANTY OF ANY KIND."
echo -e "## It may be used, shared, copied and modified freely."
echo -e "##"
echo -e "## I hope you find the script useful! Yours respectfully, Schwarzer Kater"
echo -e "########\n"
read -p "Press [Enter] to continue, press [Ctrl] [c] to exit. "

########
## Make sure the computer has established an internet connection with IP and DNS
## before running the rest of the script
########
if ! ping -c1 -W1 ubuntu.com &> /dev/null && ! ping -c1 -W1 kde.org &> /dev/null && ! ping -c1 -W1 kernel.org &> /dev/null
then
    echo -e "\n###############################################################################\n## -> AN ERROR OCCURED! <-                                                   ##\n## An Internet connection is required to run this script.                    ##\n## -> Please connect your Kubuntu™ to the Internet and run the script again! ##\n###############################################################################\n"
    exit 1
fi

########
## If applicable, do the following:
## - update Snaps first
## - remove the Firefox Snap (and Chromium, Thunderbird, Element, Krita and
## Firmware Updater Snaps), snapd and additionally installed Snaps entirely
## - remove remaining Snap support tools/libraries
## - remove remaining Snap directories
## - remove broken symbolic systemd links
## - block future installation of Snap by APT pinning (like Linux Mint and
## TUXEDO OS do)
## - remove the Mozilla Team PPA placeholder files (if they have been installed
## by a previous version of the scripts)
########
snappin=0
rmffsnap=0
rmtbsnap=0
rmkrsnap=0
rmfusnap=0
rmsnap=0
blocksnap=0

# Test if the operating system is Kubuntu 20.04 or later / Ubuntu 20.04 or
# later-based with KDE Plasma
if ! cat /etc/os-release | grep -Ei "(^|\s)VERSION=(|\s|\"|\s\")(20.04|20.10|21.04|21.10|22.04|22.10|23.04|23.10|24.04|24.10|25.04)" &> /dev/null || ! echo "$XDG_CURRENT_DESKTOP" | grep -i KDE &> /dev/null
then
    echo -e "\n######################################################################\n## This script is meant to be used with Kubuntu™ 20.04 LTS or later ##\n## -> PROCEED AT YOUR OWN RISK!                                     ##\n######################################################################"
fi

# Test if there already is relevant APT pinning in /etc/apt/preferences.d
for snappincounter in /etc/apt/preferences.d/* ; do if cat "${snappincounter}" 2> /dev/null | grep -Ei "(^|\s)Package:(|\s)snapd($|\s)|(^|\s)Package:(|\s)snapd\*($|\s)" &> /dev/null && cat "${snappincounter}" 2> /dev/null | grep -Ei "(^|\s)Pin-Priority:(|\s)-" &> /dev/null ; then snappin=1 ; fi ; done
# Only continue if snapd is installed or future installation of Snaps has not
# been blocked
if command -v snap &> /dev/null || [[ ${snappin} = 0 ]]
then
    echo -e "\n########\n## Do you want to REMOVE and BLOCK Snap entirely from Kubuntu™?"
    if command -v snap &> /dev/null && snap list 2> /dev/null | grep -i "^core" &> /dev/null && snap list firefox &> /dev/null
    then
        # Warn about installed Snaps including the Firefox Snap that are to be
        # removed
        if ! snap list thunderbird &> /dev/null && ! snap list firmware-updater &> /dev/null
        then
            echo -e "## (Including the Firefox Snap and all additional Snaps you may have installed.)\n## The following Snaps WILL BE REMOVED (\"bare\", \"core…\", etc. are no actual\n## programs you have installed but just Snap \"support stuff\") :\n########\n" && snap list && echo
        # Warn about installed Snaps including the Firefox and Thunderbird Snaps
        # that are to be removed
        elif snap list thunderbird &> /dev/null && ! snap list firmware-updater &> /dev/null
        then
            echo -e "## (Including the Firefox and Thunderbird Snaps and all additional Snaps you may\n## have installed.)\n## The following Snaps WILL BE REMOVED (\"bare\", \"core…\", etc. are no actual\n## programs you have installed but just Snap \"support stuff\") :\n########\n" && snap list && echo
        # Warn about installed Snaps including the Firefox and Firmware Updater
        # Snaps that are to be removed
        elif ! snap list thunderbird &> /dev/null && snap list firmware-updater &> /dev/null
        then
            echo -e "## (Including the Firefox and Firmware Updater Snaps and all additional Snaps\n## you may have installed.)\n## The following Snaps WILL BE REMOVED (\"bare\", \"core…\", etc. are no actual\n## programs you have installed but just Snap \"support stuff\") :\n########\n" && snap list && echo
        # Warn about installed Snaps including the Firefox, Thunderbird and
        # Firmware Updater Snaps that are to be removed
        elif snap list thunderbird &> /dev/null && snap list firmware-updater &> /dev/null
        then
            echo -e "## (Including the Firefox, Thunderbird and Firmware Updater Snaps and all\n## additional Snaps you may have installed.)\n## The following Snaps WILL BE REMOVED (\"bare\", \"core…\", etc. are no actual\n## programs you have installed but just Snap \"support stuff\") :\n########\n" && snap list && echo
        fi
    elif command -v snap &> /dev/null && snap list 2> /dev/null | grep -i "^core" &> /dev/null && ! snap list firefox &> /dev/null
    then
        # Warn about installed Snaps including the Thunderbird and Firmware
        # Updater Snaps that are to be removed
        if snap list thunderbird &> /dev/null && snap list firmware-updater &> /dev/null
        then
            echo -e "## (Including the Thunderbird and Firmware Updater Snaps and all additional\n## Snaps you may have installed.)\n## The following Snaps WILL BE REMOVED (\"bare\", \"core…\", etc. are no actual\n## programs you have installed but just Snap \"support stuff\") :\n########\n" && snap list && echo
        # Warn about installed Snaps including the Thunderbird Snap that are to
        # be removed
        elif snap list thunderbird &> /dev/null && ! snap list firmware-updater &> /dev/null
        then
            echo -e "## (Including the Thunderbird Snap and all additional Snaps you may have\n## installed.)\n## The following Snaps WILL BE REMOVED (\"bare\", \"core…\", etc. are no actual\n## programs you have installed but just Snap \"support stuff\") :\n########\n" && snap list && echo
        # Warn about installed Snaps including the Firmware Updater Snap that
        # are to be removed
        elif ! snap list thunderbird &> /dev/null && snap list firmware-updater &> /dev/null
        then
            echo -e "## (Including the Firmware Updater Snap and all additional Snaps you may have\n## installed.)\n## The following Snaps WILL BE REMOVED (\"bare\", \"core…\", etc. are no actual\n## programs you have installed but just Snap \"support stuff\") :\n########\n" && snap list && echo
        # Warn about installed Snaps that are to be removed
        elif ! snap list thunderbird &> /dev/null && ! snap list firmware-updater &> /dev/null
        then
            echo -e "## (Including all additional Snaps you may have installed.)\n## The following Snaps WILL BE REMOVED (\"bare\", \"core…\", etc. are no actual\n## programs you have installed but just Snap \"support stuff\") :\n########\n" && snap list && echo
        fi
    # Tell that snapd is to be removed
    elif command -v snap &> /dev/null && ! snap list 2> /dev/null | grep -i "^core" &> /dev/null
    then
        echo -e "## No Snaps seem to be installed, but snapd WILL BE REMOVED.\n########"
    else
        echo -e "########"
    fi

    # Give option to cancel
    while true
    do
        read -p "[y/n] " answer
        if [[ "${answer}" = [Yy] ]]
        then
            # Only continue if snapd is installed
            if command -v snap &> /dev/null
            then
                # Ask for confirmation
                echo -e "\n########\n## Are you sure you want to GET RID OF and BLOCK Snap?\n########"
                while true
                do
                    read -p "[y/n] " confirm
                    if [[ "${confirm}" = [Yy] ]]
                    then
                        # Update Snaps first, so running the removal will not
                        # fail
                        echo -e "\n########\n## -> Updating Snaps first as a prerequisite for removal …\n########\n" && sudo snap refresh && sudo systemctl daemon-reload

                        # Uninstall the Firefox Snap first, if it is installed
                        if snap list firefox &> /dev/null ; then echo -e "\n########\n## -> Removing the Firefox Snap …\n########\n" && sudo snap remove --purge firefox && rmffsnap=1 ; fi

                        # Uninstall the Chromium Snap first, if it is installed
                        if snap list chromium &> /dev/null ; then echo -e "\n########\n## -> Removing the Chromium Snap …\n########\n" && sudo snap remove --purge chromium ; fi

                        # Uninstall the Thunderbird Snap first, if it is
                        # installed
                        if snap list thunderbird &> /dev/null ; then echo -e "\n########\n## -> Removing the Thunderbird Snap …\n########\n" && sudo snap remove --purge thunderbird && rmtbsnap=1 ; fi

                        # Uninstall the Element Snap first, if it is installed
                        if snap list element-desktop &> /dev/null ; then echo -e "\n########\n## -> Removing the Element Snap …\n########\n" && sudo snap remove --purge element-desktop ; fi

                        # Uninstall the Krita Snap first, if it is installed
                        if snap list krita &> /dev/null
                        then
                            echo -e "\n########\n## -> Removing the Krita Snap …\n########\n" && sudo snap remove --purge krita
                            if ! test -d "/usr/share/krita" || ! test -x "/usr/bin/krita"
                            then
                                rmkrsnap=1
                            fi
                        fi

                        # Uninstall the Firmware Updater Snap first, if it is
                        # installed
                        if snap list firmware-updater &> /dev/null ; then echo -e "\n########\n## -> Removing the Firmware Updater Snap …\n########\n" && sudo snap remove --purge firmware-updater && rmfusnap=1 ; fi

                        # Disable Snap daemon and remove snapd and remaining
                        # Snaps entirely
                        echo -e "\n########\n## -> Removing snapd …\n########\n"
                        sudo systemctl disable --now snapd.service
                        sudo apt-get purge -y snapd

                        # Uninstall Snap support tools, if they are still
                        # installed
                        if dpkg -l squashfs-tools 2> /dev/null | grep "^ii" &> /dev/null ; then echo -e "\n########\n## -> Removing Snap support: squashfs-tools …\n########\n" && sudo apt-get purge -y squashfs-tools ; fi

                        # Uninstall Discover's support for Snap, if it is still
                        # installed
                        if dpkg -l plasma-discover-backend-snap 2> /dev/null | grep "^ii" &> /dev/null ; then echo -e "\n########\n## -> Removing Discover's support for Snap …\n########\n" && sudo apt-get purge -y plasma-discover-backend-snap ; fi
                        if dpkg -l plasma-discover-snap-backend 2> /dev/null | grep "^ii" &> /dev/null ; then echo -e "\n########\n## -> Removing Discover's support for Snap …\n########\n" && sudo apt-get purge -y plasma-discover-snap-backend ; fi

                        # Uninstall Snap support libraries, if they are still
                        # installed
                        if dpkg -l libsnapd-qt1 2> /dev/null | grep "^ii" &> /dev/null ; then echo -e "\n########\n## -> Removing Snap support: libsnapd-qt1 …\n########\n" && sudo apt-get purge -y libsnapd-qt1 ; fi
                        if dpkg -l libsnapd-qt-2-1 2> /dev/null | grep "^ii" &> /dev/null ; then echo -e "\n########\n##  Removing Snap support: libsnapd-qt-2-1 …\n########\n" && sudo apt-get purge -y libsnapd-qt-2-1 ; fi

                        # Remove all possible and impossible Snap directories
                        # that may exist
                        echo -e "\n########\n## -> Removing Snap directories …\n########"
                        # Remove snap directory from $HOME, if it exists
                        if test -d "$HOME/snap" ; then sudo rm -rf /home/*/snap ; fi
                        # Remove snap directory from /root, if it exists
                        if sudo test -d "/root/snap" ; then sudo rm -rf /root/snap ; fi
                        # Remove snap directory from /var, if it exists
                        if test -d "/var/snap" ; then sudo rm -rf /var/snap ; fi
                        # Remove snapd directory from /var/cache, if it exists
                        if test -d "/var/cache/snapd" ; then sudo rm -rf /var/cache/snapd ; fi
                        # Additionally remove snap directory from /, if it
                        # exists
                        if test -d "/snap" ; then sudo rm -rf /snap ; fi
                        # Additionally remove snapd directory from /var/lib, if
                        # it exists
                        if test -d "/var/lib/snapd" ; then sudo rm -rf /var/lib/snapd ; fi
                        # Additionally remove snapd directory from /usr/lib, if
                        # it exists
                        if test -d "/usr/lib/snapd" ; then sudo rm -rf /usr/lib/snapd ; fi

                        # Remove broken symbolic links from
                        # /etc/systemd/system/default.target.wants, if they
                        # exist
                        for bsymlink in /etc/systemd/system/default.target.wants/snap-* ; do test -L "${bsymlink}" && sudo rm -f "${bsymlink}" && echo -e "\n########\n## -> Removing broken symbolic link :\n##    ${bsymlink} …\n########" ; done
                        for bsymlinkd in /etc/systemd/system/default.target.wants/snapd.* ; do test -L "${bsymlinkd}" && sudo rm -f "${bsymlinkd}" && echo -e "\n########\n## -> Removing broken symbolic link :\n##    ${bsymlinkd} …\n########" ; done

                        # Remove broken symbolic links from
                        # /etc/systemd/system/multi-user.target.wants, if they
                        # exist
                        for bsymlinksnap in /etc/systemd/system/multi-user.target.wants/snap-* ; do test -L "${bsymlinksnap}" && sudo rm -f "${bsymlinksnap}" && echo -e "\n########\n## -> Removing broken symbolic link :\n##    ${bsymlinksnap} …\n########" ; done
                        for bsymlinksnapd in /etc/systemd/system/multi-user.target.wants/snapd.* ; do test -L "${bsymlinksnapd}" && sudo rm -f "${bsymlinksnapd}" && echo -e "\n########\n## -> Removing broken symbolic link :\n##    ${bsymlinksnapd} …\n########" ; done

                        # Remove broken symbolic links from
                        # /var/lib/sddm/.config/systemd/user/timers.target.wants
                        # and the user's home, if they exist
                        sudo bash -c 'for bsymlinktimer1 in /var/lib/sddm/.config/systemd/user/timers.target.wants/snap.* ; do test -L "${bsymlinktimer1}" && rm -f "${bsymlinktimer1}" && echo -e "\n########\n## -> Removing broken symbolic link :\n##    ${bsymlinktimer1} …\n########" ; done'
                        for bsymlinktimer2 in "$HOME"/.config/systemd/user/timers.target.wants/snap.* ; do test -L "${bsymlinktimer2}" && rm -f "${bsymlinktimer2}" && echo -e "\n########\n## -> Removing broken symbolic link :\n##    ${bsymlinktimer2} …\n########" ; done

                        # Prevent Snap from being installed again by APT pinning
                        #  in /etc/apt/preferences.d like Linux Mint and TUXEDO
                        #  OS do
                        echo -e "\n########\n## -> Writing the following to /etc/apt/preferences.d/no_snapd.pref :\n########\n"
                        echo -e "# To prevent repository packages from triggering the installation of Snap,\n# this file forbids snapd from being installed by APT.\n\nPackage: snapd\nPin: release a=*\nPin-Priority: -10" | sudo tee /etc/apt/preferences.d/no_snapd.pref

                        # Test if the "Mozilla Team PPA" placeholder file from a
                        # previous version of the scripts is in $HOME and remove
                        # it
                        if test -f "$HOME/.mtppa-placeholder" ; then rm -f "$HOME/.mtppa-placeholder" ; fi

                        # Test if the "prefer Firefox from the Mozilla Team PPA
                        # APT pinning" placeholder file from a previous version
                        # of the scripts is in $HOME and remove it
                        if test -f "$HOME/.mtppa-ffpin-placeholder" ; then  rm -f "$HOME/.mtppa-ffpin-placeholder" ; fi

                        # Test if the "Firefox from the Mozilla Team PPA"
                        # placeholder file from a previous version of the
                        # scripts is in $HOME and remove it
                        if test -f "$HOME/.mtff-placeholder" ; then rm -f "$HOME/.mtff-placeholder" ; fi

                        rmsnap=1
                        break 2
                    elif [[ "${confirm}" = [Nn] ]]
                    then
                        echo -e "\n########\n## You canceled the removal of Snap -> not changing anything …\n########"
                        break 2
                    fi
                done
            else
                # Give option to block future installation of Snaps
                echo -e "\n########\n## Neither snapd nor Snaps seem to be installed -> not removing anything …"
                echo -e "## Do you want to simply BLOCK the future installation of snapd and Snaps?\n########"
                # Give option to cancel
                while true
                do
                    read -p "[y/n] " askblock
                    if [[ "${askblock}" = [Yy] ]]
                    then
                        # Test if there already is relevant APT pinning in
                        # /etc/apt/preferences.d
                        for snappincount in /etc/apt/preferences.d/* ; do if cat "${snappincount}" 2> /dev/null | grep -Ei "(^|\s)Package:(|\s)snapd($|\s)|(^|\s)Package:(|\s)snapd\*($|\s)" &> /dev/null && cat "${snappincount}" 2> /dev/null | grep -Ei "(^|\s)Pin-Priority:(|\s)-" &> /dev/null ; then snappin=2 ; fi ; done
                        if [[ ${snappin} = 2 ]]
                        then
                            echo -e "\n########\n## The future installation of Snap seems to have already been blocked by APT\n## pinning -> not changing anything …\n########"
                            break 2
                        else
                            # Prevent Snap from being installed again by APT
                            # pinning in /etc/apt/preferences.d like Linux Mint
                            # and TUXEDO OS do
                            echo -e "\n########\n## -> Writing the following to /etc/apt/preferences.d/no_snapd.pref :\n########\n"
                            echo -e "\n# To prevent repository packages from triggering the installation of Snap,\n# this file forbids snapd from being installed by APT.\n\nPackage: snapd\nPin: release a=*\nPin-Priority: -10" | sudo tee /etc/apt/preferences.d/no_snapd.pref
                            blocksnap=1
                            break 2
                        fi
                    elif [[ "${askblock}" = [Nn] ]]
                    then
                        echo -e "\n########\n## You canceled to block the future installation of Snap\n## -> not changing anything …\n########"
                        break 2
                    fi
                done
            fi
        elif [[ "${answer}" = [Nn] ]]
        then
            echo -e "\n########\n## You canceled the removal of Snap -> not changing anything …\n########"
            break
        fi
    done
elif ! command -v snap &> /dev/null && [[ ${snappin} = 1 ]]
then
    echo -e "\n########\n## Neither snapd nor Snaps seem to be installed and the future installation of\n## snapd and Snaps seems to have already been blocked by APT pinning\n## -> not changing anything …\n########"
fi

########
## Report what has been done
########
summary_first="\n########\n## -> SUMMARY:"
summary_nochanges="## The script has made no changes at all to your system!"
summary_ff="## -> You can install the \"traditional\" Firefox from Mozilla.org with the\n##    \"install_traditional_Firefox\" script instead."
summary_tb="## -> You can install the \"traditional\" Thunderbird from Mozilla.org with the\n##    \"install_traditional_Thunderbird\" script instead."
summary_kr="## -> Instead of the Krita Snap you can install the \"traditional\" Krita with\n##    Discover or in Konsole with \"sudo apt install krita\"."
summary_reboot="## -> It is strongly recommended that you reboot your computer now!"
summary_last="## Have a nice day and enjoy a snap-free Kubuntu™.\n########\n"
savesummary=0

if [[ ${rmsnap} = 1 ]] && [[ ${rmffsnap} = 1 ]]
then
    # Tell that Snap including the Firefox Snap (and Thunderbird and Firmware
    # Updater Snaps) has been removed and recommend system reboot
    echo -e "${summary_first}"
    if [[ ${rmtbsnap} = 0 ]] && [[ ${rmfusnap} = 0 ]]
    then
        echo -e "## Snap including the Firefox Snap has been removed from your system and the\n## future installation of Snap has been blocked by APT pinning in\n## /etc/apt/preferences.d - the file is named \"no_snapd.pref\"."
        if ! test -x "/opt/firefox/firefox" ; then echo -e "${summary_ff}" ; fi
        if [[ ${rmkrsnap} = 1 ]] ; then echo -e "${summary_kr}" ; fi
    elif [[ ${rmtbsnap} = 1 ]] && [[ ${rmfusnap} = 0 ]]
    then
        echo -e "## Snap including the Firefox and Thunderbird Snaps has been removed from your\n## system and the future installation of Snap has been blocked by APT pinning in\n## /etc/apt/preferences.d - the file is named \"no_snapd.pref\"."
        if ! test -x "/opt/firefox/firefox" ; then echo -e "${summary_ff}" ; fi
        if ! test -x "/opt/thunderbird/thunderbird" ; then echo -e "${summary_tb}" ; fi
        if [[ ${rmkrsnap} = 1 ]] ; then echo -e "${summary_kr}" ; fi
    elif [[ ${rmtbsnap} = 0 ]] && [[ ${rmfusnap} = 1 ]]
    then
        echo -e "## Snap including the Firefox and Firmware Updater Snaps has been removed from\n## your system and the future installation of Snap has been blocked by APT\n## pinning in /etc/apt/preferences.d - the file is named \"no_snapd.pref\"."
        if ! test -x "/opt/firefox/firefox" ; then echo -e "${summary_ff}" ; fi
        if [[ ${rmkrsnap} = 1 ]] ; then echo -e "${summary_kr}" ; fi
    elif [[ ${rmtbsnap} = 1 ]] && [[ ${rmfusnap} = 1 ]]
    then
        echo -e "## Snap including the Firefox, Thunderbird and Firmware Updater Snaps has been\n## removed from your system and the future installation of Snap has been blocked\n## by APT pinning in /etc/apt/preferences.d - the file is named \"no_snapd.pref\"."
        if ! test -x "/opt/firefox/firefox" ; then echo -e "${summary_ff}" ; fi
        if ! test -x "/opt/thunderbird/thunderbird" ; then echo -e "${summary_tb}" ; fi
        if [[ ${rmkrsnap} = 1 ]] ; then echo -e "${summary_kr}" ; fi
    fi
    echo -e "## -> Be sure to remove any relevant APT pinning and reinstall Snap BEFORE a"
    echo -e "##    release-upgrade to the next main Kubuntu™ version (e.g. from 24.10 to"
    echo -e "##    25.04)!"
    echo -e "##    You can do both with the \"reinstall_Snap_for_release-upgrade\" script."
    echo -e "${summary_reboot}"
    echo -e "${summary_last}"
    savesummary=1
elif [[ ${rmsnap} = 1 ]] && [[ ${rmffsnap} = 0 ]]
then
    # Tell that Snap (including the Thunderbird and Firmware Updater Snaps) has
    # been removed and recommend system reboot
    echo -e "${summary_first}"
    if [[ ${rmtbsnap} = 1 ]] && [[ ${rmfusnap} = 1 ]]
    then
        echo -e "## Snap including the Thunderbird and Firmware Updater Snaps has been removed\n## from your system and the future installation of Snap has been blocked by APT\n## pinning in /etc/apt/preferences.d - the file is named \"no_snapd.pref\"."
        if ! test -x "/opt/thunderbird/thunderbird" ; then echo -e "${summary_tb}" ; fi
        if [[ ${rmkrsnap} = 1 ]] ; then echo -e "${summary_kr}" ; fi
    elif [[ ${rmtbsnap} = 1 ]] && [[ ${rmfusnap} = 0 ]]
    then
        echo -e "## Snap including the Thunderbird Snap has been removed from your system and the\n## future installation of Snap has been blocked by APT pinning in\n## /etc/apt/preferences.d - the file is named \"no_snapd.pref\"."
        if ! test -x "/opt/thunderbird/thunderbird" ; then echo -e "${summary_tb}" ; fi
        if [[ ${rmkrsnap} = 1 ]] ; then echo -e "${summary_kr}" ; fi
    elif [[ ${rmtbsnap} = 0 ]] && [[ ${rmfusnap} = 1 ]]
    then
        echo -e "## Snap including the Firmware Updater Snap has been removed from your system\n## and the future installation of Snap has been blocked by APT pinning in\n## /etc/apt/preferences.d - the file is named \"no_snapd.pref\"."
        if [[ ${rmkrsnap} = 1 ]] ; then echo -e "${summary_kr}" ; fi
    elif [[ ${rmtbsnap} = 0 ]] && [[ ${rmfusnap} = 0 ]]
    then
        echo -e "## Snap has been removed from your system and the future installation of Snap\n## has been blocked by APT pinning in /etc/apt/preferences.d - the file is named\n## \"no_snapd.pref\"."
        if [[ ${rmkrsnap} = 1 ]] ; then echo -e "${summary_kr}" ; fi
    fi
    echo -e "## -> Be sure to remove any relevant APT pinning and reinstall Snap BEFORE a"
    echo -e "##    release-upgrade to the next main Kubuntu™ version (e.g. from 24.10 to"
    echo -e "##    25.04)!"
    echo -e "##    You can do both with the \"reinstall_Snap_for_release-upgrade\" script."
    echo -e "${summary_reboot}"
    echo -e "${summary_last}"
    savesummary=1
elif ! command -v snap &> /dev/null && [[ ${blocksnap} = 1 ]]
then
    # Tell that future installation of Snap has been blocked
    echo -e "${summary_first}"
    echo -e "## The future installation of Snap has been blocked by APT pinning in\n## /etc/apt/preferences.d - the file is named \"no_snapd.pref\"."
    echo -e "## -> Be sure to remove any relevant APT pinning and reinstall Snap BEFORE a"
    echo -e "##    release-upgrade to the next main Kubuntu™ version (e.g. from 24.10 to"
    echo -e "##    25.04)!"
    echo -e "##    You can do both with the \"reinstall_Snap_for_release-upgrade\" script."
    echo -e "${summary_last}"
    savesummary=1
elif ! command -v snap &> /dev/null && [[ ${blocksnap} = 0 ]]
then
    # Tell that nothing has changed
    echo -e "${summary_first}"
    echo -e "${summary_nochanges}"
    echo -e "## -> Be sure to remove any relevant APT pinning and reinstall Snap BEFORE a"
    echo -e "##    release-upgrade to the next main Kubuntu™ version (e.g. from 24.10 to"
    echo -e "##    25.04)!"
    echo -e "##    You can do both with the \"reinstall_Snap_for_release-upgrade\" script."
    echo -e "${summary_last}"
else
    # Tell that nothing has changed
    echo -e "${summary_first}"
    echo -e "${summary_nochanges}"
    if [[ ${snappin} = 0 ]] ; then echo -e "## Have a nice day and enjoy Kubuntu™.\n########\n" ; fi
    if [[ ${snappin} = 1 ]] ; then echo -e "${summary_last}" ; fi
fi

########
## Give option to save the summary, if the script has changed anything
########
appendix="$(date +"%Y-%m-%d_%H:%M")"

if [[ ${savesummary} = 1 ]]
then
    echo -e "########\n## -> Do you want to save this summary for future reference?\n########"
    while true
    do
        read -p "[y/n] " wantsave
        if [[ "${wantsave}" = [Yy] ]] && [[ ${rmsnap} = 1 ]] && [[ ${rmffsnap} = 1 ]] && [[ ${blocksnap} = 0 ]]
        then
            # Save to text file that Snap including the Firefox Snap (and
            # Thunderbird and Firmware Updater Snaps) has been removed and
            # system reboot is recommended
            echo -e "${summary_first}" > "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            if [[ ${rmtbsnap} = 0 ]] && [[ ${rmfusnap} = 0 ]]
            then
                echo -e "## Snap including the Firefox Snap has been removed from your system and the\n## future installation of Snap has been blocked by APT pinning in\n## /etc/apt/preferences.d - the file is named \"no_snapd.pref\"." >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
                if ! test -x "/opt/firefox/firefox" ; then echo -e "${summary_ff}" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt" ; fi
                if [[ ${rmkrsnap} = 1 ]] ; then echo -e "${summary_kr}" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt" ; fi
            elif [[ ${rmtbsnap} = 1 ]] && [[ ${rmfusnap} = 0 ]]
            then
                echo -e "## Snap including the Firefox and Thunderbird Snaps has been removed from your\n## system and the future installation of Snap has been blocked by APT pinning in\n## /etc/apt/preferences.d - the file is named \"no_snapd.pref\"." >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
                if ! test -x "/opt/firefox/firefox" ; then echo -e "${summary_ff}" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt" ; fi
                if ! test -x "/opt/thunderbird/thunderbird" ; then echo -e "${summary_tb}" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt" ; fi
                if [[ ${rmkrsnap} = 1 ]] ; then echo -e "${summary_kr}" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt" ; fi
            elif [[ ${rmtbsnap} = 0 ]] && [[ ${rmfusnap} = 1 ]]
            then
                echo -e "## Snap including the Firefox and Firmware Updater Snaps has been removed from\n## your system and the future installation of Snap has been blocked by APT\n## pinning in /etc/apt/preferences.d - the file is named \"no_snapd.pref\"." >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
                if ! test -x "/opt/firefox/firefox" ; then echo -e "${summary_ff}" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt" ; fi
                if [[ ${rmkrsnap} = 1 ]] ; then echo -e "${summary_kr}" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt" ; fi
            elif [[ ${rmtbsnap} = 1 ]] && [[ ${rmfusnap} = 1 ]]
            then
                echo -e "## Snap including the Firefox, Thunderbird and Firmware Updater Snaps has been\n## removed from your system and the future installation of Snap has been blocked\n## by APT pinning in /etc/apt/preferences.d - the file is named \"no_snapd.pref\"." >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
                if ! test -x "/opt/firefox/firefox" ; then echo -e "${summary_ff}" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt" ; fi
                if ! test -x "/opt/thunderbird/thunderbird" ; then echo -e "${summary_tb}" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt" ; fi
                if [[ ${rmkrsnap} = 1 ]] ; then echo -e "${summary_kr}" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt" ; fi
            fi
            echo -e "## -> Be sure to remove any relevant APT pinning and reinstall Snap BEFORE a" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "##    release-upgrade to the next main Kubuntu™ version (e.g. from 24.10 to" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "##    25.04)!" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "##    You can do both with the \"reinstall_Snap_for_release-upgrade\" script." >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "${summary_reboot}" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "${summary_last}" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "Script version used: ${versionnr}" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "\n########\n## -> The summary of what has been done by this script was saved to:\n##    $HOME/get_rid_of_Snap-SUMMARY_${appendix}\n########\n"
            break
        elif [[ "${wantsave}" = [Yy] ]] && [[ ${rmsnap} = 1 ]] && [[ ${rmffsnap} = 0 ]] && [[ ${blocksnap} = 0 ]]
        then
            # Save to text file that Snap (including the Thunderbird and
            # Firmware Updater Snaps) has been removed and system reboot is
            # recommended
            echo -e "${summary_first}" > "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            if [[ ${rmtbsnap} = 1 ]] && [[ ${rmfusnap} = 1 ]]
            then
                echo -e "## Snap including the Thunderbird and Firmware Updater Snaps has been removed\n## from your system and the future installation of Snap has been blocked by APT\n## pinning in /etc/apt/preferences.d - the file is named \"no_snapd.pref\"." >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
                if ! test -x "/opt/thunderbird/thunderbird" ; then echo -e "${summary_tb}" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt" ; fi
                if [[ ${rmkrsnap} = 1 ]] ; then echo -e "${summary_kr}" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt" ; fi
            elif [[ ${rmtbsnap} = 1 ]] && [[ ${rmfusnap} = 0 ]]
            then
                echo -e "## Snap including the Thunderbird Snap has been removed from your system and the\n## future installation of Snap has been blocked by APT pinning in\n## /etc/apt/preferences.d - the file is named \"no_snapd.pref\"." >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
                if ! test -x "/opt/thunderbird/thunderbird" ; then echo -e "${summary_tb}" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt" ; fi
                if [[ ${rmkrsnap} = 1 ]] ; then echo -e "${summary_kr}" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt" ; fi
            elif [[ ${rmtbsnap} = 0 ]] && [[ ${rmfusnap} = 1 ]]
            then
                echo -e "## Snap including the Firmware Updater Snap has been removed from your system\n## and the future installation of Snap has been blocked by APT pinning in\n## /etc/apt/preferences.d - the file is named \"no_snapd.pref\"." >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
                if [[ ${rmkrsnap} = 1 ]] ; then echo -e "${summary_kr}" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt" ; fi
            elif [[ ${rmtbsnap} = 0 ]] && [[ ${rmfusnap} = 0 ]]
            then
                echo -e "## Snap has been removed from your system and the future installation of Snap\n## has been blocked by APT pinning in /etc/apt/preferences.d - the file is named\n## \"no_snapd.pref\"." >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
                if [[ ${rmkrsnap} = 1 ]] ; then echo -e "${summary_kr}" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt" ; fi
            fi
            echo -e "## -> Be sure to remove any relevant APT pinning and reinstall Snap BEFORE a" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "##    release-upgrade to the next main Kubuntu™ version (e.g. from 24.10 to" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "##    25.04)!" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "##    You can do both with the \"reinstall_Snap_for_release-upgrade\" script." >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "${summary_reboot}" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "${summary_last}" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "Script version used: ${versionnr}" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "\n########\n## -> The summary of what has been done by this script was saved to:\n##    $HOME/get_rid_of_Snap-SUMMARY_${appendix}\n########\n"
            break
        elif [[ "${wantsave}" = [Yy] ]] && [[ ${blocksnap} = 1 ]]
        then
            # Save to text file that future installation of Snap has been
            # blocked
            echo -e "${summary_first}" > "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "## The future installation of Snap has been blocked by APT pinning in\n## /etc/apt/preferences.d - the file is named \"no_snapd.pref\"." >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "## -> Be sure to remove any relevant APT pinning and reinstall Snap BEFORE a" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "##    release-upgrade to the next main Kubuntu™ version (e.g. from 24.10 to" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "##    25.04)!" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "##    You can do both with the \"reinstall_Snap_for_release-upgrade\" script." >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "${summary_last}" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "Script version used: ${versionnr}" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "\n########\n## -> The summary of what has been done by this script was saved to:\n##    $HOME/get_rid_of_Snap-SUMMARY_${appendix}\n########\n"
            break
        elif [[ "${wantsave}" = [Nn] ]]
        then
            echo
            break
        fi
    done
fi

########
## Give option to reboot, if this has been recommended
########
if [[ ${rmsnap} = 1 ]]
then
    echo -e "########\n## -> Do you want to reboot your system now as recommended?\n########"
    while true
    do
        read -p "[y/n] " rebootpc
        if [[ "${rebootpc}" = [Yy] ]]
        then
            reboot
            break
        elif [[ "${rebootpc}" = [Nn] ]]
        then
            echo
            break
        fi
    done
fi
