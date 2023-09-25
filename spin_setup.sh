#!/bin/bash

if [[ "$PWD" =~ \ |\' ]]
then
    echo "The path \"$PWD\" contains a space, please use another directory"
    exit 1
fi

echo "This script will install the following"
echo " - jspin"
echo " - spin(if not already present)"
echo " - graphviz(if not already present)"
echo " - gcc(if not already present)"
echo " - java(if not already present)"
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

# install Java
if ! command -v java &> /dev/null
then
    echo "installing java"
    sudo apt install default-jdk -y
fi

# Update config information
# C_COMPILER=gcc
sed -i 's/C_COMPILER=.*/C_COMPILER=gcc/g' jspin/config.cfg
# SPIN=spin
sed -i 's/SPIN=.*/SPIN=spin/g' jspin/config.cfg
# DOT=dot
sed -i 's/DOT=.*/DOT=dot/g' jspin/config.cfg
# C_COMPILER_OPTIONS=-w -o pan pan.c
sed -i 's/C_COMPILER_OPTIONS=.*/C_COMPILER_OPTIONS=-w -o pan pan.c/g' jspin/config.cfg

# create start start_spin.sh
echo "#!/bin/bash" > start_spin.sh
echo "" >> start_spin.sh
echo "cd jspin" >> start_spin.sh
echo "java -jar jspin.jar \$1" >> start_spin.sh


echo "wsl ./start_spin.sh" > start_spin.bat

echo "you can now start jspin with the following command"
echo "./start_spin.sh"
echo "or"
echo "$PWD/start_spin.sh"

