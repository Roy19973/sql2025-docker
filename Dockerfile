# ------------------------------------------------------------
# Basis‑Image (derzeit verfügbar: SQL Server 2022 Developer)
# ------------------------------------------------------------
FROM mcr.microsoft.com/mssql/server:2022-latest

# ------------------------------------------------------------
# Temporär zu root wechseln (für Paket‑Installation)
# ------------------------------------------------------------
USER root

# ------------------------------------------------------------
# a) Verzeichnis für apt‑Listen anlegen (Permission‑Problem verhindern)
# ------------------------------------------------------------
RUN mkdir -p /var/lib/apt/lists/partial && \
    chmod 755 /var/lib/apt/lists/partial

# ------------------------------------------------------------
# b) Grundlegende Werkzeuge (curl, gnupg2, ca‑certificates,
#    apt‑transport‑https) installieren
# ------------------------------------------------------------
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        curl gnupg2 ca-certificates apt-transport-https && \
    rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# **WICHTIG** – Keine eigene Repository‑Datei mehr!
#     Das Basis‑Image enthält bereits die richtige Microsoft‑Quelle.
#     Wir müssen nur das Agent‑Paket installieren.
# ------------------------------------------------------------
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends mssql-server-agent && \
    rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# Zurück zum regulären mssql‑User (UID 10001)
# ------------------------------------------------------------
USER 10001

# ------------------------------------------------------------
# Entrypoint‑Script – startet SQL Server und danach den Agent
# ------------------------------------------------------------
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
