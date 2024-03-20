#!/bin/sh

reset() {
        mv /etc/vmware/license.cfg etc/vmware/license.cfg.$(date -I)
        cp /etc/vmware/.#license.cfg /etc/vmware/license.cfg
        /etc/init.d/vpxa restart
}

check() {
        local hours=$(vim-cmd vimsvc/license --show | grep -i hour | cut -d = -f 2)
        if [ $hours -gt 71 ]
        then
                echo $(date -R)'        Evaluation license expired hours is '$hours', skip.'
        else
                echo $(date -R)'        Evaluation license expired hours is '$hours', less than 72, try to reset...'
                reset
                echo $(date -R)'        Evaluation license reset finished.'
        fi
}

usage() {
        echo "USAGE: $SCRIPT_NAME [-a] [-r]"
        echo "-a auto       add script to crontab, then check and run every 2 hours."
        echo "-r reset      check if the trial license is almost out of date, if yes, reset the trial license."
        echo ""
}


set_crontab() {
        local CRON_FILE="/var/spool/cron/crontabs/root"
        local CRON_TASK="0 2 * * * /bin/sh $SCRIPT_PATH/$SCRIPT_NAME -r >> $SCRIPT_PATH/esxi_trial_reset.log"
        chmod +w $CRON_FILE
        grep -qF -- "$CRON_TASK" "$CRON_FILE" || echo -e "\n$CRON_TASK" >> $CRON_FILE
        chmod -w $CRON_FILE
        echo "script has been set to contab and will check and run every 2 hours."
        echo "↓ ↓ ↓ check crontab below ↓ ↓ ↓"
        echo ""
        cat $CRON_FILE
}

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
SCRIPT_NAME="${0##*/}"



if [ "$1" == "-a" ] || [ "$1" == "auto" ]; then
        set_crontab
        exit 0
fi

if [ "$1" == "-r" ] || [ "$1" == "reset" ]; then
        check
        exit 0
fi

usage
