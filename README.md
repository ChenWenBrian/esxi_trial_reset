# esxi_trial_reset

> This script is tested on `ESXI 6` and `ESXI 7`, other versions are not tested yet. 

Normally, the trial license for ESXI is only 60 days. But sometimes we need more time to evaluate.

This script can help developers to reset their esxi home lab trial license，in order to extend their evaluation time.

With this script, if you want more evaluation time, you don't have to
- reinstall the whole home lab
- restart your servers
- reset license every 2 month

## How to use?

Just download [esxi_trial_reset.sh](https://raw.githubusercontent.com/ChenWenBrian/esxi_trial_reset/main/esxi_trial_reset.sh) from github, and put it to your esxi server.

1. enable ssh access, login to your esxi web portal, click `Host`->`Actions`->`Services`->`Enable Secure Shell(SSH)`

2. download in ssh, use any ssh tool you like to login to your esxi shell, and excute the following commands:

```bash
# cd to any directory you want to save the script, such as /vmfs/volumes/datastore1
cd /vmfs/volumes/datastore1

# enable firewall for http
esxcli network firewall ruleset set -e true -r httpClient

# download esxi_trial_reset.sh from github
wget "https://raw.githubusercontent.com/ChenWenBrian/esxi_trial_reset/main/esxi_trial_reset.sh"  --no-check-certificate

# disable firewall again
esxcli network firewall ruleset set -e false -r httpClient
```

3. if you failed to excute the command in step 2, just copy the script manually.

### 1. Show usage

To show the help menu, just run `sh esxi_trial_reset.sh`

```bash
[root@MY-ESXI-SERVER:/vmfs/volumes/123c21f4-32b22a80-31bd-80b11c4ce689] sh esxi_trial_reset.sh
USAGE: esxi_trial_reset.sh [-a] [-r]
-a auto       add script to crontab, then check and run every 2 hours.
-r reset      check if the trial license is almost out of date, if yes, reset the trial license.

```

### 2. Check and reset the trial license

`sh esxi_trial_reset.sh -r`, this command will check if the trial license is out of date. If the expired hours is less than 72, the trial license will be reset, and you will have another 1440 hours for evaluation, that is 60 days.

```bash
[root@MY-ESXI-SERVER:/vmfs/volumes/123c21f4-32b22a80-31bd-80b11c4ce689] sh esxi_trial_reset.sh -r
Wed, 20 Mar 2024 09:00:20 +0000        Evaluation license expired hours is  1440, skip.

```


### 3. Add job to crontab

If you don't want to reset the trial license every 60 days, you can add a crontab job, run `sh esxi_trial_reset.sh -a` and then check if the job has been set to crontab.

```bash
[root@MY-ESXI-SERVER:/vmfs/volumes/123c21f4-32b22a80-31bd-80b11c4ce689] sh esxi_trial_reset.sh -a
script has been set to contab and will check and run every 2 hours.
↓ ↓ ↓ check crontab below ↓ ↓ ↓

#min hour day mon dow command
1    1    *   *   *   /sbin/tmpwatch.py
1    *    *   *   *   /sbin/auto-backup.sh ++group=host/vim/vmvisor/backup.sh
0    *    *   *   *   /usr/lib/vmware/vmksummary/log-heartbeat.py
*/5  *    *   *   *   /bin/hostd-probe.sh ++group=host/vim/vmvisor/hostd-probe/stats/sh
00   1    *   *   *   localcli storage core device purge
*/10 *    *   *   *   /bin/crx-cli gc
0 2 * * * /bin/sh /vmfs/volumes/123c21f4-32b22a80-31bd-80b11c4ce689/esxi_trial_reset.sh -r >> /vmfs/volumes/123c21f4-32b22a80-31bd-80b11c4ce689/esxi_trial_reset.log

```