#!/bin/bash

privoxy_logfile="/usr/local/var/log/privoxy/logfile"
tmp_folder_path="/tmp/privoxy-log-reporter-bitrise/$(date +%s)/"
request_file="${tmp_folder_path}request.txt"
regex_file="${tmp_folder_path}regexes.txt"

# Configs
echo ""
echo "========== Configs =========="
echo "logfile: ${privoxy_logfile}"
echo "privoxylog_regexes: ${privoxylog_regexes}"
if [[ -n "${fauxpas_debug_mode}" ]]; then
	echo "fauxpas_debug_mode: ${fauxpas_debug_mode}"
	echo "tmp_folder_path: ${tmp_folder_path}"
	echo "request_file: ${request_file}"
	echo "regex_file: ${regex_file}"
fi
echo "============================="
echo ""

mkdir -p ${tmp_folder_path}
touch ${request_file}
touch ${regex_file}
touch filtered_data.txt

if [[ "${fauxpas_debug_mode}" = true ]]; then
	# set -e
	set -x
fi

grep -E "Request: (.*)+" ${privoxy_logfile}  > ${request_file}
echo ${privoxylog_regexes} > ${regex_file}
grep -f ${regex_file} ${request_file} > filtered_data.txt

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
	cat ${regex_file}
	echo "🔥🔥🔥🔥🔥	request.txt	🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
	cat ${request_file}
	echo "🔥🔥🔥🔥🔥	filtered_data.txt	🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
	cat filtered_data.txt
fi

# exporting filtered data
export PRIVOXYLOG_FILTERED_DATA="$PWD/filtered_data.txt"
envman add --key PRIVOXYLOG_FILTERED_DATA --value "$PWD/filtered_data.txt"
echo ""
echo "========== Outputs =========="
echo "PRIVOXYLOG_FILTERED_DATA: ${PRIVOXYLOG_FILTERED_DATA}"
echo "============================="
echo ""

if [[ "${fauxpas_debug_mode}" = true ]]; then
	ps aux | grep privoxy | grep -v grep
fi

# killing privoxy
privoxy_pid=$(ps aux | grep privoxy | grep -v grep | awk '{print $2}')
echo "privoxy_pid: ${privoxy_pid}"
kill -9 ${privoxy_pid}
killall -KILL privoxy
killall -KILL privoxy
killall -KILL privoxy

# verifing that privoxy is properly killed
privoxy_state=1
is_privoxy_working=$(ps aux | grep privoxy | grep -v grep | wc -l | awk '{print $1}')
if [[ "$is_privoxy_working" -eq 0 ]]; then
	privoxy_state=0
fi

rm /usr/local/var/log/privoxy/logfile

# if data have been grep and privoxy is killed everything is a success
if [[ "$grep_state" -eq 0 && "$is_privoxy_working" -eq 0 ]]; then
	exit 0
fi

exit 1
