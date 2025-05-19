# EnvoyFilter Collection

Dieser Ordner enthält produktiv getestete `EnvoyFilter`-Beispiele für Istio,  
die das Logging-Verhalten für TCP- und HTTP-Traffic erweitern.

## 📂 Dateien

| Datei                | Zweck                                     |
|----------------------|-------------------------------------------|
| `json-log-tcp.yaml`  | Fügt strukturiertes JSON-Logging für `tcp_proxy` hinzu |
| `json-log-http.yaml` | Fügt strukturiertes JSON-Logging für HTTP-Routes (`router`) hinzu |

Die Filter loggen auf `/dev/stdout` und erzeugen maschinenlesbare JSON-Einträge,  
die sich gut für zentrale Logging-Systeme wie Loki, Fluent Bit oder Stackdriver eignen.

## ➕ Anwendung

```bash
kubectl apply -f json-log-tcp.yaml
kubectl apply -f json-log-http.yaml