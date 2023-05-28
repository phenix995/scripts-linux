#write out current crontab
crontab -l > temp-crontab

#echo new cron into cron file
echo "*/5 * * * * (bluetoothctl info 'AA:BB:CC:DD:EE:FF' | grep -q "Connected: yes" || echo -e 'connectAA\BB CCbDDeEEoFFctl)" >> temp-crontab

#install new cron file
crontab temp-crontab

rm temp-crontab
