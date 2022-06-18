#!/bin/bash
echo
echo "################################################################## "
tput setaf 2
echo "Phase 1 : "
echo "- Setting General parameters"
tput sgr0
echo "################################################################## "
echo

    # setting of the general parameters
    archisoRequiredVersion="archiso 64-1"
    currentFolder=$(pwd)
    buildFolder="${currentFolder}/build"
    outFolder="${currentFolder}/out"
    archisoVersion=$(sudo pacman -Q archiso)

    echo "################################################################## "
    echo "Build folder                           : "$buildFolder
    echo "Out folder                             : "$outFolder
    echo "################################################################## "

echo
echo "################################################################## "
tput setaf 2
echo "Phase 2 :"
echo "- Checking if archiso is installed"
echo "- Making mkarchiso verbose"
tput sgr0
echo "################################################################## "
echo

    package="archiso"

    #----------------------------------------------------------------------------------

    #checking if application is already installed or else install with aur helpers
    if pacman -Qi $package &> /dev/null; then

            echo "Archiso is already installed"

    else

        #checking which helper is installed
        if pacman -Qi yay &> /dev/null; then

            echo "################################################################"
            echo "######### Installing with yay"
            echo "################################################################"
            yay -S --noconfirm $package

        elif pacman -Qi trizen &> /dev/null; then

            echo "################################################################"
            echo "######### Installing with trizen"
            echo "################################################################"
            trizen -S --noconfirm --needed --noedit $package

        fi

        # Just checking if installation was successful
        if pacman -Qi $package &> /dev/null; then

            echo "################################################################"
            echo "#########  "$package" has been installed"
            echo "################################################################"

        else

            echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            echo "!!!!!!!!!  "$package" has NOT been installed"
            echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            exit 1
        fi

    fi

    echo
    echo "Making mkarchiso verbose"
    sudo sed -i 's/quiet="y"/quiet="n"/g' /usr/bin/mkarchiso

echo
echo "################################################################## "
tput setaf 2
echo "Phase 3 :"
echo "- Deleting the build folder if one exists"
echo "- Copying the Archiso folder to build folder"
tput sgr0
echo "################################################################## "
echo

    echo "Deleting the build folder if one exists - takes some time"
    [ -d $buildFolder ] && sudo rm -rf $buildFolder
    echo
    echo "Copying the Archiso folder to build work"
    echo
    mkdir $buildFolder
    cp -r archiso $buildFolder/archiso

echo
echo "################################################################## "
tput setaf 2
echo "Phase 6 :"
echo "- Cleaning the cache from /var/cache/pacman/pkg/"
tput sgr0
echo "################################################################## "
echo

    echo "Cleaning the cache from /var/cache/pacman/pkg/"
    yes | sudo pacman -Scc

echo
echo "################################################################## "
tput setaf 2
echo "Phase 7 :"
echo "- Building the iso - this can take a while - be patient"
tput sgr0
echo "################################################################## "
echo

    [ -d $outFolder ] || mkdir $outFolder
    cd $buildFolder/archiso/
    sudo mkarchiso -v -w $buildFolder -o $outFolder $buildFolder/archiso/


    echo "Moving pkglist.x86_64.txt"
    echo "########################"
    rename=$(date +%Y-%m-%d)
    cp $buildFolder/iso/arch/pkglist.x86_64.txt  $outFolder/cachyos-$rename-pkglist.txt

echo
echo "##################################################################"
tput setaf 2
echo "DONE"
echo "- Check your out folder :"$outFolder
tput sgr0
echo "################################################################## "
echo
