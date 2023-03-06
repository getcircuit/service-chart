{{- range $k, $environment := .Values.environments }}
{{- /* Deploy production environment only when deployProduction override isn't set */}}
{{ $deployProduction := $.Values.overrides.deployProduction }}
{{- if or (not $environment.production) $deployProduction }}

{{- if $environment.clusterAuth }}

{{ $name := printf "%s--%s" $environment.name $.Values.name }}
{{- if and $environment.production (not $environment.name) }}
  {{ $name = $.Values.name }}
{{- end }}
{{- if and $.Values.overrides.environmentName }}
  {{ $name = printf "%s-%s--%s" $.Values.overrides.environmentName ($environment.name | default "default") $.Values.name }}
{{- end }}

{{ $namespace := $.Values.global.stagingNamespace }}
{{- if $environment.production }}
  {{ $namespace = $.Values.global.prodNamespace }}
{{- end }}

apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: {{ $name }}
  namespace: {{ $namespace }}
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: {{ $.Values.name }}
  action: DENY
  rules:
    {{- range $i, $route := $environment.clusterAuth.routes }}
    - to:
      - operation:
          {{- if not (kindIs "slice" $route.paths) }}
            {{ fail "clusterAuth.routes.paths must be a list" }}
          {{- end }}
          paths: 
            {{- toYaml $route.paths | nindent 12 }}
          {{- if $route.methods }}
          {{- if not (kindIs "slice" $route.methods) }}
            {{ fail "clusterAuth.routes.methods must be a list" }}
          {{- end }}
          methods: 
            {{- toYaml $route.methods | nindent 12 }}
          {{- end }}
      from:
      - source:
          namespaces:
            - {{ $namespace }}
          notPrincipals:
            {{- if not (kindIs "slice" $route.services) }}
              {{ fail "clusterAuth.routes.services must be a list" }}
            {{- end }}
            {{- range $j, $service := $route.services }}
            - {{ printf "cluster.local/ns/%s/sa/%s" $namespace $service }}
            {{- end }}
    {{- end }}
---
{{- end }}

{{- end }}
{{- end }}
