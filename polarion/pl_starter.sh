#! /bin/bash
sudo ./kill_postgres.sh
sudo -u postgres /usr/lib/postgresql/17/bin/pg_ctl -D /opt/polarion/data/postgres-data -l /opt/polarion/data/postgres-data/log.out -o "-p 5433" start
service apache2 start
service polarion start

wait
tail -f /dev/null