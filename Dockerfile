# ------------------------------------------------------------
# Basis‑Image (aktuell verfügbar: SQL Server 2022 Developer)
# ------------------------------------------------------------
FROM mcr.microsoft.com/mssql/server:2022-latest

# ------------------------------------------------------------
# emporär zu root wechseln, um Pakete zu installieren
# ------------------------------------------------------------
USER root

# ------------------------------------------------------------
# a) Verzeichnis für apt‑Listen anlegen (Permission‑Problem verhindern)
# ------------------------------------------------------------
RUN mkdir -p /var/lib/apt/lists/partial && \
    chmod 755 /var/lib/apt/lists/partial

# ------------------------------------------------------------
# b) Grundlegende Werkzeuge installieren (curl, gnupg2, ca‑certificates,
#    apt‑transport‑https). Diese sind nötig, um das Microsoft‑Repo zu holen.
# ------------------------------------------------------------
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        curl gnupg2 ca-certificates apt-transport-https && \
    rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# c) Microsoft‑Key und das **richtige Repository** (Ubuntu 22.04) einbinden
# ------------------------------------------------------------
RUN curl -sSL https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl -sSL https://packages.microsoft.com/config/ubuntu/22.04/mssql-server-2022.list \
        > /etc/apt/sources.list.d/mssql-server.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends mssql-server-agent && \
    rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# zurück zum regulären mssql‑User (UID 10001)
# ------------------------------------------------------------
USER 10001

# ------------------------------------------------------------
# Entrypoint‑Script – startet SQL Server und danach den Agent
# ------------------------------------------------------------
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
