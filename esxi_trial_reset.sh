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
        echo "Usage 1: $SCRIPT_NAME -a [hour]"
        echo "  -a auto         add script to crontab, then check and run every day."
        echo "  hour            set crontab fire time during the day(UTC), default value is 1."
        echo "Usage 2: $SCRIPT_NAME -r"
        echo "  -r reset        check if the trial license is almost out of date, if yes, reset the trial license."
        echo ""
}


set_crontab() {
        local CRON_FILE="/var/spool/cron/crontabs/root"
        local CRON_TIME="0 $FIRE_HOUR * * *"
        local CRON_TASK="$SCRIPT_PATH/$SCRIPT_NAME -r >> $SCRIPT_PATH/$SCRIPT_NAME.log"
        chmod +x $SCRIPT_PATH/$SCRIPT_NAME
        chmod +w $CRON_FILE
        if grep -qF -- "$CRON_TASK" "$CRON_FILE"; then
                echo "script already exist in crontab, exising jobs will be removed."
                sed -i "/$SCRIPT_NAME/d" "$CRON_FILE"
        fi
        echo "$CRON_TIME $CRON_TASK" >> $CRON_FILE
        chmod -w $CRON_FILE
        echo "script has been set to crontab, the job will excute by $FIRE_HOUR o'clock every day(UTC)."
        echo "↓ ↓ ↓ check crontab below ↓ ↓ ↓"
        echo ""
        cat $CRON_FILE
        kill $(cat /var/run/crond.pid)
        crond
}

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
SCRIPT_NAME="${0##*/}"



if [ "$1" == "-a" ] || [ "$1" == "auto" ]; then
        FIRE_HOUR=${2-1}
        set_crontab
        exit 0
fi

if [ "$1" == "-r" ] || [ "$1" == "reset" ]; then
        check
        exit 0
fi

usage
