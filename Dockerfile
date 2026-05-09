# ------------------------------------------------------------
# Basis‑Image (aktuell verfügbar: SQL Server 2022 Developer)
# ------------------------------------------------------------
FROM mcr.microsoft.com/mssql/server:2022-latest   # 2025-Preview gibt es noch nicht

# ------------------------------------------------------------
# Wir gehen zu root, weil wir Pakete installieren müssen
# ------------------------------------------------------------
USER root

# a) Verzeichnis für apt‑listen anlegen (um das Permission‑Problem zu umgehen)
RUN mkdir -p /var/lib/apt/lists/partial && \
    chmod 755 /var/lib/apt/lists/partial

# b) Basis‑Tools installieren (curl, gnupg2, …) – ohne apt‑key‑Hack
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        curl gnupg2 ca-certificates apt-transport-https && \
    rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# SQL Server Agent aus dem **eingebauten** Microsoft‑Repo installieren
# ------------------------------------------------------------
RUN ACCEPT_EULA=Y apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends mssql-server-agent && \
    rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# zurück zum regulären mssql‑User (UID 10001)
# ------------------------------------------------------------
USER 10001

# ------------------------------------------------------------
# Entrypoint‑Script, das Server + Agent startet
# ------------------------------------------------------------
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
