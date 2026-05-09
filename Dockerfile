# ------------------------------------------------------------
# Basis‑Image (derzeit verfügbare 2022‑Developer)
# ------------------------------------------------------------
FROM mcr.microsoft.com/mssql/server:2022-latest

# ------------------------------------------------------------
# Wir wechseln zu root, weil wir Pakete installieren müssen
# ------------------------------------------------------------
USER root

# a) Verzeichnis für apt‑listen anlegen (Permission‑Problem verhindern)
RUN mkdir -p /var/lib/apt/lists/partial && \
    chmod 755 /var/lib/apt/lists/partial

# b) Grund‑Tools installieren (curl, gnupg2, ca‑certificates, apt‑transport‑https)
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        curl gnupg2 ca-certificates apt-transport-https && \
    rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# Microsoft‑Key & Repository für das SQL‑Server‑Agent‑Paket hinzufügen
# ------------------------------------------------------------
#   - Schlüssel in ein keyring‑File schreiben (apt‑key wird nicht mehr empfohlen)
#   - Repository‑Eintrag für Ubuntu 22.04 / SQL‑Server 2022 einbinden
RUN curl -sSL https://packages.microsoft.com/keys/microsoft.asc | \
        gpg --dearmor -o /usr/share/keyrings/microsoft-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] \
          https://packages.microsoft.com/ubuntu/22.04/mssql-server-2022 stable main" \
        > /etc/apt/sources.list.d/mssql-server.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        mssql-server-agent && \
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
