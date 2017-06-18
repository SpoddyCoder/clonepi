# ClonePi

ClonePi will clone a running Raspberry Pi file to a destination SD card plugged into a USB card reader. Features:

* Works with standard 2 partition Raspbian setups and multi-partition NOOBS setups
* On-the-fly clone
* Size up or down to fit the destination disk
* Configuration options allow it to be tuned to work with many systems / use cases
* Script hooks allow it to be extended beyond the default use cases


## Prerequisites
ClonePi works on Raspberry Pi's running a Debian based OS (Raspbian tested). It requires rsync & dosfstools, these are normally installed but if not, run the following...

```
$ sudo apt-get update
$ sudo apt-get install rsync
$ sudo apt-get install dosfstools
```


## Installing / Updating

Clone this repo to your Raspberry Pi (or download the zip). Run the installer as root...

```
$ git clone 
$ cd clonepi
$ sudo ./install.sh
```

Simply re-run the installer at any time to update to latest version. To completely remove ClonePi and config files, run the uninstaller...

```
$ sudo ./uninstall.sh
```

A copy of the config files is placed in `/tmp/clonepi-bak/` in case you need to restore them.


## Usage

ClonePi must be run as root
```
$ sudo clonepi --help
```

### Examples
Clone to card at /dev/sdb
```
$ sudo clonepi /dev/sdb
```

Clone to card at /dev/sdb, forcing initialisation of the disk
```
$ sudo clone /dev/sdb --init-destination
```

Clone to card at /dev/sdb after initialising + resizing the disk, list files as they are synced
```
$ sudo clonepi /dev/sdb --fill-destination --verbose
```

### Options 

+ `--help` show usage info
+ `--init-destination` force initialisation of the destination disk. This will erase all of its contents.
+ `--fill-destination` fill destination disk. Implies `--init-destination`. Will attempt to resize the last partition to fill the destination disk. If the source disk is larger than the destination it will attempt to resize down, but this may or may not leave room for the content.
+ `--verbose` list all files as they are rsynced.
+ `--dry-run` apply --dry-run flag to rsync, which will show files that would be synced, but not actually sync them.
+ `--script` TODO: run in non-interactive mode. All user input is assumed to be yes. Useful for running via cron.

### Modes of Operation

+ ClonePi will initialise the destination disk if its partition structure does not match the source disk.
+ If the destination disk matches the source partition structure then ClonePi assumes this is an initialised disk and an incremental copy will be performed.
+ You can override this behaviour with the command line options.

#### Initialisation + Copy
First time setup of the destination disk. 
It will format the destination card to match the source disk partition structure and then perform a first time sync. 
This can be expected to take a while.

#### Incremental Copy
Subsequent updates to the an initialised clone.
It will sync files that have changed since last sync.
This will be much quicker than full init + copy.


## Use cases
Typical use cases for ClonePi are backing up a system for disaster recover or cloning a system to run on other Pi's. 

### Backup

1. Initialise + copy the disk, eg: `sudo clonepi /dev/sdb --init-destination`
1. Perform incremental update at regular intervals, eg: `sudo clonepi /dev/sdb`

### Cloning for other PI's

1. Initialise + copy the disk, eg: `sudo clonepi /dev/sdb --init-destination`
1. Before unmounting the clone disk (don't press enter to cleanup), use a 2nd shell window to modify any files on the clone you need for it to work on other Pi's
1. Eg: you may want to edit the hostname, network configuration etc.
1. You can use the script hooks to automate this final step.


## Configuration
ClonePi utilises configuration files at `/etc/clonepi/`. 
These can be edited to tune ClonePi for your system and use case. 
Notes on each of the configurable items are included in the files.

+ **clonepi.conf** - main config file
+ **raspbian.excludes** - files/directories to be excluded from the running OS sync

Script hooks allow you to inject your own code at specific points during the ClonePi process. Typical use cases;

+ Stop services/apps before starting sync and restarting them after sync finishes.
+ Prepare the source disk before syncing.
+ Prepare the clone disk after sync - eg: modify hostname/fixed IP address if intended for anothe Pi on your network etc.

All script hooks run as a subprocess so they have access to all ClonePi variables.
You can optionally end your scripts with an exit code and ClonePi will take the following actions (no exit code = success)

+ **exit 0** and clonepi will **continue**
+ **exit 1** and clonepi will **output an error and abort**
+ **exit 2** and clonepi will **output a warning and continue**


## Additional Notes
This project owes it's genesis to rpi-clone and is based on the same clever "partial dd & full rsync" approach.
If your use case is simple and you are just running a standard 2 partition Raspbian install, then consider using Bill's much simpler and lighter-weight version at https://github.com/billw2/rpi-clone

#### Some hints for the less experienced
You will need to know the device name of your SD card. ClonePi cannot determine this for you, but run the following command to identify all attached disks...
```
$ sudo fdisk -l
```
A couple of tips and a couple warnings when identifying your device;

1. the first disk will be the current booted Raspberry Pi SD card `mmcblk0p1 / mmcblk0p2` - i.e. the disk you will be cloning from
1. size is normally the easiest way to identify particular SD cards
1. using the incorrect device identifier will likely result in data loss on that disk
1. depending on the system setup, the device identifier **can change** between reboots, so you should always confirm the correct disk before running clonepi

#### Some hints for the more experienced
1. The script hooks are your friend
1. ClonePi probably works on non-Debian systems, but you may need to modify the OS_EXCLUDES_FILE (please consider contributing)


## Contributing
Contributions and pull requests are welcome, but we ask the following guidelines are respected;

+ the PR adds a compelling new feature 
+ OR addresses a known / open issue
+ OR improves reliability / robustness
+ adhere to current coding style used within the source - good comments, tab indents etc.
+ be hygenic, ensure all secondary tasks are done - robustness checks, update summary, readme, installer etc.
+ don't update version num - will be incremented when the PR is merged

## Authors
1. **Paul Fernihough** - original author - (paul--at--spoddycoder.com)
