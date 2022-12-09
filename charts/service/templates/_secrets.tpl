{{- define "secrets.key.env" -}}
{{ printf "%s-%s" .key (join "-" (list .secret.name "env")) }}
{{- end -}}

{{- define "secrets.key.mount" -}}
{{ printf "%s-%s" .key (join "-" (list .secret.name "mount")) }}
{{- end -}}
