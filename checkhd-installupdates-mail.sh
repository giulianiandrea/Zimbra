#! /bin/sh

###########################################################################################################################################
######################################## Script realizzato da Andrea Giuliani - PentaService S.p.A ########################################
###########################################################################################################################################

#Path dello script e dove verranno salvati i file disco.txt e list-updates.txt
PATHSCRIPT=/home
#Mittente
MAILFROM="admin@pentaservice.ga"
#Destinatario
MAILTO="backup.hw@pentaservice.it"
#Limite spazio disco oltre al quale arriverà la mail di warning
ALERT=80
# SENDMAILPATHSCRIPT - Centos senza Zimbra è /usr/sbin/sendmail - SENDMAILPATHSCRIPT Centos con Zimbra è /opt/zimbra/common/sbin/sendmail
SENDMAILPATHSCRIPT=/opt/zimbra/common/sbin/sendmail
# Riavvio automatico dopo installazione aggiornamenti
RIAVVIO=SI

UPDATES=$(yum check-update --quiet | grep -v "^$")
UPDATES_COUNT=$(echo "$UPDATES" | wc -l)
#Alcune volte il sistema rileva ogni giorno un aggiornamento. In questo caso togliere # nella istruzione sottostante
UPDATES_COUNT=$(($UPDATES_COUNT-1))
NFS=$(df -H | grep -vE '^Filesystem|File|tmpfs|cdrom|Dispon.' | wc -l)
CONTATORE=0
df -H | grep -vE '^Filesystem|File|tmpfs|cdrom|Dispon.' > $PATHSCRIPT/disco.txt
if [[ $UPDATES_COUNT -gt 0 ]]; then
	yum -y update
	yum history info > $PATHSCRIPT/install-updates.txt
	awk 'BEGIN { 
        x = 0;
        print "<table border="1">"
    }
    {
        if (NF == 1){
            print "<tr><td colspan="2">"$i"</td>";
            print "</tr>"
        } else {
            if (x == 0){
                x++;
                print "<tr><td>"$i"</td>"
            } else {
                x = 0;
                print "<tr><td>"$i"</td>"
            }
        }
    }
    END {
        print "</table>"
    }' $PATHSCRIPT/install-updates.txt > $PATHSCRIPT/install-updates.html
	yum history > $PATHSCRIPT/history.txt
	awk 'BEGIN { 
        x = 0;
        print "<table border="1">"
    }
    {
        if (NF == 1){
            print "<tr><td colspan="2">"$i"</td>";
            print "</tr>"
        } else {
            if (x == 0){
                x++;
                print "<tr><td>"$i"</td></tr>"
            } else {
                x = 0;
                print "<tr><td>"$i"</td></tr>"
            }
        }
    }
    END {
        print "</table>"
    }' $PATHSCRIPT/history.txt > $PATHSCRIPT/history.html
	df -H | grep -vE '^Filesystem|File|tmpfs|cdrom|Dispon.' | awk '{ print $5 " " $1 }' | while read output;
	do
		CONTATORE=$[$CONTATORE +1]
		USEP=$(echo $output | awk '{ print $1}' | cut -d'%' -f1)
		PARTITION=$(echo $output | awk '{ print $2 }')
		if [ $USEP -ge $ALERT ]; then
			(
			echo "From: $MAILFROM"
			echo "To: $MAILTO"
			echo "Content-type: text/html"
			echo "Subject: Spazio in esaurimento in $PARTITION ($USEP%) su $(hostname -f) e Aggiornamenti installati"
			echo La partizione "<font color="red">"$PARTITION"</font>" risulta piena al "<font color="red">"$USEP%."</font>"
			echo "<br><br>"
			echo "<font color="red">Stato del disco:</font>"
			echo "<br><br>"
			awk 'BEGIN{print "<table>"} {print "<tr>";for(i=1;i<=NF;i++)print "<td>" $i"</td>";print  "</tr>"} END{print "</table>"}' $PATHSCRIPT/disco.txt
			echo "<br>"
			echo "<font color="red">"Erano presenti $UPDATES_COUNT aggiornamenti. Gli aggiornamenti sono stati installati. Risultato:"</font>"
			echo "<br><br>"
			echo $(cat $PATHSCRIPT/install-updates.html)
			echo "<br><br>"
			echo "<font color="red">"Storico aggiornamenti:"</font>"
			echo "<br><br>"
			echo $(cat $PATHSCRIPT/history.html)
			) | $SENDMAILPATHSCRIPT -i $MAILTO
			rm -f $PATHSCRIPT/install-updates.txt $PATHSCRIPT/install-updates.html $PATHSCRIPT/history.txt $PATHSCRIPT/history.html $PATHSCRIPT/disco.txt
			if [[ $RIAVVIO == SI ]] ; then
				reboot
			fi
		else
			if [[ $CONTATORE == $NFS ]] ; then
				(
				echo "From: $MAILFROM"
				echo "To: $MAILTO"
				echo "Content-type: text/html"
				echo "Subject: Aggiornamenti installati su $(hostname -f)"
				echo Stato del disco:
				echo "<br><br>"
				awk 'BEGIN{print "<table>"} {print "<tr>";for(i=1;i<=NF;i++)print "<td>" $i"</td>";print  "</tr>"} END{print "</table>"}' $PATHSCRIPT/disco.txt
				echo "<br>"
				echo "<font color="red">"Erano presenti $UPDATES_COUNT aggiornamenti. Gli aggiornamenti sono stati installati. Risultato:"</font>"
				echo "<br><br>"
				echo $(cat $PATHSCRIPT/install-updates.html)
				echo "<br><br>"
				echo "<font color="red">"Storico aggiornamenti:"</font>"
				echo "<br><br>"
				echo $(cat $PATHSCRIPT/history.html)
				) | $SENDMAILPATHSCRIPT -i $MAILTO
				rm -f $PATHSCRIPT/install-updates.txt $PATHSCRIPT/install-updates.html $PATHSCRIPT/history.txt $PATHSCRIPT/history.html $PATHSCRIPT/disco.txt
				if [[ $RIAVVIO == SI ]] ; then
					reboot
				fi
			fi
		fi
	done
else
	df -H | grep -vE '^Filesystem|File|tmpfs|cdrom|Dispon.' | awk '{ print $5 " " $1 }' | while read output;
	do
		USEP=$(echo $output | awk '{ print $1}' | cut -d'%' -f1  )
		PARTITION=$(echo $output | awk '{ print $2 }' )
		if [ $USEP -ge $ALERT ]; then
			(
			echo "From: $MAILFROM"
			echo "To: $MAILTO"
			echo "Content-type: text/html"
			echo "Subject: Spazio in esaurimento in $PARTITION ($USEP%) su $(hostname -f)"
			echo La partizione "<font color="red">"$PARTITION"</font>" risulta piena al "<font color="red">"$USEP%"</font>"
			echo "<br><br>"
			echo "Stato del disco:"
			echo "<br><br>"
			awk 'BEGIN{print "<table>"} {print "<tr>";for(i=1;i<=NF;i++)print "<td>" $i"</td>";print  "</tr>"} END{print "</table>"}' $PATHSCRIPT/disco.txt
			echo "<br><br>"
			echo Non sono disponibili aggiornamenti.
			) | $SENDMAILPATHSCRIPT -i $MAILTO
		fi
	done
fi
rm -f $PATHSCRIPT/list-updates.txt $PATHSCRIPT/install-updates.html $PATHSCRIPT/updates.txt $PATHSCRIPT/history.html $PATHSCRIPT/disco.txt
