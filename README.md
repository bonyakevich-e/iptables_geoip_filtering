# iptables_geoip_filtering
Allow/block connections by geoip (iptables + ipset)

Cloned from https://habr.com/ru/companies/selectel/articles/511392/comments/#comment_21864472

Usage:

1. Clone repository 

Let's suppose workdir is /usr/scripts

mkdir  /usr/scripts

git clone https://github.com/bonyakevich-e/iptables_geoip_filtering .

1. Create ipset countries list:

ipset_create_by_country.bash countrycode [countrycode] ......

For example:

ipset_create_by_country.bash ru
 
2. Create iptables rules. For example:

iptables -I INPUT 1 -i eth0 -p tcp --dport 80 -m set --match-set ru src -j ACCEPT

iptables -I INPUT 2 -i eth0 -p tcp --dport 443 -m set --match-set ru src -j ACCEPT

Make rules persistent:

/sbin/iptables-save > /etc/sysconfig/iptables

3. Modify systemd iptables unit. If you don't do that, iptables service will fail to start :

systemctl edit iptables.service

[Service]

ExecStartPre=/usr/scripts/ipset-restore.bash

systemctl daemon-reload

4. Set systemd timers for regular ipset updating (optional)

Edit ipset-create-by-country.service line "ExecStart" if you need to change countries list (default 'ru')

Edit ipset-create-by-country.timer line "OnCalendar" if you need to change time period (default 'Weekly') 

cp ipset-create-by-country.service /etc/systemd/system

cp ipset-create-by-country.timer /etc/systemd/system 

systemctl daemon-reload

