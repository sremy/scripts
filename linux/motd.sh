#!/bin/bash
# Welcome banner displaying info about system, load, processes, ip addresses

col_warn="\033[1;31m"
col_bord='\033[1;36m'
col_value="\033[1;32m"
col_key="\033[0;37m"
col_yellow="\033[0;93m"

cc="\x1b[1;36m"
yy="\x1b[1;93m"
gg="\x1b[0;37m"

# Hostname
HOSTNAME=$(hostname)

# Uptime
#UPTIME=$(uptime -p | cut -b 4-)
#UPTIME=$(awk '{print int($1/86400)" days "int($1%86400/3600)"h "int(($1%3600)/60)"min "int($1%60)"s"}' /proc/uptime)
UPTIME=$(awk '{if ($1>=86400) {printf int($1/86400)" days "} print int($1%86400/3600)" h "int(($1%3600)/60)" min "int($1%60)" s"}' /proc/uptime)

#LOAD_AVG=$(cut -d' ' /proc/loadavg -f1-3)
LOAD_AVG=$(awk -F' ' '{if($1 > 4.0) {col="'$col_warn'"} else if($1 > 1.0) {col="'$col_yellow'"} else {col="'$col_value'"} {print col,$1, $2, $3"\033[0m"}}' /proc/loadavg)

# IP Address (list all ip addresses)
#IP_ADDRESS=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]+\.){3}[0-9]+).*/\2/p' |  sed ':next;N;$!bnext;s/\n/, /g')
# ifconfig | sed -En 's/^([^ ]+):.*/\1/p; s/.*inet (addr:)?(([0-9]+\.){3}[0-9]+).*/\2/p'
# ifconfig | sed -En 's/^([^ ]+):.*/\1/p; t label; b end; :label N; s/.*inet (addr:)?(([0-9]+\.){3}[0-9]+).*/\2/p; :end'
#IP_ADDRESS=$(ifconfig | sed -En 's/^([^ ]+):.*/\1/; t label; b end; :label N; s/(.*)\n.*inet (addr:)?(([0-9]+\.){3}[0-9]+).*/\1: \3   /p; :end' | tr -d "\n" )
#IP_ADDRESS=$(ifconfig | sed -En 's/^lo:/ /;t; s/^([^ ]+):.*/\1/; T; N; s/(.*)\n.*inet (addr:)?(([0-9]+\.){3}[0-9]+).*/\1: \3   /p' | tr -d "\n")
##IP_ADDRESS=$(ip a | sed -En 's/^[0-9]+: lo: .*//;t; s/^[0-9]+: ([^ ]+): .*/\1/; T; N;N; s/([^ ]+)\n.*inet (([0-9]+\.){3}[0-9]+).*/\1: \2   /p'| tr -d "\n") # KO if eth without ip
IP_ADDRESS=$(ifconfig | sed -En 's/^lo:/ /;t; s/^([^ :]+(:[^ :]+)?)(: | ).*/\1/; T; N; s/(.*)\n.*inet (addr:)?(([0-9]+\.){3}[0-9]+).*/\1: \3   /p' | tr -d "\n") # OK
# OK, but slow: loop over /sys/ filesystem, call ip a show for each device
#IP_ADDRESS=$(
#for DEV in /sys/class/net/*; do
#    if [ "${DEV##*/}" = "lo" ]; then continue; fi;
#    echo -n "${DEV##*/}: "$(ip -f inet addr show ${DEV##*/} | sed -rn '/inet/s:\s+inet\s+([0-9.]+).*:\1:gp' | sed ':next;N;$!bnext;s/\n/, /g') "  ";
#done
#)

# Distribution & Kernel
#DISTRIBUTION=$(if [ -f /etc/debian_version ]; then echo "Debian $(cat /etc/debian_version)"; elif [ -f /etc/redhat-release ]; then cat /etc/redhat-release; fi)
DISTRIBUTION=$(if [ -f /etc/os-release ]; then grep PRETTY /etc/os-release | cut -d'=' -f 2- ; elif [ -f /etc/redhat-release ]; then cat /etc/redhat-release; fi)
# Kernel release
KERNEL=$(echo $(uname -r))
# CPU Info
#CPU_INFO=$( echo $(grep processor /proc/cpuinfo | wc -l) "x" $(grep 'model name' /proc/cpuinfo | uniq | cut -d':' -f2) )
CPU_INFO=$( echo $(grep "^processor" /proc/cpuinfo | wc -l) "x" $(awk -F: '$1 ~ "^model name" {print $2; exit}' /proc/cpuinfo))
#CPU_INFO=$(echo $(lscpu | grep '^CPU(s)' | cut -d':' -f2 ) "x" $(lscpu | grep 'Model name' | cut -d':' -f2))
HT=$(lscpu | grep '^Thread(s) per core' | awk -F":" '$2 > 1 {print "HT"}')
# Total Memory
MEMORY_TOTAL=$(echo $(free -m | grep Mem: | awk -F " " '{print $2/1024}') GB)
# Memory Used procps-ng (Mem:       total        used        free      shared  buff/cache   available)
MEMORY_USED=$(echo $(free -m | grep Mem: | awk -F " " '{print $3/1024}') GB)
# Disk left
DISK_LEFT=$(df -Ph | grep " /mnt" | awk '{ sub(/%/, "", $5); if ($5.0 > 85) {alert="'$col_warn'"} else {alert="'$col_value'"} {print alert $6, $4, (100-$5)"%\033[0m"}}' | sed ':next;N;$!bnext;s/\n/   /g')

# Process count
PROCCOUNT=$(ps -A --no-headers | wc -l)
PROCCOUNT=$(( $PROCCOUNT - 4 )) # Minus: $() + bash motd.h + ps + wc


#bord='\xE2\x94\x82' # echo -ne '\u2502'
hb="\xE2\x94\x80" # \u2500
vb="\xE2\x94\x82" # \u2502
cornerul="\xE2\x94\x8C" # \u250c
cornerbl="\xE2\x94\x94" # \u2514
intersec="\xE2\x94\x9C" # \u251c

NGINX_RAW=$(ps h -o pid,pcpu,pmem,rss,args -C nginx k -pcpu | sed 's/nginx: \([^ ]*\) process.*/\1/g')
#JAVA_RAW=$(ps h -o pid,pcpu,pmem,rss,args -C java k -pcpu | sed 's/\/home.*catalina.base=\([^ ]*\).*/\1/g')
#MONGO_RAW=$(ps h -o pid,pcpu,pmem,rss,args -C mongod k -pcpu )

horbar="$hb$hb$hb$hb$hb$hb$hb$hb$hb$hb$hb$hb$hb$hb$hb$hb$hb$hb$hb$hb$hb"
shorthorbar="$hb$hb$hb$hb$hb$hb$hb$hb"

function formater() {
	if [[ -n "$1" ]]; then
		echo -e "$1" | sed "s/^/$cc$vb $yy/g"
	fi
}

echo -e "
${col_bord}$cornerul$horbar: ${col_key}System Data${col_bord} :$horbar
${col_bord}$vb ${col_key}Hostname ${col_bord}= ${col_value}$HOSTNAME
${col_bord}$vb ${col_key}Load ${col_bord}= ${col_value}$LOAD_AVG
${col_bord}$vb ${col_key}IP ${col_bord}= ${col_value}$IP_ADDRESS
${col_bord}$vb ${col_key}Kernel ${col_bord}= ${col_value}$KERNEL  $DISTRIBUTION
${col_bord}$vb ${col_key}Uptime ${col_bord}= ${col_value}$UPTIME
${col_bord}$vb ${col_key}CPU Info ${col_bord}= ${col_value}$CPU_INFO $HT
${col_bord}$vb ${col_key}Memory Used ${col_bord}= ${col_value}$MEMORY_USED / $MEMORY_TOTAL
${col_bord}$vb ${col_key}Disk left ${col_bord}= ${col_value}$DISK_LEFT
${col_bord}$intersec$horbar$hb: ${col_key}Processes${col_bord} :$horbar$hb
${col_bord}$vb ${col_key}Total Processes count ${col_bord}= ${col_value}$PROCCOUNT"
formater "$NGINX_RAW"
formater "$MONGO_RAW"
formater "$JAVA_RAW"
echo -e "${col_bord}$cornerbl$horbar$horbar$shorthorbar$hb$hb$hb$hb$hb$hb$hb\033[0m"
