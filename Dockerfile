# ------------------------------------------------------------
# Basis‑Image (offizielles Microsoft SQL Server 2025 Image)
# ------------------------------------------------------------
FROM mcr.microsoft.com/mssql/server:2025-latest

# ------------------------------------------------------------
# Wechsel zu root → Werkzeuge und Agent installieren
# ------------------------------------------------------------
USER root

# a) Verzeichnis für apt‑Listen anlegen (sonst Permission‑Error)
RUN mkdir -p /var/lib/apt/lists/partial && \
    chmod 755 /var/lib/apt/lists/partial

# b) Grundpakete (curl, gnupg2, …) installieren
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl gnupg2 ca-certificates apt-transport-https && \
    rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# Microsoft‑Key & Repository für den Agent‑Paket hinzufügen
# ------------------------------------------------------------
RUN curl -sSL https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl -sSL https://packages.microsoft.com/config/ubuntu/22.04/mssql-server-2025.list \
        > /etc/apt/sources.list.d/mssql-server.list && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y --no-install-recommends mssql-server-agent && \
    rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# zurück zu mssql (UID 10001) – das ist der normale Laufzeit‑User
# ------------------------------------------------------------
USER 10001

# ------------------------------------------------------------
# Start‑Script (Entry‑Point) – startet Server + Agent
# ------------------------------------------------------------
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
