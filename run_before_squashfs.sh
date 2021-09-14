#!/bin/bash

# Made by Fernando "maroto"
# Run anything in the filesystem right before being "mksquashed"
# ISO-NEXT specific cleanup removals and additions (08-2021) @killajoe and @manuel

script_path=$(readlink -f ${0%/*})
work_dir=work

# Adapted from AIS. An excellent bit of code!
arch_chroot(){
    arch-chroot $script_path/${work_dir}/x86_64/airootfs /bin/bash -c "${1}"
}

do_merge(){

arch_chroot "

sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
usermod -s /usr/bin/bash root
cp -aT /etc/skel/ /root/
rm /root/xed.dconf
chmod 700 /root
useradd -m -p \"\" -g users -G 'sys,rfkill,wheel' -s /bin/bash liveuser
git clone --single-branch https://gitlab.com/cachyos/liveuser-desktop-settings.git
#git clone https://gitlab.com/cachyos/liveuser-desktop-settings.git
cd liveuser-desktop-settings
rm -R /home/liveuser/.config
cp -R .config /home/liveuser/
chown -R liveuser:liveuser /home/liveuser/.config
cp .xinitrc .xprofile .Xauthority /home/liveuser/
chown liveuser:liveuser /home/liveuser/.xinitrc
chown liveuser:liveuser /home/liveuser/.xprofile
chown liveuser:liveuser /home/liveuser/.Xauthority
cp -R .local /home/liveuser/
chown -R liveuser:liveuser /home/liveuser/.local
chmod +x /home/liveuser/.local/bin/*
cp user_pkglist.txt /home/liveuser/
chown liveuser:liveuser /home/liveuser/user_pkglist.txt
rm /home/liveuser/.bashrc
cp .bashrc /home/liveuser/
chown liveuser:liveuser /home/liveuser/.bashrc
cp LICENSE /home/liveuser/
cd ..
rm -R liveuser-desktop-settings
chmod 755 /etc/sudoers.d
mkdir -p /media
chmod 755 /media
chmod 440 /etc/sudoers.d/g_wheel
chown 0 /etc/sudoers.d
chown 0 /etc/sudoers.d/g_wheel
chown root:root /etc/sudoers.d
chown root:root /etc/sudoers.d/g_wheel
chmod 755 /etc
sed -i 's/#\(PermitRootLogin \).\+/\1yes/' /etc/ssh/sshd_config
# sed -i 's/#Server/Server/g' /etc/pacman.d/mirrorlist
sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf
sed -i 's/#\(HandleSuspendKey=\)suspend/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleHibernateKey=\)hibernate/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleLidSwitch=\)suspend/\1ignore/' /etc/systemd/logind.conf
systemctl enable NetworkManager.service vboxservice.service vmtoolsd.service vmware-vmblock-fuse.service systemd-timesyncd
systemctl set-default multi-user.target

cp -rf /usr/share/mkinitcpio/hook.preset /etc/mkinitcpio.d/linux.preset
sed -i 's?%PKGBASE%?linux?' /etc/mkinitcpio.d/linux.preset

# fetch fallback mirrorlist for offline installs:
wget https://gitlab.com/cachyos/cachyos-archiso/-/raw/master/mirrorlist
cp mirrorlist /etc/pacman.d/
rm mirrorlist

# now done with recreating pacman keyring inside calamares:
# shellprocess_initialize_pacman
#pacman-key --init
#pacman-key --add /usr/share/pacman/keyrings/cachyos.gpg && sudo pacman-key --lsign-key F3B607488DB35A47
#pacman-key --populate
#pacman-key --refresh-keys
#pacman -Syy

# now done with recreating pacman keyring inside calamares:
# shellprocess_initialize_pacman
#rm -R /etc/pacman.d/gnupg

sed -i 's|^GRUB_CMDLINE_LINUX_DEFAULT=\"\(.*\)\"$|GRUB_CMDLINE_LINUX_DEFAULT=\"\1 nowatchdog\"|' /etc/default/grub
sed -i 's?GRUB_DISTRIBUTOR=.*?GRUB_DISTRIBUTOR=\"CachyOS\"?' /etc/default/grub
sed -i 's?\#GRUB_THEME=.*?GRUB_THEME=\/boot\/grub\/themes\/CachyOS\/theme.txt?g' /etc/default/grub
echo 'GRUB_DISABLE_SUBMENU=y' >> /etc/default/grub
rm /boot/grub/grub.cfg
wget https://gitlab.com/cachyos/liveuser-desktop-settings/-/raw/master/dconf/xed.dconf
dbus-launch dconf load / < xed.dconf
sudo -H -u liveuser bash -c 'dbus-launch dconf load / < xed.dconf'
rm xed.dconf
chmod -R 700 /root
chown root:root -R /root
chown root:root -R /etc/skel
mkdir -p /root/src
ln -s /usr/share/calamares/qml /root/src/qml
touch /CHANGES
chsh -s /bin/bash"
}

#################################
########## STARTS HERE ##########
#################################

do_merge
