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
else
	echo "No request found in the logfile."
fi

if [[ "${fauxpas_debug_mode}" = true ]]; then
	echo "grep_state: ${grep_state}"
	echo "nb_line: ${nb_line}"
	echo "🔥🔥🔥🔥🔥	privoxy_logfile	🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
	cat ${privoxy_logfile}
	echo "🔥🔥🔥🔥🔥	regexes.txt	🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
	cat regexes.txt
	echo "🔥🔥🔥🔥🔥	request.txt	🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
	cat request.txt
	echo "🔥🔥🔥🔥🔥	filtered_data.txt	🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
	cat filtered_data.txt
fi

# exporting filtered data
export PRIVOXYLOG_FILTERED_DATA="$PWD/filtered_data.txt"
echo ""
echo "========== Outputs =========="
echo "PRIVOXYLOG_FILTERED_DATA: ${PRIVOXYLOG_FILTERED_DATA}"
echo "============================="
echo ""

# killing privoxy
privoxy_pid=$(ps aux | grep privoxy | grep -v grep | awk '{print $2}')
echo "privoxy_pid: ${privoxy_pid}"
kill -9 ${privoxy_pid}

# verifing that privoxy is properly killed
privoxy_state=1
is_privoxy_working=$(ps aux | grep privoxy | grep -v grep | wc -l | awk '{print $1}')
if [[ "$is_privoxy_working" -eq 0 ]]; then
	privoxy_state=0
fi

# if data have been grep and privoxy is killed everything is a success
if [[ "$grep_state" -eq 0 && "$is_privoxy_working" -eq 0 ]]; then
	exit 0
fi

exit 1
