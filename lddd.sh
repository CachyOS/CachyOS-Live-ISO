#!/bin/bash
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

src_dir=$(pwd)
[[ -r ${src_dir}/util-msg.sh ]] && source ${src_dir}/util-msg.sh

ifs=$IFS
IFS="${IFS}:"

libdirs="/lib /usr/lib /usr/local/lib $(cat /etc/ld.so.conf.d/*)"
extras=

TMPDIR=$(mktemp -d --tmpdir lddd-script.XXXX)

msg 'Go out and drink some tea, this will take a while :) ...'
#  Check ELF binaries in the PATH and specified dir trees.
for tree in $PATH $libdirs $extras; do
    msg2 "DIR $tree"

    #  Get list of files in tree.
    files=$(find $tree -type f ! -name '*.a' ! -name '*.la' ! -name '*.py*' ! -name '*.txt' ! -name '*.h' ! -name '*.ttf' ! \
    -name '*.rb' ! -name '*.ko' ! -name '*.pc' ! -name '*.enc' ! -name '*.cf' ! -name '*.def' ! -name '*.rules' ! -name \
    '*.cmi' ! -name  '*.mli' ! -name '*.ml' ! -name '*.cma' ! -name '*.cmx' ! -name '*.cmxa' ! -name '*.pod' ! -name '*.pm' \
    ! -name '*.pl' ! -name '*.al' ! -name '*.tcl' ! -name '*.bs' ! -name '*.o' ! -name '*.png' ! -name '*.gif' ! -name '*.cmo' \
    ! -name '*.cgi' ! -name '*.defs' ! -name '*.conf' ! -name '*_LOCALE' ! -name 'Compose' ! -name '*_OBJS' ! -name '*.msg' ! \
    -name '*.mcopclass' ! -name '*.mcoptype')
    IFS=$ifs
    for i in $files; do
        if (( $(file $i | grep -c 'ELF') != 0 )); then
            #  Is an ELF binary.
            if (( $(ldd $i 2>/dev/null | grep -c 'not found') != 0 )); then
                #  Missing lib.
                echo "$i:" >> $TMPDIR/raw.txt
                ldd $i 2>/dev/null | grep 'not found' >> $TMPDIR/raw.txt
            fi
        fi
    done
done
grep '^/' $TMPDIR/raw.txt | sed -e 's/://g' >> $TMPDIR/affected-files.txt
# invoke pacman
for i in $(cat $TMPDIR/affected-files.txt); do
    pacman -Qo $i | awk '{print $4,$5}' >> $TMPDIR/pacman.txt
done
# clean list
sort -u $TMPDIR/pacman.txt >> $TMPDIR/possible-rebuilds.txt

msg "Files saved to $TMPDIR"
