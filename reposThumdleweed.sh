#!/bin/bash

# reposThundleweed.sh

# script remove and add repositories openSuse Thumdleweed
# we need to lauch this script with root

# Version
VERSION="tumbleweed"

# Mirrors
MIRROR="http://download.opensuse.org/"
PACKMAN="http://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed/"

# Repositories list

# Open Source Software
REPONAME[1]="oss"
REPOSITE[1]="${MIRROR}/${VERSION}/repo/oss"
PRIORITY[1]="99" #standard

# Open Source Software
REPONAME[2]="non-oss"
REPOSITE[2]="${MIRROR}/${VERSION}/repo/oss"
PRIORITY[2]="99" #standard

# Open Source Update
REPONAME[3]="update"
REPOSITE[3]="${MIRROR}/${VERSION}/repo/oss"
PRIORITY[3]="99" #standard

# Non Open Source Update
REPONAME[4]="non-update"
REPOSITE[4]="${MIRROR}/${VERSION}/repo/oss"
PRIORITY[4]="99" #standard

# Provides codecs and audio and video player applications
REPONAME[5]="packman"
REPOSITE[5]="${PACKMAN}"
PRIORITY[5]="90" # replace official packages

REPOS=${#REPONAME[*]}
echo $REPOS

configure_repo() {
    rm -rf /etc/zypp/repos.d/*
    for (( REPO=1; REPO<=${REPOS}; REPO++ ))
    do
        echo "Configuring repository : ${REPONAME[${REPO}]}"
        zypper ar -p ${PRIORITY[${REPO}]} ${REPOSITE[${REPO}]} ${REPONAME[${REPO}]} >&2
        if [ ${?} -ne 0 ]
        then
            echo "Could not add repository : ${REPONAME[${REPO}]}"
            exit 1
        fi
    done
    echo "Configuring repository : vsCode"
    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\
        \ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/zypp/repos.d/vscode.repo
    if [ "${?}" -ne 0 ]
    then
        echo "Could not add repository: vsCode" >&2
        exit 1
    fi
    # Refresh metadata and import GPG keys.
    echo 'Refreshing repository information.'
    echo 'This might take a moment...'
    zypper --gpg-auto-import-keys refresh 2>&1
    if [ "${?}" -ne 0 ]
    then
        echo "Could not refresh repository information." >&2
        exit 1
    fi
    # Update and replace some vanilla packages with enhanced versions.
    echo 'Updating system with enhanced packages.'
    echo "This might also take a moment..."
    zypper --non-interactive update --allow-vendor-change --auto-agree-with-licenses 2>&1
    if [ "${?}" -ne 0 ]
    then
        echo "Could not perform system update." >&2
        exit 1
    fi
    echo 'All repositories configured successfully.'
}

configure_repo
