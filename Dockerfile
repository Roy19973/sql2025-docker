# ------------------------------------------------------------
# Basis‑Image (derzeit verfügbar: SQL Server 2022 Developer)
# ------------------------------------------------------------
FROM mcr.microsoft.com/mssql/server:2022-latest

# ------------------------------------------------------------
# Wir benötigen Root‑Rechte, um Pakete zu installieren
# ------------------------------------------------------------
USER root

# ------------------------------------------------------------
# a) Verzeichnis für apt‑listen anlegen (Permission‑Problem verhindern)
# ------------------------------------------------------------
RUN mkdir -p /var/lib/apt/lists/partial && \
    chmod 755 /var/lib/apt/lists/partial

# ------------------------------------------------------------
# Grundlegende Werkzeuge (curl, gnupg2, ca‑certificates, apt‑transport‑https)
# ------------------------------------------------------------
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        curl gnupg2 ca-certificates apt-transport-https && \
    rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# Microsoft‑Key & das offizielle Repository für das Agent‑Paket einbinden
# ------------------------------------------------------------
RUN curl -sSL https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl -sSL https://packages.microsoft.com/config/ubuntu/22.04/mssql-server-2022.list \
        > /etc/apt/sources.list.d/mssql-server.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends mssql-server-agent && \
    rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# Zurück zum regulären mssql‑User (UID 10001)
# ------------------------------------------------------------
USER 10001

# ------------------------------------------------------------
# Entrypoint‑Script – startet SQL Server und danach den SQL Server Agent
# ------------------------------------------------------------
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
