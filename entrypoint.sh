#!/usr/bin/env bash
set -e

# Startet den SQL Server im Hintergrund
/opt/mssql/bin/sqlservr &

# Wartet, bis der Server bereit ist (max. 30 Versuche à 2 s)
max_tries=30
tries=0
until /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "$MSSQL_SA_PASSWORD" -Q "SELECT 1" >/dev/null 2>&1; do
    ((tries++))
    if ((tries >= max_tries)); then
        echo "SQL Server startete nicht innerhalb von $((max_tries*2)) Sekunden → Abbruch"
        exit 1
    fi
    sleep 2
done

# Startet den SQL Server Agent
/opt/mssql/bin/sqlservr-agent &

# Hält den Container am Leben (wartet auf den ersten beendeten Prozess)
wait -n
