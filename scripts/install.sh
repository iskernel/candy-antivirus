#!/bin/bash

echo "Specify destination path for Candy Antivirus: "
read path
if [[ -d $path ]]; then
    nowpath=`pwd`
    cd $path
    mkdir "CandyAntivirus"
    cd $nowpath
    cp -avr "../lib/" "$path/CandyAntivirus/lib"
    cp -avr "../data/" "$path/CandyAntivirus/data"
    cp -avr "../CandyAntivirus.pl" "$path/CandyAntivirus/"
    cp -avr "candy_antivirus.sh" "$path/CandyAntivirus/"
    echo "Candy Antivirus was installed"
else
    echo "$path is not valid"
    echo "Candy Antivirus was not installed"
    exit 1
fi
