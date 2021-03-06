#! /bin/sh

# -----------------------------------
# Execute AndroVM VirtualBox Machine
# and AndroVM Player from shell
#
# http://androvm.org
# -----------------------------------

VM_MOUNT_CMD="udisks --mount /dev/mapper/volumes-VM"
VBOX_NAME=androVM_vbox86tp_4.1.1_r4-20121119-gapps-houdini-flash
ANDROVM_PATH=/media/VM/VirtualBox/AndroVM/AndroVMplayer-linux64
ANDROVM_OPTIONS="1280 720 160"

# Check for VM path, if not found then mount
if [ ! -d "$ANDROVM_PATH" ]; then
  `$VM_MOUNT_CMD`
fi


if [ ! -d "$ANDROVM_PATH" ]; then
  echo "AndroVM startup script error!"
  echo "AndroVM Virtual Machine not found"

  exit 10
fi

# Start VirtualBox machine
VBoxHeadless --startvm $VBOX_NAME &

sleep 3


# Start AndroVM Player
cd $ANDROVM_PATH
env LD_LIBRARY_PATH=. ./run.sh $ANDROVM_OPTIONS


# Power off VirtualBox machine
VBoxManage controlvm $VBOX_NAME poweroff




