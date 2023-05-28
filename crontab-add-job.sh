#write out current crontab
crontab -l > temp-crontab

#echo new cron into cron file
echo "00 09 * * 1-5 echo hello" >> temp-crontab

#install new cron file
crontab temp-crontab

rm temp-crontab
