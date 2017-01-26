#!/bin/bash

self=innobackupex

# avoid classical cron pitfall
pgrep $self.sh | grep -v $$ | line > /dev/null && { date | mail -s "$self already running" root; exit 1; }

# max number of backup to keep
H=24 # cron hour divisor
D=21 # days to keep
N=$(((24/$H)*$D))

# to be invoked via cron
# 0 */$H * * * root /usr/local/bin/$self.sh

# base dir
b=/space/backups
t=/tmp/$self.out
l=/var/log/$self.log

# try to minimize load
function low { time nice -19 ionice -n 7 $*; }

# verify output of $self
function check { grep -q "$self: completed OK!" $1 || { date | mail -s "$2" root; exit 1; }; }

password=$(cat /usr/local/etc/innobackupex.txt)
mkdir -p $b/{last,olders}

# make a time-stamped backup
low $self --password=$password $b/last 2> $t
# check success and log
check $t "$self failed"
cat $t >> $l

# prepare the last made backup for usage or restoration
ls -d $b/last/* | tail -n 1 | low xargs $self --password=$password --apply-log 2> $t
# check success and log
check $t "$self --apply-log failed"
cat $t >> $l

# move all but the last backup to *older* zone
ls -d $b/last/* | head -n -1 | xargs -ri mv {} $b/olders

# make a shallow copy of last backup without timestamp
# to allow differential (rsync) backup

rm -rf $b/2copy; mkdir -p $b/2copy
ls -d $b/last/* | tail -n 1 | xargs -ri cp -al {}/. $b/2copy

# never keep more than $N backups
mkdir -p $b/2rm
ls -d $b/olders/* | head -n -$N | xargs -ri mv {} $b/2rm
ls -A $b/2rm | line > /dev/null && (ls -l $b/2rm/*; rm -r $b/2rm) >> $l

# dedup unchanged files
hardlink $b/olders >> $l

# show changes
du -sh $b/{olders/*,last/*,} > $t
if tty > /dev/null; then mail -s $self root < $t; else cat $t; fi
cat $t >> $l

rm $t
