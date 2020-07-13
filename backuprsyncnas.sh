#!/bin/bash

# Zimbra Backup Script v0.0001
# Requires that you have ssh-keys: https://help.ubuntu.com/community/SSHHowto#Public%20key%20authentication
# This script is intended to run from the crontab as root
# Compiled from different resources by Oliver Bross - oliver@bross.eu

# the destination log file
BACKUPLOG="/var/log/rsync-backup.log"
# the destination directory for local backups
# example : DESTLOCAL=/opt/zimbra-backup/
DESTLOCAL=/zimbrabackup
# the destination for remote backups
# example: DESTREMOTE="zimbrabackp.server.net:/Backup/zextras"
DESTREMOTE=/zimbrabackupnas
#mailling
MAIL=backup.hw@pentaservice.it
# Outputs the time the backup started, for log/tracking purposes
START=$(date +%s)
w
echo ZeXtras Remote rSync Backup > $BACKUPLOG
echo >> $BACKUPLOG
echo Time backup started : $(date +%a) $(date +%T). >> $BACKUPLOG

# Let's write few bits into the log file
echo >> $BACKUPLOG
echo Source : $DESTLOCAL >> $BACKUPLOG
echo Destination : $DESTREMOTE >> $BACKUPLOG
echo Backup Log : $BACKUPLOG >> $BACKUPLOG
echo >> $BACKUPLOG

# Am I root or not?
if [ x`whoami` != xroot ]; then
  echo Error: Must be run as root user
  exit 1
fi
 # exit 0

# backup the backup dir to remote
echo Syncing files started >> $BACKUPLOG
rsync -azrtqHK --delete $DESTLOCAL $DESTREMOTE >> $BACKUPLOG 2>&1
echo Syncing of files finished >> $BACKUPLOG
echo "(Any errors would be showsn abowe, if nothing shown, all went accoding to the plan!)" >> $BACKUPLOG
echo >> $BACKUPLOG

# Outputs the time the backup finished
FINISH=$(date +%s)
echo Time backup finished : $(date +%a) $(date +%T). >> $BACKUPLOG

# Lets see how log it all took
echo "Total Backup Time taken :  $(( ($FINISH-$START) / 60 )) minutes, $(( ($FINISH-$START) % 60 )) seconds" >> $BACKUPLOG
echo >> $BACKUPLOG

# Email some details over ... well, email the log file :-)
( echo -e "Subject: ZeXtras Remote rSync Backup results \nFrom: admin@mokador.it\nTo: $MAIL\n"; echo; cat $BACKUPLOG ) | /opt/zimbra/common/sbin/sendmail $MAIL
# end
