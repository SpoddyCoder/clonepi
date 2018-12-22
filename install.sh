#!/bin/bash

# install script for ClonePi
# last updated @ v1.7.4
#
# - gets latest available version from github
# - updates source repo if possible
# - checks dependencies: system, rsync and fsck.vfat
# - copies clonepi to /usr/local/sbin & sets owner/permisions
# - copies configuration files to /etc/clonepi/ & sets owner/perms
#
# ClonePi version format: "major.minor.revision"


#
# helper functions
#
doMsg()
{
	# msg, type
	case "$2" in
		warn)
			printf "WARNING: ${1}\n"
			echo
			;;
		user-abort)
			printf "User aborted: ${1}\n"
			echo
			exit 0
			;;
		error)
			printf "ERROR: ${1}\n"
			echo "Aborting!"
			echo
			exit 1
			;;
		info-abort)
			printf "INFO: ${1}\n"
			echo "Nothing to do!"
			echo
			exit 0
			;;
	esac
}


#
# config + setup
#
INSTALL_DIR="/usr/local/sbin"
CONF_DIR="/etc/clonepi"
BAK_DIR="/tmp/clonepi-conf-bak"
GITHUB_VERSION_URL="https://raw.githubusercontent.com/SpoddyCoder/clonepi/master/version.txt"
CUR_INSTALLER_VER=`head -10 install.sh | grep "last updated" | cut -f2 -d'@' | xargs | cut -f2 -d'v'`

echo
echo "Welcome to the ClonePi installer"
echo
if [ `id -u` != 0 ]; then
	doMsg "The ClonePi installer needs to be run as root" "error"
fi
# get current state
# ...version for this installer
NEW_VERSION=`cat version.txt | xargs`
# ...version currently installed
CUR_VERSION=0
if [ -f ${INSTALL_DIR}/clonepi ]; then
	CUR_VERSION=`${INSTALL_DIR}/clonepi -v | grep "ClonePi v" | sed 's/^ClonePi v//'`
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
# ...current conf & excludes versions, if installed
CUR_CONF_VER=""
CUR_EXCLUDES_VER=""
if [ -d $CONF_DIR ]; then
	if [ -f ${CONF_DIR}/clonepi.conf ]; then
		CUR_CONF_VER=`head -5 ${CONF_DIR}/clonepi.conf | grep "last updated" | cut -f2 -d'@' | xargs | cut -f2 -d'v'`
	fi
	if [ -f ${CONF_DIR}/raspbian.excludes ]; then
		CUR_EXCLUDES_VER=`head -5 ${CONF_DIR}/raspbian.excludes | grep "last updated" | cut -f2 -d'@' | xargs | cut -f2 -d'v'`
	fi
fi


#
# update repo to latest, if possible
#
if [ -d .git ]; then
	# running inside git repo
	if [ "$REMOTE_VERSION" = "$NEW_VERSION" ]; then
		echo "Source repo is at latest version."
		echo
	else
		doMsg "Source repo is not upto date." "warn"
		read -p "Perform a 'git pull origin master' now (yes|no)? " UI < /dev/tty
		if [ ! "$UI" = "y" -a ! "$UI" = "yes" ]; then
			echo "Continuing without updating the repo"
			echo
		else
			echo "Updating repo..."
			su - `logname` -c "cd `pwd` && git pull origin master"
			if [ $? = 0 ]; then
			        echo "Repo updated sucessfully"
				# check if installer has been updated
				NEW_INSTALLER_VER=`head -5 install.sh | grep "last updated" | cut -f2 -d'@' | xargs | cut -f2 -d'v'`
				if [ "$CUR_INSTALLER_VER" != "$NEW_INSTALLER_VER" ]; then
					doMsg "the installer has been updated, please re-run" "error"
				fi
			else
			        doMsg "problem updating repo." "error"
			fi
			NEW_VERSION=`cat version.txt | xargs`
		fi
	fi
else
	# not a git repo, assume download zip
	if [ "$REMOTE_VERSION" != "$NEW_VERSION" ]; then
		doMsg "Source install dir is not upto date.\nDownload the latest zip to get latest version." "error"
	fi
fi


#
# check dependencies
#
# system check
IS_RASPBIAN=`lsb_release -d | grep -i Raspbian`
if [ -z "$IS_RASPBIAN" -o ! $? = 0 ]; then
	doMsg "this doesn't look like a Rapsbian system." "warn"
	echo "Your OS is reported as:"
	lsb_release -d
	echo
	echo "ClonePi is designed to work on Raspberry Pi systems. Please proceed, if you know what you're doing."
	echo
fi
# rsync check
if ! rsync --version > /dev/null; then
	doMsg "ClonePi requires rsync. Run the following to install: sudo apt-get update && sudo apt-get install rsync" "error"
fi
# fsck.vfat check
if ! test -e /sbin/fsck.vfat; then
	doMsg "ClonePi requires dosfstools. Run the following to install: sudo apt-get update && sudo apt-get install dosfstools" "error"
fi

#
# pre-install setup
#
NEW_CONF_VER=`head -5 conf/clonepi.conf | grep "last updated" | cut -f2 -d'@' | xargs | cut -f2 -d'v'`
NEW_EXCLUDES_VER=`head -5 conf/raspbian.excludes | grep "last updated" | cut -f2 -d'@' | xargs | cut -f2 -d'v'`
UPGRADE_CONF=false
UPGRADE_EXCLUDES=false
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
if ! $INSTALL_CONF_FILE; then
	# check if existing version is latest
	if [ "$CUR_CONF_VER" = "$NEW_CONF_VER" ]; then
		UPGRADE_CONF=false
	else
		UPGRADE_CONF=true
	fi
fi
if ! $INSTALL_EXCLUDES_FILE; then
        # check if existing version is latest
        if [ "$CUR_EXCLUDES_VER" = "$NEW_EXCLUDES_VER" ]; then
                UPGRADE_EXCLUDES=false
        else
                UPGRADE_EXCLUDES=true
        fi
fi

#
# summarise and get user confirmation
#
if [ "$INSTALL_CONF_DIR" = false -a "$INSTALL_CONF_FILE" = false -a "$INSTALL_EXCLUDES_FILE" = false -a "$INSTALL_CLONEPI" = false -a "$UPGRADE_CONF" = false -a "$UPGRADE_EXCLUDES" = false ]; then
	doMsg "ClonePi v${CUR_VERSION} already installed with latest config files" "info-abort"
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
	if $UPGRADE_CONF; then
		echo " - Upgrade the config file at ${CONF_DIR}/clonepi.conf"
	fi
	if $UPGRADE_EXCLUDES; then
                echo " - Upgrade the excludes file at ${CONF_DIR}/raspbian.excludes"
        fi
fi
echo
read -p "Continue with install (yes|no)? " UI < /dev/tty
if [ ! "$UI" = "y" -a ! "$UI" = "yes" ]; then
	doMsg "installation not confirmed" "user-abort"
fi

#
# And finally install
#
if $INSTALL_CLONEPI; then
	rm -f ${INSTALL_DIR}/clonepi && cp ./src/clonepi ${INSTALL_DIR}/clonepi && chown root:root ${INSTALL_DIR}/clonepi && chmod u+x ${INSTALL_DIR}/clonepi
	if [ "$?" = 0 ]; then
		echo "Installed ClonePi to ${INSTALL_DIR}/clonepi"
	else
		doMsg "could not install ClonePi to ${INSTALL_DIR}/clonepi" "error"
	fi
fi

if $INSTALL_CONF_DIR; then
	mkdir ${CONF_DIR}
	if [ "$?" = 0 ]; then
		echo "Created config directory at ${CONF_DIR}"
	else
		doMsg "could not create config directory at ${CONF_DIR}" "error"
	fi
fi

if $INSTALL_CONF_FILE; then
	cp ./conf/clonepi.conf ${CONF_DIR}/clonepi.conf
	if [ "$?" = 0 ]; then
		echo "Installed config file at ${CONF_DIR}/clonepi.conf"
        else
		doMsg "could not install config file at ${CONF_DIR}/clonepi.conf" "error"
        fi
fi

if $INSTALL_EXCLUDES_FILE; then
	cp ./conf/raspbian.excludes ${CONF_DIR}/raspbian.excludes
	if [ "$?" = 0 ]; then
		echo "Installed config file at ${CONF_DIR}/raspbian.excludes"
        else
		doMsg "could not install config file at ${CONF_DIR}/raspbian.excludes" "error"
        fi
fi

if [ "$UPGRADE_CONF" = true -o "$UPGRADE_EXCLUDES" = true ]; then
	rm -rf ${BAK_DIR} && mkdir ${BAK_DIR}
	if $UPGRADE_CONF; then
		mv ${CONF_DIR}/clonepi.conf ${BAK_DIR}
		cp ./conf/clonepi.conf ${CONF_DIR}/clonepi.conf
		if [ "$?" = 0 ]; then
                	echo "Replaced config file at ${CONF_DIR}/clonepi.conf with latest version"
			doMsg "Your old config file has been moved to ${BAK_DIR} - if you have modified this, you may need to merge back in any of your own changes" "warn"
        	else
        	        doMsg "could not install config file at ${CONF_DIR}/clonepi.conf" "error"
        	fi
	fi
	if $UPGRADE_EXCLUDES; then
		mv ${CONF_DIR}/raspbian.excludes ${BAK_DIR}
                cp ./conf/raspbian.excludes ${CONF_DIR}/raspbian.excludes
		if [ "$?" = 0 ]; then
                	echo "Replaced excludes file at ${CONF_DIR}/raspbian.excludes with latest version"
                        doMsg "Your old excludes file has been moved to ${BAK_DIR} - if you have modified this, you may need to merge back in your own changes" "warn"
        	else
        	        doMsg "could not install excludes file at ${CONF_DIR}/raspbian.excludes" "error"
        	fi
	fi
fi

chown -R root:root ${CONF_DIR}
chmod -R 755 ${CONF_DIR}
echo
echo "Installation complete!"
echo
exit 0
