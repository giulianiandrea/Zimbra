DOMAIN=$(hostname -d)
zmprov cdl services@$DOMAIN
zmprov adlm services@$DOMAIN 'backup.hw@pentaservice.it'