# PART 1 - EXTEND EBS VOLUME WITHOUT PARTITIONING
# launch an instance from aws console
# check volumes which volumes attached to instance. 
# only root volume should be listed
lsblk
# create a new volume from aws console.
# attach the new volume from aws console, then list block storages again.
# root volume and secondary volume should be listed
lsblk
# check if the attached volume is already formatted or not and has data on it.
sudo file -s /dev/xvdf
# if not formatted, format the new volume
sudo mkfs -t ext4 /dev/xvdf
# create a mounting point path for new volume
sudo mkdir /mnt/2nd-vol
# mount the new volume to the mounting point path
sudo mount /dev/xvdf /mnt/2nd-vol/
# check if the attached volume is mounted to the mounting point path
lsblk
# show the available space, on the mounting point path
df -h
# if there is data on it, check if the data still persists.
ls -lh /mnt/2nd-vol/
# if there is no data on it, create a new file to show persistence in later steps
sudo touch who-wants-to-live-forever.txt
ls
# modify the new volume in aws console, and enlarge capacity to double gb.
# check if the attached volume is showing the new capacity
lsblk
# show the real capacity used currently at mounting path, old capacity should be shown.
df -h
# resize the file system on the new volume to cover all available space.
sudo resize2fs /dev/xvdf
# show the real capacity used currently at mounting path, new capacity should reflect the modified volume size.
df -h
# show that the data still persists on the newly enlarged volume.
ls -lh /mnt/2nd-vol/
# show that mounting point path will be gone when instance rebooted 
sudo reboot now
# show the new volume is still attached, but not mounted
lsblk
# check if the attached volume is already formatted or not and has data on it.
sudo file -s /dev/xvdf
# mount the new volume to the mounting point path
sudo mount /dev/xvdf /mnt/2nd-vol/
# show the used and available capacity is same as the disk size.
df -h
# if there is data on it, check if the data still persists.
ls -lh /mnt/2nd-vol/
# #############

# PART 2 - EXTEND EBS VOLUME WITH PARTITIONING
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/recognize-expanded-volume-linux.html
# https://www.tecmint.com/fdisk-commands-to-manage-linux-disk-partitions/
# list volumes to show current status, primary (root) and secondary volumes should be listed
lsblk
# show the used and available capacities related with volumes
df -h
# create tertiary volume on aws console
# attach the new volume from aws console, then list volumes again.
#  primary (root), secondary and tertiary volumes should be listed
lsblk
# show the used and available capacities related with volumes
df -h
# show the current partitions... use "fdisk -l /dev/xvda" for specific partition
sudo fdisk -l
# check all available fdisk commands
sudo fdisk /dev/xvdg
# n -> add new partition (with 2G size)
# p -> primary
# Partition number: 1
# Last sector: +1500M
# n -> add new partition (with rest of the size)
# p -> primar
# Partition number: 2
# p -> show the partition table
# w -> write partition table
# show new partitions
lsblk
# format the new partitions
sudo mkfs -t ext4 /dev/xvdg1
sudo mkfs -t ext4 /dev/xvdg2
# create a mounting point path for new volume
sudo mkdir /mnt/3rd-vol-part1
sudo mkdir /mnt/3rd-vol-part2
# mount the new volume to the mounting point path
sudo mount /dev/xvdg1 /mnt/3rd-vol-part1/
sudo mount /dev/xvdg2 /mnt/3rd-vol-part2/
# list volumes to show current status, all volumes and partittions should be listed
lsblk
# show the used and available capacities related with volumes and partitions
df -h
# if there is no data on it, create a new file to show persistence in later steps
sudo touch /mnt/3rd-vol-part2/i-want-to-survive.txt
ls -lh /mnt/3rd-vol-part2/
# modify the new volume in aws console, and enlarge capacity to double gb.
# check if the attached volume is showing the new capacity
lsblk
# show the real capacity used currently at mounting path, old capacity should be shown.
df -h
# extend the partition 2 and occupy all newly avaiable space
sudo growpart /dev/xvdg 2
# ​show the real capacity used currently at mounting path, updated capacity should be shown.
df -h
# resize and extend the file system
sudo resize2fs /dev/xvdg2
# show and save the UUIDs of each volume and partitions
sudo file -s /dev/xvdf
sudo file -s /dev/xvdg
sudo file -s /dev/xvdg1
sudo file -s /dev/xvdg2
# reboot and show that configuration is gone
sudo reboot now
#############################

# PART 3 - AUTOMOUNT EBS VOLUMES AND PARTITIONS ON REBOOT
# secondary volume UUID=d0b4716b-1147-4d25-8e44-22f28c6e342d
# tertiary volume partition 1 UUID=ab3aa290-c38c-4057-ad17-3491d2291655
# tertiary volume partition 2 UUID=7e00b524-1d30-4bc1-b015-73e2ad92e594
# back up the /etc/fstab file.
sudo cp /etc/fstab /etc/fstab.bak
# open /etc/fstab file and make an entry in the following format.
# /dev/xvdf       /newvolume   ext4    defaults,nofail        0       0
sudo vim /etc/fstab
# mount volumes and partitions with fstab file.
sudo mount -a
# list volumes to show current status, all volumes and partittions should be listed
lsblk
# show the used and available capacities related with volumes and partitions
df -h
# if there is data on it, check if the data still persists.
ls -lh /mnt/2nd-vol/
ls -lh /mnt/3rd-vol-part2/
# reboot and show that configuration is gone
sudo reboot now
# list volumes to show current status, all volumes and partittions should be listed
lsblk
# show the used and available capacities related with volumes and partitions
df -h
# if there is data on it, check if the data still persists.
ls -lh /mnt/2nd-vol/
ls -lh /mnt/3rd-vol-part2/
##############################