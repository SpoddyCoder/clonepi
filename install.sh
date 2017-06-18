#!/bin/bash

# install script for clonepi:
#
# - gets latest available version from github
# - updates source repo if possible
# - checks dependencies: system, rsync and fsck.vfat
# - copies clonepi to /usr/local/sbin & sets owner/permisions
# - copies configuration files to /etc/clonepi/ & sets owner/perms
#   - only if they don't yet exist (will not overwrite existing configuration)
#

# ClonePi version format: "major.minor.revision"
# TODO: currently installed config files version check & warning
# - revision releases will always work without needing to update config files
# - breakign changes will be restricted to minor/major releases


#
# helper functions
#
doError()
{
	# msg, type
	case "$2" in
		warn)
			printf "WARNING: ${1}\n"
			echo
			;;
		user)
			printf "User aborted: ${1}\n"
			echo
			exit 0
			;;
		*)
			printf "ERROR: ${1}\n"
			echo "Aborting!"
			echo
			exit 1
			;;
	esac
}


#
# config + setup
#
INSTALL_DIR="/usr/local/sbin"
CONF_DIR="/etc/clonepi"
GITHUB_VERSION_URL="https://raw.githubusercontent.com/SpoddyCoder/clonepi/master/version.txt"

echo
echo "Welcome to the ClonePi installer"
echo
if [ `id -u` != 0 ]; then
	doError "The ClonePi installer needs to be run as root"
fi
# get current state
# ...version for this installer
NEW_VERSION=`cat version.txt | xargs`
# ...version currently installed
CUR_VERSION=0
if [ -f ${INSTALL_DIR}/clonepi ]; then
	CUR_VERSION=`${INSTALL_DIR}/clonepi | grep "ClonePi v" | sed 's/^ClonePi v//'`
fi
# ...version on github
echo "Checking for latest version number at GitHub..."
REMOTE_VERSION=$(wget -q -O - $GITHUB_VERSION_URL)
if [ $? = 0 ]; then
	echo "...latest available version is ${REMOTE_VERSION}"
else
	echo "...error trying to get latest version - assuming source repo/dir is upto date."
	REMOTE_VERSION=$NEW_VERSION
fi
echo


#
# update repo to latest, if possible
#
if [ -d .git ]; then
	if [ "$REMOTE_VERSION" = "$NEW_VERSION" ]; then
		echo "Source repo is at latest version."
		echo
	else
		doError "Source repo is not upto date." "warn"
		read -p "Perform a 'git pull origin master' now (yes|no)? " UI < /dev/tty
		if [ ! "$UI" = "y" -a ! "$UI" = "yes" ]; then
			echo "Continuing without updating the repo"
			echo
		else
			echo "Updating repo..."
			su - `logname` -c "cd `pwd` && git pull origin master"
			if [ $? = 0 ]; then
			        echo "Repo updated sucessfully"
			        echo
			else
			        doError "problem updating repo."
			fi
			NEW_VERSION=`cat version.txt | xargs`
		fi
	fi
else
	if [ "$CUR_VERSION" != "$NEW_VERSION" ]; then
		doError "Source install dir is not upto date.\nDownload the latest zip to get latest version." "warn"
	fi
fi


#
# check dependencies
#
# system check
IS_RASPBIAN=`lsb_release -d | grep -i Raspbian`
if [ -z "$IS_RASPBIAN" -o ! $? = 0 ]; then
	doError "this doesn't look like a Rapsbian system." "warn"
	echo "Your OS is reported as:"
	lsb_release -d
	echo
	echo "ClonePi is designed to work on Raspberry Pi systems. Please proceed, if you know what you're doing."
	echo
fi
# rsync check
if ! rsync --version > /dev/null; then
	doError "ClonePi requires rsync."
fi
# fsck.vfat check
if ! test -e /sbin/fsck.vfat; then
	doError "fsck.vfat was not found. ClonePi requires dosfstools."
fi

#
# pre-install setup
#
INSTALL_CLONEPI=true
INSTALL_CONF_DIR=true
INSTALL_CONF_FILE=true
INSTALL_EXCLUDES_FILE=true
if [ "$CUR_VERSION" = "$NEW_VERSION" ]; then
	INSTALL_CLONEPI=false
fi
if [ -d ${CONF_DIR} ]; then
	INSTALL_CONF_DIR=false
	if [ -f ${CONF_DIR}/clonepi.conf ]; then
		INSTALL_CONF_FILE=false
	fi
	if [ -f ${CONF_DIR}/raspbian.excludes ]; then
                INSTALL_EXCLUDES_FILE=false
        fi
fi

#
# summarise and get user confirmation
#
if [ "$INSTALL_CONF_DIR" = false -a "$INSTALL_CONF_FILE" = false -a "$INSTALL_EXCLUDES_FILE" = false -a "$INSTALL_CLONEPI" = false ]; then
	doError "Latest ClonePi v${CUR_VERSION} already installed and config files in place" "info"
	echo "Nothing to do - exiting!"
	echo
	exit 0
else
	echo "This will..."
	if $INSTALL_CLONEPI; then
		if [ "$CUR_VERSION" = 0 ]; then
			echo " - Install ClonePi $NEW_VERSION"
		else
			echo " - Update ClonePi from $CUR_VERSION to $NEW_VERSION"
		fi
	fi
	if $INSTALL_CONF_DIR; then
		echo " - Install missing config directory at ${CONF_DIR}"
	fi
	if $INSTALL_CONF_FILE; then
		echo " - Install missing config file at ${CONF_DIR}/clonepi.conf"
	fi
	if $INSTALL_EXCLUDES_FILE; then
		echo " - Install missing config file at ${CONF_DIR}/raspbian.excludes"
	fi
fi
echo
read -p "Continue with install (yes|no)? " UI < /dev/tty
if [ ! "$UI" = "y" -a ! "$UI" = "yes" ]; then
	doError "installation not confirmed" "user"
fi

#
# And finally install
#
if $INSTALL_CLONEPI; then
	rm -f ${INSTALL_DIR}/clonepi && cp ./src/clonepi ${INSTALL_DIR}/clonepi && chown root:root ${INSTALL_DIR}/clonepi && chmod u+x ${INSTALL_DIR}/clonepi
	if [ "$?" = 0 ]; then
		echo "Installed ClonePi to ${INSTALL_DIR}/clonepi"
	else
		doError "could not install ClonePi to ${INSTALL_DIR}/clonepi"
	fi
fi

if $INSTALL_CONF_DIR; then
	mkdir ${CONF_DIR}
	if [ "$?" = 0 ]; then
		echo "Created config directory at ${CONF_DIR}"
	else
		doError "could not create config directory at ${CONF_DIR}"
	fi
fi

if $INSTALL_CONF_FILE; then
	cp ./conf/clonepi.conf ${CONF_DIR}/clonepi.conf
	if [ "$?" = 0 ]; then
		echo "Installed config file at ${CONF_DIR}/clonepi.conf"
        else
		doError "could not install config file at ${CONF_DIR}/clonepi.conf"
        fi
fi

if $INSTALL_EXCLUDES_FILE; then
	cp ./conf/raspbian.excludes ${CONF_DIR}/raspbian.excludes
	if [ "$?" = 0 ]; then
		echo "Installed config file at ${CONF_DIR}/raspbian.excludes"
        else
		doError "could not install config file at ${CONF_DIR}/raspbian.excludes"
        fi
fi
chown -R root:root ${CONF_DIR}
chmod -R 755 ${CONF_DIR}
echo
echo "Installation complete!"
echo
exit 0
