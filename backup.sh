#!/bin/bash
# ***** BEGIN LICENSE BLOCK *****
# Version: MPL 2.0
#
# The contents of this file are subject to the Mozilla Public License Version
# 2.0 (the "License"); you may not use this file except in compliance with
# the License. You may obtain a copy of the License at
# http://www.mozilla.org/MPL/
#
# Software distributed under the License is distributed on an "AS IS" basis,
# WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
# for the specific language governing rights and limitations under the
# License.
#
# The Initial Developer of the Original Code is
# Etienne Rached
# http://www.tech-and-dev.com/2013/10/backup-godaddy-files-and-databases.html
# Portions created by the Initial Developer are Copyright (C) 2013
# the Initial Developer. All Rights Reserved.
#
# Contributor(s):
# Don Ellington 2017-04-08
# Added 
#
# ***** END LICENSE BLOCK *****

###################### Configuration ######################

#Store the backups in the following directory
#Note: Always backup your data outside of your public_html or html directory. This will ensure your backup files won't be accessed publicly from a browser.
#Example:
#backupDirectory="backup/mybackupfiles"
backupDirectory="backups"

##### Database Configuration #####
#Databases Information
#You can add as much databases information as you wish
#The database information should be incremental and follow the below format:
#############
#dbHost[0]=''
#dbName[0]=''
#dbUser[0]=''
#dbPass[0]=''
#
#dbHost[1]=''
#dbName[1]=''
#dbUser[1]=''
#dbPass[1]=''
#
#dbHost[2]=''
#dbName[2]=''
#dbUser[2]=''
#dbPass[2]=''
#############
#
#
#Example:
##################################
#dbHost[0]='localhost'
#dbName[0]='database1'
#dbUser[0]='user'
#dbPass[0]='myhardtoguesspassword'
#
#dbHost[1]='db.domain.com'
#dbName[1]='database1'
#dbUser[1]='myusername'
#dbPass[1]='ghjkkjh2678(27'
##################################

dbHost[0]='localhost' 
dbName[0]='stsMagentoStoreDB' 
dbUser[0]='stsStoreManager'
dbPass[0]='I8@homeB4'

dbHost[1]='localhost' 
dbName[1]='phppos'
dbUser[1]='stsStoreManager'
dbPass[1]='I8@homeB4'

#Compress Databases (On=1 / Off=0)
compressDatabases=1

##### Files Configuration #####
#$HOME should by default hold the path of your user home directory, in case it doesn't, or if you want to backup a specific directory, you can define it below:
#HOME="/var/www"
HOME="/home/peepsnetdon1us"

#Directory (and its subdirectories) to backup. By Default, the godaddy public directory is called "html" or "public_html"
filesPath='public_html'

#Directories to exclude so they are not backed up(relative to backup path above)
#excludeDirs[0]='junk.html'
#excludeDirs[1]='logs/*'
#excludeDirs[2]='cgi-bin/*'

excludeDirs[0]='sts/var/cache/*'
excludeDirs[1]='sts/var/session/*'

#Archive files as Zip(0) or Tar(1)
ZipOrTar=1

#Compress Files in Archive? (On=1, Off=0)
#Note: Godaddy scripts are usually interrupted after a specific time. Compressing/deflating the files will take more time to complete. Use zero if you have a huge website and the script is always interrupted.
compressFiles=1

#How many days should the backup remain locally before it's deleted. Set to 0 to disable it.
deleteLocalOldBackupsAfter=30

##### FTP Configuration #####
#Note: Using FTP is not secure, use it at your own risk. Your password will be stored in this file in plain text, and can be read by a simple ps command upon execution by others.
#Enable FTP Transfer (Yes=1 / No=0)
enableFtpTransfer=0

#Delete local files after uploading them to FTP (Yes=1 / No=0). This will only work if enableFtpTransfer is set to 1
deleteFilesAfterTransfer=0

#How many days should the backup remain in the ftp before it's deleted. Set to 0 to disable it. This will only work if enableFtpTransfer is set to 1
deleteOldBackupsAfter=30

#FTP Host - Fill the FTP details below. This is only required if enableFtpTransfer is set to 1
FtpHost=''

#FTP Port
FtpPort=''

#FTP User
FtpUser=''

#FTP Password
FtpPass=''

#FTP Path
FtpPath='/'

################# End Of Configuration ###################

################# Bash Color and Format Codes ###################

parm="*"
err="####"
att="+++"
if [ -t 1 ]; then
	BOLD=$(tput bold)
	STOT=$(tput smso)
	UNDR=$(tput smul)
	REV=$(tput rev)
	RED=$(tput setaf 1)
	GREEN=$(tput setaf 2)
	YELLOW=$(tput setaf 3)
	MAGENTA=$(tput setaf 5)
	WHITE=$(tput setaf 7)
	NORM=$(tput sgr0)
	NORMAL=$(tput sgr0)

else
	BOLD=" "
	STOT=" "
	UNDR=" "
	REV=" "
	RED=" "
	GREEN=" "
	YELLOW=" "
	MAGENTA=" "
	WHITE=" "
	NORM=" "
	NORMAL=" "

fi

################# Bash Color and Format Codes ###################

################# Script Execution ###################

###!!! Edit at your own risk !!!###
echo -e "${BOLD}######################################################################"
echo -e "                    ${BOLD}${UNDR}BEGINNING WEBSITE BACKUP SCRIPT${NORM}"
echo -e "${BOLD}######################################################################"
echo ""
echo -e "${BOLD}Backup location preparation...${NORM}"
echo -e "Generating backup date."
#Store Current Date
Date=`date '+%Y-%m-%d_%H-%M-%S'`
echo -e "Date for backup will be: ${GREEN}$Date${NORM}"

#Create Final Backup Directory
thisBackupDirectory="$backupDirectory/$Date"

#Check if backup directory exist, otherwise create it
echo -e "Preparing backup location."
if [ ! -d "$HOME/$thisBackupDirectory" ]
then
    mkdir -p $HOME/$thisBackupDirectory/
    echo -e "Backup location created: ${GREEN}$HOME/$thisBackupDirectory${NORM}"
fi

##### Backup Databases #####
echo ""
echo -e "${BOLD}Begining backup of mySQL Databases:${NORM}"
for i in ${!dbHost[@]}
do
	echo -e "Backing up ${GREEN}${dbName[$i]}${NORM}"
  if [ $compressDatabases -eq 1 ]
    then
      filename[i]="$HOME/$thisBackupDirectory/${dbName[$i]}_$Date.sql.gz"
      mysqldump -h ${dbHost[$i]} -u ${dbUser[$i]} -p${dbPass[$i]} ${dbName[$i]} | gzip > ${filename[i]}
    else
      filename[i]="$HOME/$thisBackupDirectory/${dbName[$i]}_$Date.sql"
      mysqldump -h ${dbHost[$i]} -u ${dbUser[$i]} -p${dbPass[$i]} ${dbName[$i]} > ${filename[i]}
  fi
  echo -e "Backup of $dbName[$1] complete."
done
##### END OF Backup Databases #####

##### Backup Files #####
echo ""
echo -e "${BOLD}Begining backup of files at $HOME/$filesPath${NORM}"
echo -e "Moving into backup path: $HOME/$filesPath"
cd $HOME/$filesPath

#Zip
if [ $ZipOrTar -eq 0 ]
then
	echo -e "Building Zip command."
	for x in ${!excludeDirs[@]}
	do
		excludeVar+=" ${excludeDirs[$x]}\*"
	done
	excludeVar=" -x $excludeVar"
    if [ $compressFiles -eq 0 ]
    then
        filesname="$HOME/$thisBackupDirectory/files_$Date.zip"
		echo "Running Zip Command:"
		echo "zip -r -0 $filesname * $excludeVar "
#		read -p "Press [Enter] key to start backup..."
        zip -r -0 $filesname * $excludeVar
    else
        filesname="$HOME/$thisBackupDirectory/files_$Date.zip"
		echo "Running Zip Command with compression:"
		echo "zip -r -9 $filesname * $excludeVar "
#		read -p "Press [Enter] key to start backup..."
		zip -r -9 $filesname * $excludeVar
    fi
fi

#Tar
if [ $ZipOrTar -eq 1 ]
then
	echo -e "Building Tar command."
	for x in ${!excludeDirs[@]}
	do
		excludeVar+=" --exclude=./${excludeDirs[$x]}"
	done
    if [ $compressFiles -eq 0 ]
    then
        filesname="$HOME/$thisBackupDirectory/files_$Date.tar"
		echo "Running Tar Command:"
		echo "tar $excludeVar -pcf $filesname . "
#		read -p "Press [Enter] key to start backup..."
		tar $excludeVar -pcf $filesname . 
    else
        filesname="$HOME/$thisBackupDirectory/files_$Date.tar.gz"
		echo "Running Tar Command with compression:"
		echo "tar $excludeVar -pzcf $filesname . "
#		read -p "Press [Enter] key to start backup..."
		tar $excludeVar -pzcf $filesname . 
    fi
fi
echo -e "${BOLD}Backing up of files complete.${NORM}"
##### END OF Backup Files #####

######## FTP Transfer ########
##### Transfer Files #####
if [ $enableFtpTransfer -eq 1 ]
then
	echo ""
	echo -e "${BOLD}Beginning FTP File Transfer.${NORM}"
    if [ "$FtpPath" == "" ]
    then
        FtpPath="$Date"
    else
        FtpPath="$FtpPath/$Date"
    fi
	echo "Uploading backup file to: $FtpPath"
#Upload File & Database(s)
ftp -npv $FtpHost $FtpPort  << END
user $FtpUser $FtpPass
mkdir $FtpPath
cd $FtpPath
lcd $HOME/$thisBackupDirectory
prompt off
mput *
bye
END
echo "FTP Transfer Complete."
##### END OF Transfer Files #####

##### Delete Old Backups #####
    #get list of directories in ftp
    if [ $deleteOldBackupsAfter -gt 0 ]
    then
		echo "FTP Cleanup..."
		echo "Getting list of current backups"
        listing=`ftp -inp $FtpHost $FtpPort  << EOF
user $FtpUser $FtpPass
ls -1R
bye
EOF
`
        lista=( $listing )
        toDelete=""

        #loop through the list and compare
		echo "comparing backup file ages for deletion"
        for i in ${!lista[@]}
        do
            dirToDate=`cut -d "_" -f 1 <<< "${lista[i]}"`
            dateToTimestamp=`date -d "$dirToDate" +%s`
	    if ! [[ $dateToTimestamp =~ ^-?[0-9]+$ ]]
            then
                continue
            fi
            currentDateInTimestamp=`date +"%s"`
            dateDifference=$((currentDateInTimestamp-dateToTimestamp))
            dateDifferenceInDays=$(($dateDifference/3600/24))
            if [ $dateDifferenceInDays -gt $deleteOldBackupsAfter ]
            then
                toDelete="${toDelete}mdelete ${lista[i]}/*
                rmdir ${lista[i]}
                "
            fi
        done

        #delete old files
        if [ "$toDelete" != "" ]
        then
		echo "Deleting backups from FTP location"
        ftp -inpv $FtpHost $FtpPort  << EOF
user $FtpUser $FtpPass
$toDelete
bye
EOF
        fi #END OF if [ "$toDelete" != "" ]
    fi #END OF if [ $deleteOldBackupsAfter -gt 0 ]
##### END OF Delete Old Backups #####

##### Delete local files #####
    if [ $deleteFilesAfterTransfer -eq 1 ]
    then
	echo "Deleting local file: " $HOME/$thisBackupDirectory;
        rm -rf $HOME/$thisBackupDirectory
    fi #END [ $deleteFilesAfterTransfer -eq 1 ]
##### END OF Delete local files #####

fi #END [ $enableFtpTransfer -eq 1 ]
######## END OF FTP Transfer ########

##### Delete local old backups #####
#get list of directories in backup folder
echo ""
echo -e "${BOLD}Cleaning up local backups by age.${NORM}"
if [ $deleteLocalOldBackupsAfter -gt 0 ]
then
    listing=`ls -1 $HOME/$backupDirectory`
    lista=( $listing )
    toDelete=""

    #loop through the list and compare
    for i in ${!lista[@]}
    do
        dirToDate=`cut -d "_" -f 1 <<< "${lista[i]}"`
        dateToTimestamp=`date -d "$dirToDate" +%s`
        if ! [[ $dateToTimestamp =~ ^-?[0-9]+$ ]]
        then
            continue
        fi
        currentDateInTimestamp=`date +"%s"`
        dateDifference=$((currentDateInTimestamp-dateToTimestamp))
        dateDifferenceInDays=$(($dateDifference/3600/24))
        echo "$((i+1))) Backup: $HOME/$backupDirectory/${lista[i]} - Is $dateDifferenceInDays days old"
        if [ $dateDifferenceInDays -gt $deleteLocalOldBackupsAfter ]
        then
            echo "  deleting"
            rm -rf $HOME/$backupDirectory/${lista[i]}
        fi
    done
fi #END OF if [ $deleteLocalOldBackupsAfter -gt 0 ]
##### END OF Delete local old backups #####

################# END OF Script Execution ###################
