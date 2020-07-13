DOMAIN=$(hostname -d)
zmprov cdl services@$DOMAIN
zmprov adlm services@$DOMAIN backup.hw@pentaservice.it
zmprov adlm services@$DOMAIN andrea.giuliani@pentaservice.it
zmprov adlm services@$DOMAIN stefano.tozzi@pentaservice.it
zxsuite backup setProperty ZxBackup_DestPath /zimbrabackup/
zxsuite backup setProperty ZxBackup_DatadRetentionDays 180
zxsuite core setProperty ZxCore_NTMail services@$DOMAIN
zxsuite core setProperty ZxCore_NTLevel 2
zxsuite core setProperty ZxCore_LicenseWarningRecipients services@$DOMAIN
zxsuite mobile setProperty ZxMobile_MaxGlobalVersion 16.1
#Configurazione Parametri COS
zmprov mc default zimbraPrefShowSelectionCheckbox TRUE
zmprov mc default zimbrapreflocale it
zmprov mc default zimbraMaxMailitemsPerPage 500
zmprov mc default zimbraPrefMailitemsPerPage 100
zmprov mc default zimbraPrefGroupMailBy message
zmprov mc default zimbraPrefItemsPerVirtualPage 100
zmprov mc default zimbraPrefMailPollingInterval 2m
zmprov mc default zimbraMailSignatureMaxLength 40960
zmprov mc default zimbraPrefTimeZoneId '(GMT+01.00) Amsterdam / Berlin / Bern / Rome / Stockholm / Vienna'
zmprov mc default zimbraPrefCalendarFirstDayOfWeek 1
zmprov mc default zimbraMailTrashLifetime 180
zmprov mc default zimbraMailSpamLifetime 180
zmprov mc default zimbraFeatureMobileSyncEnabled TRUE
zmprov mc default zimbraMobilePolicyMaxCalendarAgeFilter 0
zmprov mc default zimbraMobilePolicyMaxEmailAgeFilter 0
zmprov mcf zimbraMtaMaxMessageSize 52428800
#Modifica parametri
zmprov modifyConfig zimbraFileUploadMaxSize 52428800
zmprov modifyConfig zimbraImapMaxRequestSize 52428800
zmprov modifyConfig zimbraMailContentMaxSize 2428800
zmprov modifyConfig zimbraMtaMaxMessageSize 52428800
#Ottimizzazione IMAP
zmprov ms `zmhostname` zimbraImapMaxConnections 500
zmprov ms `zmhostname` zimbraImapNumThreads 500
#Technique #1 – Outright Blocking With Postscreen
zmprov mcf zimbraMtaPostscreenDnsblSites 'b.barracudacentral.org=127.0.0.2*7'
zmprov mcf zimbraMtaPostscreenDnsblAction enforce
zmprov mcf zimbraMtaPostscreenGreetAction enforce
zmprov mcf zimbraMtaPostscreenNonSmtpCommandAction drop
zmprov mcf zimbraMtaPostscreenPipeliningAction enforce
zmprov mcf zimbraMtaPostscreenDnsblTTL 5m
#Technique #2 – Outright Blocking With Postfix DNS Protocol Checks
zmprov mcf +zimbraMtaRestriction reject_non_fqdn_sender
zmprov mcf +zimbraMtaRestriction reject_unknown_sender_domain
#Technique #3 – Outright Blocking of Bad Sending Servers
zmprov mcf +zimbraMtaRestriction "reject_rbl_client b.barracudacentral.org"
zmprov mcf +zimbraMtaRestriction "reject_rbl_client psbl.surriel.com"
zmprov mcf +zimbraMtaRestriction "reject_rbl_client cbl.abuseat.org"
zmprov mcf +zimbraMtaRestriction 'reject_rhsbl_client dbl.spamhaus.org'
zmprov mcf +zimbraMtaRestriction 'reject_rhsbl_client rhsbl.sorbs.net'
zmprov mcf +zimbraMtaRestriction 'reject_rhsbl_reverse_client dbl.spamhaus.org'
zmprov mcf +zimbraMtaRestriction 'reject_rhsbl_sender rhsbl.sorbs.net'
zmprov mcf +zimbraMtaRestriction 'reject_rhsbl_sender dbl.spamhaus.org'
#Technique #5 – Outright Blocking of Certain Attachments
zmprov mcf +zimbraMtaBlockedExtension asd
zmprov mcf +zimbraMtaBlockedExtension bat
zmprov mcf +zimbraMtaBlockedExtension cab
zmprov mcf +zimbraMtaBlockedExtension chm
zmprov mcf +zimbraMtaBlockedExtension cmd
zmprov mcf +zimbraMtaBlockedExtension com
zmprov mcf +zimbraMtaBlockedExtension dll
zmprov mcf +zimbraMtaBlockedExtension do
zmprov mcf +zimbraMtaBlockedExtension exe
zmprov mcf +zimbraMtaBlockedExtension hlp
zmprov mcf +zimbraMtaBlockedExtension hta
zmprov mcf +zimbraMtaBlockedExtension js
zmprov mcf +zimbraMtaBlockedExtension jse
zmprov mcf +zimbraMtaBlockedExtension lnk
zmprov mcf +zimbraMtaBlockedExtension ocx
zmprov mcf +zimbraMtaBlockedExtension pif
zmprov mcf +zimbraMtaBlockedExtension reg
zmprov mcf +zimbraMtaBlockedExtension scr
zmprov mcf +zimbraMtaBlockedExtension shb
zmprov mcf +zimbraMtaBlockedExtension shm
zmprov mcf +zimbraMtaBlockedExtension shs
zmprov mcf +zimbraMtaBlockedExtension vbe
zmprov mcf +zimbraMtaBlockedExtension vbs
zmprov mcf +zimbraMtaBlockedExtension vbx
zmprov mcf +zimbraMtaBlockedExtension vxd
zmprov mcf +zimbraMtaBlockedExtension wsf
zmprov mcf +zimbraMtaBlockedExtension wsh
zmprov mcf +zimbraMtaBlockedExtension xl
zmprov mcf +zimbraMtaBlockedExtensionWarnAdmin TRUE
zmprov mcf +zimbraMtaBlockedExtensionWarnRecipient TRUE
zmprov mcf zimbraVirusBlockEncryptedArchive FALSE
#Technique #6 – Email Content Checking
zmprov mcf zimbraSpamKillPercent 75
zmprov mcf zimbraSpamTagPercent 20
zmprov mcf zimbraSpamSubjectTag '[ _SPAM_ ]'
#AmavisLogLevel
zmprov mcf zimbraAmavisLogLevel 2
#Antispam
zmlocalconfig -e antispam_enable_rule_updates=true
zmlocalconfig -e antispam_enable_restarts=true
zmlocalconfig -e antispam_enable_rule_compilation=true
#Antivirus
zmprov mcf zimbraVirusDefinitionsUpdateFrequency 2h
#Riavvio servizi
postfix reload
zmmailboxdctl restart
zmcontrol restart
