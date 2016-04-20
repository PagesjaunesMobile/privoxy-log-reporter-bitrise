#!/bin/bash

privoxy_logfile="/usr/local/var/log/privoxy/logfile"

# Configs
echo ""
echo "========== Configs =========="
echo "logfile: ${privoxy_logfile}"
echo "privoxylog_regexes: ${privoxylog_regexes}"
if [[ -n "${fauxpas_debug_mode}" ]]; then
	echo "fauxpas_debug_mode: ${fauxpas_debug_mode}"
fi
echo "============================="
echo ""

grep -E "Request: (.*)+" ${privoxy_logfile}  > request.txt
echo ${privoxylog_regexes} > regexes.txt
grep -f regexes.txt request.txt > filtered_data.txt

nb_line=$(wc -l filtered_data.txt | awk '{print $1}')
grep_state=1

if [[ ${nb_line} > 0 ]]; then
	grep_state=0
fi

if [[ "${fauxpas_debug_mode}" = true ]]; then
	echo "grep_state: ${grep_state}"
	echo "nb_line: ${nb_line}"
	echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
	cat ${privoxy_logfile}
	echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
	cat regexes.txt
	echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
	cat request.txt
	echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
	cat filtered_data.txt
fi

export PRIVOXYLOG_FILTERED_DATA="$PWD/filtered_data.txt"

echo ""
echo "========== Outputs =========="
echo "PRIVOXYLOG_FILTERED_DATA: ${PRIVOXYLOG_FILTERED_DATA}"
echo "============================="
echo ""

ps aux | grep privoxy | grep -v grep | awk '{print "kill -9 " $2}'

privoxy_state=1
is_privoxy_working=$(ps aux | grep privoxy | grep -v grep | wc -l | awk '{print $1}')
if [[ ${is_privoxy_working} == 0 ]]; then
	privoxy_state=0
fi

if [[ ${grep_state} == 0 && ${is_privoxy_working} == 0 ]]; then
	exit 0
fi

exit 1
