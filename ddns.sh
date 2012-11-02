#!/usr/bin/env bash

. /etc/ddns/config

UPDATE_URL='http://freedns.afraid.org/dynamic/update.php?'
WGET='wget --timeout=10 -qO -'

IP=`$WGET http://checkip.dyndns.com | grep -oE '([0-9]+\.){3}[0-9]+'`

if [ ! ${LOG_FILE} ]; then
	LOG_FILE=/tmp/ddns.log
fi

function log() {
	echo "`date`: $1" >> $LOG_FILE
	logger -t ddns $1
}

if [ -z $IP ]; then
	log 'No result from checkip.dyndns.com: aborting.'
	exit 1
fi

if [ ! ${CACHE_FILE} ]; then
	CACHE_FILE=/tmp/ddns.cache
	log "set default cache file: $CACHE_FILE"
fi

if [ ! ${HASH_LIST} ]; then
	HASH_LIST=()
	log 'set empty hash list'
fi

function update() {
	for HASH in ${HASH_LIST[*]}; do
		`$WGET $UPDATE_URL$HASH &> /dev/null`
		log "updated: $HASH"
	done
	echo $IP > $CACHE_FILE
}

function update_required() {
	if [ $IP = `cat $CACHE_FILE` ]; then
		return 0
	else
		return 1
	fi
}

if [ ! -f $CACHE_FILE ]; then
	log 'Cache file nonexistent.'
	update
	exit 0
fi

log "$IP == `cat $CACHE_FILE`?"
if [ `update_required` $? -gt 0 ]; then
	log 'Update required.'
	update
else
	log "No update required."
fi
