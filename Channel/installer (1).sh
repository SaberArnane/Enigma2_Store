#!/usr/bin/bash
# coding BY: MOHAMED_OS

# colors
Color_Off="\e[0m" # Text Reset
Red="\e[0;31m"    # Red
Yellow="\e[0;33m" # Yellow
Blue='\e[0;34m'   # Blue
Green='\e[0;32m'  # Green

if uname -n | grep -qs "^novaler4k" || uname -n | grep -qs "^multibox"; then
    opkg update >/dev/null 2>&1
else
    clear
    echo
    echo -e "${Blue}Goodbye ;)${Color_Off}"
    echo
    exit 1
fi

###########################################
# Configure where we can find things here #
pyVersion=$(python -c"from sys import version_info; print(version_info[0])")
SitUrl='https://raw.githubusercontent.com/SaberArnane/Enigma2_Store/main/Channel'
TmpDir='/var/volatile/tmp'

####################
#  Depends Checking  #
arrVar=("ffmpeg" "gstplayer" "exteplayer3" "enigma2-plugin-systemplugins-serviceapp" "alsa-plugins" "gstreamer1.0-plugins-base-meta" "gstreamer1.0-plugins-base" "gstreamer1.0-plugins-base-apps" "gstreamer1.0-plugins-good")

if [ "${pyVersion}" = 3 ]; then
    arrVar+=("python3-core" "python3-futures3" "python3-image" "python3-json" "python3-multiprocessing" "python3-pillow" "python3-requests" "python3-cryptography")
else
    arrVar+=("python-core" "python-futures" "python-image" "python-imaging" "python-json" "python-multiprocessing" "python-requests" "python-cryptography")
fi
for PkgFile in "${arrVar[@]}"; do
    if ! grep -qs "Package: $PkgFile" '/var/lib/opkg/status'; then
        echo -e ">>>>   Please Wait Install ${Green}${PkgFile}${Color_Off}   <<<<"
        echo
        opkg install "${PkgFile}"
        wait
        sleep 0.8
        clear
    fi
done

if [ "$(opkg info libcrypto-compat | grep -Fic Package)" = 1 ]; then
    LibPkg="libcrypto-compat"
else
    LibPkg="libcrypto-compat-1.0.0"
fi
####################################
# Build
if [ -z "$Pkg" ]; then
    clear
    echo -e "> ${Yellow}Novaler${Color_Off}"
    echo
    echo "  1 - Channel Motour"
    echo "  2 - Cahnnel 3 Satellite"
    echo
    echo "  x - Exit"
    echo
    echo "- Enter option:"

    read -r choice
    case $choice in
    "1") Pkg=channels_backup_user ;;
    "2") Pkg=channels_backup_user ;;

    x)
        clear
        echo
        echo -e "${Blue}Goodbye ;)${Color_Off}"
        echo
        exit 1
        ;;
    *)
        echo "Invalid option"
        sleep 3
        exit 1
        ;;
    esac
fi

####################

if [ "$choice" = 1 ] || [ "$choice" = 2 ]; then # Channel Motour | Channel 3 Satellite
    VerPkg='2.1-r0'
fi

IFS='-'
read -ra PkgName <<<"${Pkg}"

rm -rf $TmpDir/"${Pkg:?}"* >/dev/null 2>&1

if [ "$(opkg list-installed "$Pkg" | awk '{ print $3 }')" = "$VerPkg" ]; then
    echo " You are use the laste Version: $VerPkg"

    echo ""
    echo "******************************************************"
    echo "**                                                    "
    echo "**    ${PkgName[3]} : ${VerPkg}                       "
    echo -e "**    Script by  : ${Yellow}MOHAMED_OS${Color_Off} "
    echo -e "**    Support    : ${Blue}https://www.novaler.com/${Color_Off} "
    echo "**                                                    "
    echo "******************************************************"
    echo ""

    sleep 2
    exit 1
elif [ -z "$(opkg list-installed "$Pkg" | awk '{ print $3 }')" ]; then
    echo
    clear
else
    opkg remove --force-depends "$Pkg"
fi

echo -e "${Yellow}Downloading ${PkgName[3]} plugin Please Wait ......${Color_Off}"
wget --no-check-certificate $SitUrl/"${Pkg}"_"${VerPkg}"_all.ipk -qP $TmpDir

echo -e "${Yellow}Insallling ${PkgName[3]} plugin Please Wait ......${Color_Off}"
opkg install --force-overwrite $TmpDir/"${Pkg}"_"${VerPkg}"_all.ipk

rm -rf $TmpDir/"${Pkg:?}"* >/dev/null 2>&1

if [ "$choice" = 7 ] || [ "$choice" = 8 ]; then
    if [ "$(opkg list-installed | grep -Fic ${LibPkg})" = 0 ]; then
        opkg install ${LibPkg}
    fi
fi

sleep 0.8
sync
echo ""
echo ""
echo "********************************************************"
echo "*                                                      *"
echo "*    ${PkgName[3]} : ${VerPkg}                                   *"
echo -e "*    Script by  : ${Yellow}MOHAMED_OS${Color_Off}                           *"
echo -e "*    Uploaded by: ${Yellow}Saber-Arnane${Color_Off}                         *"
echo -e "*    Support    : ${Blue}https://www.novaler.com/${Color_Off}                       *"
echo "*                                                      *"
echo "********************************************************"
echo ""
echo ""

sleep 2
echo -e "${Yellow}" "Device will restart now" "${Color_Off}"
killall -9 enigma2

wait
exit
