#!/usr/bin/env bash
set -euo pipefail

# Regex, um passende Gateways zu filtern (Default: alles mit "ingress")
# Beispiel für exakt das Istio-Gateway im istio-system:
#   export GATEWAY_REGEX='^istio-system/.+ingressgateway$'
GATEWAY_REGEX="${GATEWAY_REGEX:-ingress}"

dump_routes() {
  local ctx="$1"
  kubectl --context "$ctx" get virtualservice -A -o json \
  | jq -r --arg re "$GATEWAY_REGEX" '
    .items[]
    # nur VS mit Gateways und Gateway-Referenz passend zum Regex
    | select((.spec.gateways // []) | length > 0)
    | select([.spec.gateways[]?] | map(test($re)) | any)
    | .spec as $s
    | ($s.hosts // []) as $hosts
    | if ($s.http // []) | length > 0 then
        # alle Matches extrahieren, Fallback "/" als prefix
        [$s.http[] | (.match // [ {} ])[] |
          {
            kind: ( if .uri.prefix? then "prefix"
                    elif .uri.exact? then "exact"
                    elif .uri.regex? then "regex" else "prefix" end ),
            raw:  ( .uri.prefix // .uri.exact // .uri.regex // "/" )
          }
        ] as $ms
        | $hosts[] as $h
        | $ms[]
        | (.raw | if startswith("/") then . else "/" + . end) as $p
        | "\($h)\($p) (\(.kind))"
      else
        # keine http-section => Host auf "/" als prefix
        $hosts[] | . as $h | "\($h)/ (prefix)"
      end
  ' \
  | sort -u
}

# --- Usage ---
# 1) Einzel-Cluster:
#    dump_routes <kube-context>
#
# 2) Vergleich zweier Cluster:
#    dump_routes <ctxA> > /tmp/routes.A.txt
#    dump_routes <ctxB> > /tmp/routes.B.txt
#    diff -u /tmp/routes.A.txt /tmp/routes.B.txt || true
# GATEWAY_REGEX="." dump_routes local
