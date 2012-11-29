#!/usr/bin/env bash

CONFIG='/etc/afraid-ddns/conf'
UPDATE_URL='https://freedns.afraid.org/dynamic/update.php?'
CHECK_URL='http://checkip.dyndns.com'

CACHE_FILE='/etc/afraid-ddns/cache'
LOG_FILE='/tmp/ddns.log'

while getopts "c:" opt; do
   case $opt in
      c)
         CONFIG=$OPTARG
      ;;
      ?)
         echo 'invalid usage'
         exit 1
      ;;
   esac
done

if [ -f $CONFIG ]; then
   . $CONFIG
else
   echo 'Config file not found/specified.' 1>&2
   exit 1
fi

if [ ! ${HASH_LIST} ]; then
   log 'No hosts in $HASH_LIST, exiting...'
   exit 1
fi

function log() {
   echo "`date`: $1" >> $LOG_FILE
   logger -t ddns $1
}

if [ -n `which wget | grep -E '.* not found'` ]; then
   WGET="`which wget` --timeout=10 -qO -"
   IP=`$WGET $CHECK_URL | grep -oE '([0-9]+\.){3}[0-9]+'`
else
   log 'wget not found in $PATH'
fi

if [ -z $IP ]; then
   log 'No result from checkip.dyndns.com: aborting.'
   exit 1
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

if [ ! -f $CACHE_FILE ] || [ -z `cat $CACHE_FILE` ]; then
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
