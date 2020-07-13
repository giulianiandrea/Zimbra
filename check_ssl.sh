#!/bin/sh
date > /home/script/check_ssl.log
/usr/local/bin/certbot-auto renew --post-hook "/usr/local/bin/certbot_zimbra.sh -r -d $(/opt/zimbra/bin/zmhostname)" >> /home/script/check_ssl.log
su - zimbra -c "zmlocalconfig -e ldap_starttls_required=false" >> /home/script/check_ssl.log
su - zimbra -c "zmlocalconfig -e ldap_starttls_supported=0" >> /home/script/check_ssl.log
su - zimbra -c "zmcontrol restart" >> /home/script/check_ssl.log
echo 1 >/tmp/ldap_variable
certbot_zimbra.sh -n < /tmp/ldap_variable >> /home/script/check_ssl.log
su - zimbra -c "zmlocalconfig -e ldap_starttls_required=true" >> /home/script/check_ssl.log
su - zimbra -c "zmlocalconfig -e ldap_starttls_supported=1" >> /home/script/check_ssl.log
su - zimbra -c "zmcontrol restart" >> /home/script/check_ssl.log
date >> /home/script/check_ssl.log
