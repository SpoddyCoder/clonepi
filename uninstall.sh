#!/bin/bash

# uninstall script for clonepi:
#
# - deletes clonepi command script
# - copies config dir to /tmp
# - deletes config dir


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
# config
#
INSTALL_DIR="/usr/local/sbin"
CONF_DIR="/etc/clonepi"
BAK_DIR="/tmp/clonepi-conf-bak"


# exit if not root
if [ `id -u` != 0 ]; then
	doError "The clonepi uninstaller needs to be run as root"
fi

#
# summarise and get user confirmation
#
echo
echo "This will remove clonepi and its config files from your system."
echo
read -p "Continue with uninstall (yes|no)? " UI < /dev/tty
if [ ! "$UI" = "y" -a ! "$UI" = "yes" ]; then
	doError "uninstall not confirmed" "user"
fi

#
# And uninstall
#
echo
if [ -f ${INSTALL_DIR}/clonepi ]; then
	rm -f ${INSTALL_DIR}/clonepi
	if [ "$?" = 0 ]; then
		echo "Deleted ${INSTALL_DIR}/clonepi"
        else
		doError "could not delete ${INSTALL_DIR}/clonepi"
	fi
fi
if [ -d ${CONF_DIR} ]; then
	rm -rf ${BAK_DIR} && mv ${CONF_DIR} ${BAK_DIR}
	if [ "$?" = 0 ]; then
		echo "Deleted ${CONF_DIR}"
        else
		doError "could not delete ${CONF_DIR}"
	fi
	echo "A copy of the config dir has been placed at ${BAK_DIR}"
	echo
fi
exit 0
