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
# This is a little helper script for Kubuntu™ (22.04 & later) users who want   #
# to install the traditional Firefox from Mozilla.org (the way Debian          #
# suggests) and use it complementary to or instead of the Firefox Snap.        #
# It can also remove Firefox, if it has been installed by this script before,  #
# and has been tested many times with Kubuntu™ 22.04 LTS up to 25.04.          #
#                                                                              #
# -> IMPORTANT:                                                                #
#    It is advised to run this script after a full upgrade of the system       #
#    (either with Discover or in Konsole with "sudo apt update && sudo apt     #
#    full-upgrade") AND a reboot.                                              #
#                                                                              #
# -> Firefox from Mozilla.org can simply be used alternatively with or without #
#    the Firefox Snap and no further actions are to be taken.                  #
#    It will remain installed when release-upgrading (e.g. from 24.10 to       #
#    25.04) and causes no conflicts during the upgrade process.                #
#    This version of Firefox behaves roughly like the ones for macOS™ or       #
#    Windows™ do and updates itself independently from Discover or APT package #
#    management (and can ask you before updating - if you would prefer being   #
#    asked see the Firefox settings).                                          #
#                                                                              #
# You will be asked if you want [1] to download and install Firefox from       #
# Mozilla.org OR [2] to remove a previously installed Firefox, but if you      #
# choose [3] to cancel, no changes at all are made to your system.             #
# After you chose [1] to install Firefox from Mozilla.org, you will be asked   #
# to select your preferred language next.                                      #
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
echo -e "## This is a little helper script for Kubuntu™ (22.04 & later) users who want"
echo -e "## to install the traditional Firefox from Mozilla.org (the way Debian"
echo -e "## suggests) and use it complementary to or instead of the Firefox Snap."
echo -e "## It can also remove Firefox, if it has been installed by this script before,"
echo -e "## and has been tested many times with Kubuntu™ 22.04 LTS up to 25.04."
echo -e "##"
echo -e "## -> IMPORTANT:"
echo -e "##    It is advised to run this script after a full upgrade of the system"
echo -e "##    (either with Discover or in Konsole with \"sudo apt update && sudo apt"
echo -e "##    full-upgrade\") AND a reboot."
echo -e "## -> Firefox from Mozilla.org can simply be used alternatively with or without"
echo -e "##    the Firefox Snap and no further actions are to be taken."
echo -e "##    It will remain installed when release-upgrading (e.g. from 24.10 to"
echo -e "##    25.04) and causes no conflicts during the upgrade process."
echo -e "##    This version of Firefox behaves roughly like the ones for macOS™ or"
echo -e "##    Windows™ do and updates itself independently from Discover or APT package"
echo -e "##    management (and can ask you before updating - if you would prefer being"
echo -e "##    asked see the Firefox settings)."
echo -e "##"
echo -e "## You will be asked if you want [1] to download and install Firefox from"
echo -e "## Mozilla.org OR [2] to remove a previously installed Firefox, but if you"
echo -e "## choose [3] to cancel, no changes at all are made to your system."
echo -e "## After you chose [1] to install Firefox from Mozilla.org, you will be asked"
echo -e "## to select your preferred language next."
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
## Install or remove the traditional Firefox from Mozilla.org (the way Debian
## suggests - see: https://wiki.debian.org/Firefox#From_Mozilla_binaries) and
## remove the Mozilla Team PPA placeholder files (if they have been installed by
## a previous version of the scripts)
########
inff=0
fferror=0
rmff=0

# Test if the operating system is Kubuntu 22.04 or later / Ubuntu 22.04 or
# later-based with KDE Plasma
if ! cat /etc/os-release | grep -Ei "(^|\s)VERSION=(|\s|\"|\s\")(22.04|22.10|23.04|23.10|24.04|24.10)" &> /dev/null || ! echo "$XDG_CURRENT_DESKTOP" | grep -i KDE &> /dev/null
then
    echo -e "\n######################################################################\n## This script is meant to be used with Kubuntu™ 22.04 LTS or later ##\n## -> PROCEED AT YOUR OWN RISK!                                     ##\n######################################################################"
fi

echo -e "\n########\n## Do you want to:\n## [1] DOWNLOAD and INSTALL the latest stable Firefox from Mozilla.org?"
echo -e "##     or\n## [2] REMOVE Firefox from /opt if it has been installed by this script before?"
if test -d "$HOME/.mozilla/firefox" ; then echo -e "##     (Your user data e.g. in \".mozilla\" within your $HOME" ; fi
if test -d "$HOME/.mozilla/firefox" ; then echo -e '##     directory will NOT be touched!)'; fi
echo -e "##     or\n## [3] CANCEL the download and installation or removal?\n########"

# Give option to cancel the installation
while true
do
    read -p "[1], [2] or [3] " choice
    if [[ "${choice}" = "1" ]]
    then
        # Test if traditional Firefox is still installed in 20.04 up to 21.10
        if cat /etc/os-release | grep -Ei "(^|\s)VERSION=(|\s|\"|\s\")(20.04|20.10|21.04|21.10)" &> /dev/null && [[ -d "/usr/lib/firefox" ]] && command -v firefox &> /dev/null
        then
            echo -e "\n########\n## Traditional Firefox seems to already be installed -> not changing anything …\n########"
            break
        # Test if traditional Firefox is installed conventionally/from a PPA or
        # to /opt
        elif [[ -d "/usr/lib/firefox" && $(command -v firefox) ]] || test -x "/opt/firefox/firefox"
        then
            echo -e "\n########\n## Traditional Firefox seems to already be installed -> not changing anything …\n########"
            break
        else
            # Choose from a list of languages and download latest stable Firefox
            # in the chosen language to $HOME - see:
            # https://ftp.mozilla.org/pub/firefox/releases/latest/README.txt
            echo
            PS3="$(printf '\nChoose your preferred language for Firefox: ')"
            select languagesel in "Acholi lang=ach" "Afrikaans lang=af" "Albanian lang=sq" "Arabic lang=ar" "Aragonese lang=an" "Armenian lang=hy-AM" "Assamese lang=as" "Asturian lang=ast" "Azerbaijani lang=az" "Basque lang=eu" "Belarusian lang=be" "Bengali (Bangladesh) lang=bn-BD" "Bengali (India) lang=bn-IN" "Bosnian lang=bs" "Breton lang=br" "Bulgarian lang=bg" "Catalan lang=ca" "Chinese (Simplified) lang=zh-CN" "Chinese (Traditional) lang=zh-TW" "Croatian lang=hr" "Czech lang=cs" "Danish lang=da" "Dutch lang=nl" "English (British) lang=en-GB" "English (South African) lang=en-ZA" "English (US) lang=en-US" "Esperanto lang=eo" "Estonian lang=et" "Finnish lang=fi" "French lang=fr" "Frisian lang=fy-NL" "Fulah lang=ff" "Gaelic (Scotland) lang=gd" "Galician lang=gl" "German lang=de" "Greek lang=el" "Gujarati (India) lang=gu-IN" "Hebrew lang=he" "Hindi (India) lang=hi-IN" "Hungarian lang=hu" "Icelandic lang=is" "Indonesian lang=id" "Irish lang=ga-IE" "Italian lang=it" "Kannada lang=kn" "Kazakh lang=kk" "Khmer lang=km" "Korean lang=ko" "Latvian lang=lv" "Ligurian lang=lij" "Lithuanian lang=lt" "Lower Sorbian lang=dsb" "Macedonian lang=mk" "Maithili lang=mai" "Malay lang=ms" "Malayalam lang=ml" "Marathi lang=mr" "Norwegian (BokmÃ¥l) lang=nb-NO" "Norwegian (Nynorsk) lang=nn-NO" "Oriya lang=or" "Persian lang=fa" "Polish lang=pl" "Portuguese (Brazilian) lang=pt-BR" "Portuguese (Portugal) lang=pt-PT" "Punjabi (India) lang=pa-IN" "Romanian lang=ro" "Romansh lang=rm" "Russian lang=ru" "Serbian lang=sr" "Sinhala lang=si" "Slovak lang=sk" "Slovenian lang=sl" "Songhai lang=son" "Spanish (Argentina) lang=es-AR" "Spanish (Chile) lang=es-CL" "Spanish (Mexico) lang=es-MX" "Spanish (Spain) lang=es-ES" "Swedish lang=sv-SE" "Tamil lang=ta" "Telugu lang=te" "Thai lang=th" "Turkish lang=tr" "Ukrainian lang=uk" "Upper Sorbian lang=hsb" "Uzbek lang=uz" "Vietnamese lang=vi" "Welsh lang=cy" "Xhosa lang=xh"
            do
                if [[ $REPLY -ge 1 && $REPLY -le 88 ]]
                then
                    languagename="$(echo "${languagesel}" | sed 's/ lang.*$//')"
                    languagecode="$(echo "${languagesel}" | sed 's/^.* //')"
                    echo -e "\n########\n## -> Downloading ${languagename} version of Firefox from Mozilla.org …\n########\n" && wget -O "$HOME/firefox-latest-stable.tar.xz" "https://download.mozilla.org/?product=firefox-latest&os=linux64&${languagecode}"
                    # Test if archive was e.g. not available at all
                    if [[ $? -ne 0 ]]
                    then
                        echo -e '\n#############################################################################\n## -> AN ERROR OCCURED! <-                                                 ##'
                        echo -e "## Firefox seems not to be available in your chosen language at the moment ##\n## -> not changing anything …                                              ##\n#############################################################################"
                        fferror=1
                        break 2
                    fi
                    break
                else
                    echo -e "\n-> Please enter a valid number [1-88]!"
                fi
            done
            
            # Decompress the downloaded Firefox archive
            echo -e "########\n## -> Decompressing the Firefox archive …\n########\n" && tar xf "$HOME/firefox-latest-stable.tar.xz" -C "$HOME"
            # Test if archive was e.g. corrupt
            if [[ $? -ne 0 ]]
            then
                echo -e '\n##############################################\n## -> AN ERROR OCCURED! <-                  ##'
                echo -e "## This Firefox archive seems to be corrupt ##\n## -> not changing anything …               ##\n##############################################"
                fferror=1
                break
            fi

            # Install Firefox to /opt
            echo -e "########\n## -> Installing Firefox from Mozilla.org to /opt …\n########\n" && sudo mv "$HOME/firefox" /opt

            # Clean up: remove the dowloaded Firefox archive from $HOME
            if test -e "$HOME/firefox-latest-stable.tar.xz" ; then echo -e "\n########\n## -> Cleaning up …\n########\n" && rm -f "$HOME/firefox-latest-stable.tar.xz" ; fi

            # Make the new Firefox accessible from CLI (don't use /usr/bin -
            # otherwise the link could be removed when release-upgrading /
            # (re)installing the Firefox Snap)
            # Create /usr/local/bin before, if it doesn't exit
            sudo mkdir -p /usr/local/bin && sudo ln -s /opt/firefox/firefox /usr/local/bin/firefox

            # Create firefox.desktop in /usr/local/share/applications to give
            # all users access to the new Firefox via application menu (don't
            # use /usr/share/applications - otherwise the .desktop file could be
            # removed when release-upgrading / (re)installing the Firefox Snap)
            echo -e "########\n## -> Writing firefox.desktop file to /usr/local/share/applications/ :\n########\n"
            # Create /usr/local/share/applications before, if it doesn't exit
            sudo mkdir -p /usr/local/share/applications
            echo -e "[Desktop Entry]\nName=Firefox from Mozilla.org\nComment=Browse the World Wide Web\nGenericName=Web Browser\nKeywords=Internet;WWW;Browser;Web;Explorer\nExec=/opt/firefox/firefox %u\nTerminal=false\nType=Application\nIcon=/opt/firefox/browser/chrome/icons/default/default128.png\nCategories=Network;WebBrowser;\nMimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/vnd.mozilla.xul+xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;\nStartupNotify=true\nActions=Private;\n\n[Desktop Action Private]\nExec=/opt/firefox/firefox --private-window %u\nName=Open in private mode\n" | sudo tee /usr/local/share/applications/firefox.desktop

            # Rebuild the KDE Plasma application menu index as sometimes this
            # helps when the new Firefox does not show properly (especially if
            # the Firefox Snap is additionally installed)
            if command -v kbuildsycoca6 &> /dev/null
            then
                kbuildsycoca6 &> /dev/null
            elif command -v kbuildsycoca5 &> /dev/null
            then
                kbuildsycoca5 &> /dev/null
            fi

            # Make the new Firefox the main application for www-browser
            sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser /opt/firefox/firefox 200 && sudo update-alternatives --set x-www-browser /opt/firefox/firefox

            # Test if the "Mozilla Team PPA" placeholder file from a previous
            # version of the scripts is in $HOME and remove it
            if test -f "$HOME/.mtppa-placeholder" ; then rm -f "$HOME/.mtppa-placeholder" ; fi

            # Test if the "prefer Firefox from the Mozilla Team PPA APT pinning"
            # placeholder file from a previous version of the scripts is in
            # $HOME and remove it
            if test -f "$HOME/.mtppa-ffpin-placeholder" ; then  rm -f "$HOME/.mtppa-ffpin-placeholder" ; fi

            # Test if the "Firefox from the Mozilla Team PPA" placeholder file
            # from a previous version of the scripts is in $HOME and remove it
            if test -f "$HOME/.mtff-placeholder" ; then rm -f "$HOME/.mtff-placeholder" ; fi

            inff=1
            break
        fi
    elif [[ "${choice}" = "2" ]]
    then
        # Test if traditional Firefox has been installed to /opt by this script
        if ! [[ -x "/opt/firefox/firefox" && -r "/usr/local/share/applications/firefox.desktop" ]]
        then
            echo -e "\n########\n## Traditional Firefox does not seem to have been installed from Mozilla.org\n## to /opt by this script before -> not changing anything …\n########"
            break
        else
            # Give option to cancel
            echo -e "\n########\n## Are you sure you want to UNINSTALL traditional Firefox from /opt ?\n########"
            while true
            do
                read -p "[y/n] " removeff
                if [[ "${removeff}" = [Yy] ]]
                then
                    # Remove Firefox from /opt, the link from /usr/local/bin and
                    # the .desktop file from /usr/local/share/applications
                    echo -e "\n########\n## -> Removing traditional Firefox from /opt …\n########\n"
                    sudo rm -rf /opt/firefox && sudo rm -f /usr/local/bin/firefox && sudo rm -f /usr/local/share/applications/firefox.desktop

                    # Rebuild the KDE Plasma application menu index
                    if command -v kbuildsycoca6 &> /dev/null
                    then
                        kbuildsycoca6 &> /dev/null
                    elif command -v kbuildsycoca5 &> /dev/null
                    then
                        kbuildsycoca5 &> /dev/null
                    fi

                    rmff=1
                    break 2
                elif [[ "${removeff}" = [Nn] ]]
                then
                    echo -e "\n########\n## You have canceled the removal of traditional Firefox from /opt\n## -> not changing anything …\n########"
                    break 2
                fi
            done
        fi
    elif [[ "${choice}" = "3" ]]
    then
        echo -e "\n########\n## You have canceled the download & installation or removal of the traditional\n## Firefox -> not changing anything …\n########"
        break
    fi
done

########
## Report what has been done
########
summary_first="\n########\n## -> SUMMARY:"
summary_what="## Firefox has been successfully installed from Mozilla.org to /opt ."
summary_where="## -> You can find it in your application menu under \"Internet\"."
summary_snap="## -> Be aware that the Firefox Snap is still additionally installed.\n##    DON'T START AND USE BOTH the traditional Firefox AND the Firefox Snap\n##    SIMULTANEOUSLY - this can lead to problems!"
summary_snapremove="##    You can remove and block Snaps entirely with the \"get_rid_of_Snap\" script."
summary_nochange="## The script has made no changes at all to your system!"
summary_last="## Have a nice day and enjoy Kubuntu™.\n########\n"
summary_lastff="## Have a nice day and enjoy your new Firefox and Kubuntu™.\n########\n"
savesummary=0

if [[ ${inff} = 1 ]]
then
    # Tell that Firefox has been installed from Mozilla.org
    echo -e "${summary_first}"
    echo -e "${summary_what}"
    echo -e "${summary_where}"
    if snap list firefox &> /dev/null ; then echo -e "${summary_snap}" ; fi
    if snap list firefox &> /dev/null ; then echo -e "${summary_snapremove}" ; fi
    echo -e "${summary_lastff}"
    savesummary=1
elif [[ ${rmff} = 1 ]]
then
    # Tell that Firefox has been removed from /opt
    echo -e "${summary_first}"
    echo -e "## Firefox has been successfully removed from /opt ."
    if test -d "$HOME/.mozilla/firefox" ; then echo -e "## -> Your user data in \".mozilla\" within your $HOME" ; fi
    if test -d "$HOME/.mozilla/firefox" ; then echo -e '##    directory has NOT been touched!'; fi
    echo -e "${summary_last}"
    savesummary=1
elif [[ ${inff} = 0 ]] && [[ ${fferror} = 1 ]]
then
    # Tell that an error has occured and nothing has been changed
    echo -e "${summary_first}"
    echo -e '## Firefox could NOT be installed from Mozilla.org to /opt !'
    echo -e "## It was either not available in your chosen language at the moment or this\n## archive was corrupt…"
    echo -e "## -> Please run the script again and choose a more \"common\" (but nonetheless\n##    fitting) language version instead."
    echo -e "##    After the installation you can change to your preferred language in\n##    Firefox when it starts for the first time or later on in the Firefox\n##    settings."
    echo -e "${summary_nochange}"
    echo -e "${summary_last}"
else
    # Tell that nothing has been changed
    echo -e "${summary_first}"
    echo -e "${summary_nochange}"
    echo -e "${summary_last}"
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
        if [[ "${wantsave}" = [Yy] ]] && [[ ${inff} = 1 ]]
        then
            # Save to text file that Firefox has been installed from Mozilla.org
            echo -e "${summary_first}" > "$HOME/install_traditional_Firefox-SUMMARY_${appendix}.txt"
            echo -e "${summary_what}" >> "$HOME/install_traditional_Firefox-SUMMARY_${appendix}.txt"
            echo -e "${summary_where}" >> "$HOME/install_traditional_Firefox-SUMMARY_${appendix}.txt"
            if snap list firefox &> /dev/null ; then echo -e "${summary_snap}" >> "$HOME/install_traditional_Firefox-SUMMARY_${appendix}.txt" ; fi
            if snap list firefox &> /dev/null ; then echo -e "${summary_snapremove}" >> "$HOME/install_traditional_Firefox-SUMMARY_${appendix}.txt" ; fi
            echo -e "${summary_lastff}" >> "$HOME/install_traditional_Firefox-SUMMARY_${appendix}.txt"
            echo -e "Script version used: ${versionnr}" >> "$HOME/install_traditional_Firefox-SUMMARY_${appendix}.txt"
            echo -e "\n########\n## -> The summary of what has been done by this script was saved to:\n##    $HOME/install_traditional_Firefox-SUMMARY_${appendix}\n########\n"
            break
        elif [[ "${wantsave}" = [Yy] ]] && [[ ${rmff} = 1 ]]
        then
            # Save to text file that Firefox has been removed from /opt
            echo -e "${summary_first}" > "$HOME/install_traditional_Firefox-SUMMARY_${appendix}.txt"
            echo -e "## Firefox has been successfully removed from /opt ." >> "$HOME/install_traditional_Firefox-SUMMARY_${appendix}.txt"
            if test -d "$HOME/.mozilla/firefox" ; then echo -e "## -> Your user data in \".mozilla\" within your $HOME" >> "$HOME/install_traditional_Firefox-SUMMARY_${appendix}.txt" ; fi
            if test -d "$HOME/.mozilla/firefox" ; then echo -e '##    directory has NOT been touched!' >> "$HOME/install_traditional_Firefox-SUMMARY_${appendix}.txt" ; fi
            echo -e "${summary_last}" >> "$HOME/install_traditional_Firefox-SUMMARY_${appendix}.txt"
            echo -e "Script version used: ${versionnr}" >> "$HOME/install_traditional_Firefox-SUMMARY_${appendix}.txt"
            echo -e "\n########\n## -> The summary of what has been done by this script was saved to:\n##    $HOME/install_traditional_Firefox-SUMMARY_${appendix}\n########\n"
            break
        elif [[ "${wantsave}" = [Nn] ]]
        then
            echo
            break
        fi
    done
fi
