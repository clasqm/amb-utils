#!/bin/sh

# Creates FreeDOS-ready .amb ebooks (codepage 437) on linux once
# all the .ama files have been prepared.

# Should work on all West European languages. 437 is a "least common
# denominator" in DOS 8-bit code pages, and ebooks made with this
# should remain readable to users using CP850 and CP858 (Don't use box-
# drawing characters). Includes a premade 437 to UTF8 conversion map
# for use on *NIX systems.

# Made for my own purposes - filled to the brim with hardcoded paths
# but feel free to adapt it for your own purposes.

cd ~/Unzip/etexts/workspace
mkdir final
cp title ./final/
cp ../unicode.map ./final/
for i in *.ama; do utf8tocp 437 $i > final/$i; done
cd final
echo filename?
read
ambpack c . /home/michel/Dropbox/devuan/git/amb-utils/AMB/$REPLY
cd /home/michel/Dropbox/devuan/git/amb-utils/AMB/
amb $REPLY
read -r -p "Delete temporary files? [Y/n] " input
 case $input in
    [yY][eE][sS]|[yY])
cd ~/Unzip/etexts/workspace
rm -f ./final/*
rmdir ./final
 ;;
    [nN][oO]|[nN])
 echo "OK, then"
       ;;
    *)
 echo "Invalid input..."
 exit 1
 ;;
esac

