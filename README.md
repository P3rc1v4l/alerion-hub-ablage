# Alerion Hub – Ablage

Öffentliche Ablage der offiziellen Releases von **Alerion Hub**.

- `catalog.json` – Katalog mit Version, Download-Adresse, Größe und SHA-256 je Plattform
- `catalog.json.sig` – SSH-Signatur des Katalogs (ed25519, Namensraum `alerion-hub-catalog`)
- Die Installer liegen unter *Releases*.

Alerion Hub nimmt nur Kataloge an, die mit dem eingebauten Release-Schlüssel signiert
sind, und nie einen älteren als den zuletzt gesehenen. Jede Datei wird vor der
Installation auf Größe und SHA-256 geprüft.

Selbst prüfen (mit dem öffentlichen Schlüssel aus Alerion Hub als `allowed_signers`):

```sh
ssh-keygen -Y verify -f allowed_signers -I alerion -n alerion-hub-catalog \
  -s catalog.json.sig < catalog.json
```

Dieses Repo wird nur über das Release-Werkzeug geändert. Bitte keine Pull Requests.

© Luka Kalinka
