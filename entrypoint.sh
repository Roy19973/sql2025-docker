#!/usr/bin/env bash
set -e

# ------------------------------------------------------------
# SQL Server im Hintergrund starten
# ------------------------------------------------------------
echo "=== Starte SQL Server ..."
/opt/mssql/bin/sqlservr &

# ------------------------------------------------------------
# Warten, bis der Server erreichbar ist
# ------------------------------------------------------------
echo "=== Warte bis SQL Server bereit ist ..."
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
echo "=== SQL Server ist bereit."

# ------------------------------------------------------------
# SQL Server Agent starten
# ------------------------------------------------------------
echo "=== Starte SQL Server Agent ..."
/opt/mssql/bin/sqlservr-agent &

# ------------------------------------------------------------
# Container am Leben halten (warten, bis einer der Prozesse endet)
# ------------------------------------------------------------
wait -n
