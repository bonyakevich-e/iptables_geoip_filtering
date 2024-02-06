#!/usr/bin/env bash
# Description:  Uses IPSET to create lists of ipddresses by countries. Then these lists can be used for creating iptables rules. 
#		For example, 
#		iptables -I INPUT 1 -i eth0 -p tcp --dport 80 -m set --match-set ru src -j ACCEPT
# Syntax:       ipset-create-by-country.bash countrycode [countrycode] ......
#               Use the standard locale country codes to get the proper IP list. eg.
#               ipset-create-by-country.bash cn ru ro
#               Will create tables that block all requests from China, Russia and Romania
# Note:         To get a sorted list of the inserted IPSet IPs for example China list(cn) run the command:
#               ipset list cn | sort -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4
# #############################################################################
# Defining some defaults
tempdir="/tmp"
sourceURL="http://www.ipdeny.com/ipblocks/data/countries/"
#
# Verifying that the program 'ipset' is installed
if ! (rpm -qa | grep 'ipset' &>/dev/null); then
    echo "ERROR: 'ipset' package is not installed and required."
    echo "Please install it with the command 'yum install ipset' and start this script again"
    exit 1
fi
[ -e /sbin/ipset ] && ipset="/sbin/ipset" || ipset="/usr/sbin/ipset"
#
# Verifying the number of arguments
if [ $# -lt 1 ]; then
    echo "ERROR: wrong number of arguments. Must be at least one."
    echo "ipset-create-by-country.bash countrycode [countrycode] ......"
    echo "Use the standard locale country codes to get the proper IP list. eg."
    echo "ipset-create-by-country.bash cn ru ro"
    exit 2
fi
#
# Now load the rules for dowloading ip list of each given countries and insert them into IPSet tables
for country; do
    # Read each line of the list and create the IPSet rules
    # Making sure only the valid country codes and lists are loaded
    if wget -q -P $tempdir ${sourceURL}${country}.zone; then
        # Destroy the IPSet list if it exists
        $ipset flush $country &>/dev/null
        # Create the IPSet list name
        echo "Creating and filling the IPSet country list: $country"
        $ipset create $country hash:net &>/dev/null
        (for IP in $(cat $tempdir/${country}.zone); do
            $ipset add $country $IP -exist && echo "OK" || echo "FAILED"
        done) >$tempdir/IPSet-rules.${country}.txt
	# Save ipset rules to file for restoring after system boot
	$ipset save -file /etc/sysconfig/ipset-lists.conf
        # Delete the temporary downloaded counties IP lists
        rm $tempdir/${country}.zone
    else
        echo "Argument $country is invalid or not available as country IP list. Skipping"
    fi
done
# Dispaly the number of IP ranges entered in the IPset lists
echo "--------------------------------------"
for country; do
    echo "Number of ip ranges entered in IPset list '$country' : $($ipset list $country | wc -l)"
done
echo "======================================"
#
#eof
