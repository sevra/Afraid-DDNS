## Afraid-DDNS
This is a simple Bash script that updates __Afraid.org__ DDNS hosts with your external IP.

### Requirements
* wget
* grep

### Config
`ddns.sh` looks for a config file located at `/etc/ddns/config`. The config file may contain the following variables:
	
* `$CACHE_FILE` : The path to which your external IP should be cached.
	- Defaults to *'/tmp/ddns.cache'*.
* `$LOG_FILE` : The path to which log messages should be sent.
	- Defaults to *'/tmp/ddns.log'*.
* `$HASH_LIST` : An array of hashes to update.

#### Hashes
Hashes can be obtained for a host by going to __Afraid.org__, navigating to you host list and clicking on __Direct URL__. Copy the portion of the URL after the `?` and add it to your `$HASH_LIST`.

### Usage
Executing `ddns.sh` will only update __Afraid.org__ with your external IP if necessary unless the `$CACHE_FILE` is non-existent in which case an update is forced and a `$CACHE_FILE` is created.

### Example
Add a cron job that calls the `ddns.sh` at your desired intervals. This is an example of what a crontab may look like:

	*/10 * * * *   /bin/bash -c '/usr/sbin/ddns.sh'
	0 0 */3 * *    /bin/bash -c 'rm /etc/ddns/cache & /usr/sbin/ddns.sh'

The first job checks your external IP every 10 minutes and updates if necessary.

The second job forces an update every three days.
