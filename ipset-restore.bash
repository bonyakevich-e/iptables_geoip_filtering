#!/bin/bash
## Данный скрипт восстанавливает правила ipset. Запускать его нужно перед запуском iptables, иначе последний не запуститься (будет ругаться что нет правила ipset)
ipset destroy
ipset restore -file /etc/sysconfig/ipset-lists.conf

