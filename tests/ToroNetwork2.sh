#!/bin/sh
app="ToroNetwork2";
appsource="$app.pas";
appbin=$app;
appimg="$app.img";
debug=false;
emulate=false;
qemubios="c:/qemu-1.0/pc-bios/";
gdbdir="C:/mingw64/1.0/home/gdb-7.1/gdb/";
# checking the command line
while [ $# -gt 0 ]
do
    case "$1" in
		-d)  debug=true;;
		-e)  emulate=true;;
    esac
    shift
done
# debug or just emulate?
if $debug ; then
	fpc $appsource -o$appbin -g -Fu../rtl/ -Fu../rtl/drivers
	./build 2 $appbin boot.o $appimg
	# calling qemu
	if [ "$OSTYPE" == "msys" ] ; then
		qemu-system-x86_64 -s -S -L $qemubios -m 256 -hda $appimg -smp 2 -net nic,model=ne2k_pci -net tap,ifname=TAP2 &
	elif [ "$OSTYPE" == "linux-gnu" ] ; then
		iface=`sudo tunctl -b`
		qemu-system-x86_64 -s -S -m 256 -hda $appimg -smp 2 -net nic,model=ne2k_pci -net tap,ifname=$iface &
	fi
	# at this point we need a gdb patched
	$gdbdir/gdb $appbin
else
	# compiling
	fpc $appsource -o$appbin -Fu../rtl/ -Fu../rtl/drivers
	./build 2 $appbin boot.o $appimg
	# calling qemu
	if $emulate ; then
		if [ "$OSTYPE" == "msys" ] ; then
			qemu-system-x86_64 -L $qemubios -m 256 -hda $appimg -smp 2 -net nic,model=ne2k_pci -net tap,ifname=TAP2
	    elif [ "$OSTYPE" == "linux-gnu" ] ; then
			iface=`sudo tunctl -b`
			sudo qemu-system-x86_64 -m 256 -hda $appimg -smp 2 -net nic,model=ne2k_pci -net tap,ifname=$iface
		fi
    fi
fi
