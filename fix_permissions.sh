#!/bin/bash

# For all folders
find ./airootfs -type d -exec chmod -R 755 {} \;
#find ./airootfs -type d -exec chown root:root {} \;
chown root:root -R ./airootfs
#chown root:root $(find ./airootfs |grep -v "/etc/skel")

chmod 700 ./airootfs/root
chmod -R 700 airootfs/etc/sudoers.d
chmod 444 ./airootfs/etc/sudoers.d/g_wheel
#chown root:root ./airootfs/etc/sudoers.d
#chown root:root ./airootfs/etc/sudoers.d/g_wheel
chmod +x ./{build.sh,mkarchiso,run_before_squashfs.sh}


