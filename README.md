# Use innobackupx via cron

[The innobackupex tool is a Perl script that acts as a wrapper for the xtrabackup C program][innobackupex]

Our wrapper organize cron invocation for a full cycle (backup,
prepare, rename, rotate) and allow a second rsync step of a name
invariant last backup.

This is an old 2012 script.

Should be embedded in a playbook to templatize the script dependency
(apt install hardlink), parameter (basedir, cron invocation frequency,
retention period, password acquisition, etc, ...), installation, and
cron invocation.

[innobackupex]: https://www.percona.com/doc/percona-xtrabackup/2.1/innobackupex/innobackupex_script.html "www.percona.com"
