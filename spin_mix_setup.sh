#!/bin/bash

if [[ "$PWD" =~ \ |\' ]]
then
    echo "The path \"$PWD\" contains a space, please use another directory"
    exit 1
fi


# Reconstruct the windows path based on the linux path
# Sorry if this failed
windowsPath="value"
drive="c"
if [[ $PWD == "/mnt/"* ]]; then
    drive=$(echo "$PWD" | cut -c 6)
    windowsPath=$(echo "$PWD" | cut -c 8-)
else
    drive=$(echo "$PWD" | cut -c 2)
    windowsPath=$(echo "$PWD" | cut -c 4-)
fi
windowsPath="$drive:/$windowsPath"
# echo "$windowsPath"
# exit 
uppercaseDrive=$(echo "$drive" | tr '[a-z]' '[A-Z]')

echo "This script will install the following"
echo " - jspin"
echo " - spin(if not already present)"
echo " - graphviz(if not already present)"
echo " - gcc(if not already present)"
echo "Install jspin? THIS WILL DELETE EVERYTHING INSIDE THE $PWD/jspin DIRECTORY [y/n]"

read continueInstall
if ! [[ $continueInstall == "Y" || $continueInstall == "y" ]]; then
    echo "ok bye"
    exit
fi

# DELETE spin folder(Be careful if you change this line)
rm -rf jspin

mkdir jspin

# update
sudo apt update

# Installing GCC
if ! command -v gcc &> /dev/null
then
    echo "installing gcc"
    sudo apt install build-essential -y
fi
# if this part failed consider just installing gcc

# Install graphviz
if ! command -v graphviz &> /dev/null
then
    echo "installing graphviz"  
    sudo apt install graphviz -y
fi
# if this failed maybe install from source

# install spin
if ! command -v spin &> /dev/null
then
    echo "installing spin"  
    sudo apt-get install spin -y
fi
# if this part failed you can install from source https://spinroot.com/spin/Man/README.html

# Installing jspin
echo "Installing jspin"
wget -O jspin/jspin-5-0.zip "https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/jspin/jspin-5-0.zip"
sudo apt-get install unzip
unzip jspin/jspin-5-0.zip -d jspin
# if this part failed check if the url has changed https://code.google.com/archive/p/jspin/downloads

# Create bat files
echo "wsl spin %*" > jspin/wsl-spin.bat
echo "wsl gcc %*" > jspin/wsl-gcc.bat
echo "wsl ./pan %*" > jspin/wsl-pan.bat
echo "wsl ./pan %*" > jspin/jspin-examples/wsl-pan.bat
echo "wsl ./pan %*" > jspin/spider-examples/wsl-pan.bat
mkdir jspin/programs
echo "wsl ./pan %*" > jspin/programs/wsl-pan.bat

# to call dot we have to change windows paths to WSL paths
# Loop through all command line arguments
echo "@echo off"                                                         > jspin/wsl-dot.bat
echo "setlocal enabledelayedexpansion"                                  >> jspin/wsl-dot.bat
# init empty array
echo "set \"modifiedArgs=\""                                            >> jspin/wsl-dot.bat
echo "for %%A in (%*) do ("                                             >> jspin/wsl-dot.bat
echo "    set \"arg=%%A\""                                              >> jspin/wsl-dot.bat
# replace \ with
echo "    set \"arg=!arg:\=/!\""                                        >> jspin/wsl-dot.bat
# Check if the argument contains "C:/" (Windows path)
echo "    echo !arg! | findstr /R /C:\"$uppercaseDrive:/.*\" > nul"              >> jspin/wsl-dot.bat
echo "    if !errorlevel!==0 ("                                         >> jspin/wsl-dot.bat
# Convert Windows path to WSL path manually
echo "        set \"modifiedArg=!arg:$uppercaseDrive:/=/mnt/$drive/!\"" >> jspin/wsl-dot.bat
# Append the modified argument to the array
echo "        set \"modifiedArgs=!modifiedArgs! !modifiedArg!\""        >> jspin/wsl-dot.bat
echo "    ) else ("                                                     >> jspin/wsl-dot.bat
echo "        set \"modifiedArgs=!modifiedArgs! %%A\""                  >> jspin/wsl-dot.bat
echo "    )"                                                            >> jspin/wsl-dot.bat
echo ")"                                                                >> jspin/wsl-dot.bat
echo "wsl dot !modifiedArgs!"                                           >> jspin/wsl-dot.bat
echo "endlocal"                                                         >> jspin/wsl-dot.bat


# Update config information
# C_COMPILER=$windowsPath/jspin/wsl-gcc.bat
sed -i "s@C_COMPILER=.*@C_COMPILER=$windowsPath/jspin/wsl-gcc.bat@g" jspin/config.cfg
# SPIN=$windowsPath/jspin/wsl-spin.bat
sed -i "s@SPIN=.*@SPIN=$windowsPath/jspin/wsl-spin.bat@g" jspin/config.cfg
# DOT=$windowsPath/jspin/wsl-dot.bat
sed -i "s@DOT=.*@DOT=$windowsPath/jspin/wsl-dot.bat@g" jspin/config.cfg
# PAN=wsl-pan.bat
sed -i "s@PAN=.*@PAN=wsl-pan.bat@g" jspin/config.cfg
# C_COMPILER_OPTIONS=-w -o pan pan.c
sed -i 's/C_COMPILER_OPTIONS=.*/C_COMPILER_OPTIONS=-w -o pan pan.c/g' jspin/config.cfg

echo "cd jspin" > start_spin.bat
echo "./run.bat %*" >> start_spin.bat

echo "You have to place your programs in a directory containing wsl-pan.bat"
echo "We have by default created this file in"
echo "- \"$PWD/jspin/jspin-examples\""
echo "- \"$PWD/jspin/programs/\""
echo "WARNING: This setup is fragile and will break if you move the folder."
echo "you can now start jspin with the following command(From windows)"
echo "./start_spin.bat"

