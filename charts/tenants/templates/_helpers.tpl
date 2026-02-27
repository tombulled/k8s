{{- define "tenants" -}}
{{- $tenantDefaults := .Values.tenantDefaults -}}
{{- $tenants := dict -}}
{{- range $tenantId, $tenantVal := .Values.tenants -}}
{{- $tenant := mustMergeOverwrite (dict) (deepCopy $tenantDefaults) (deepCopy $tenantVal) -}}
{{- if $tenant.enabled -}}
{{- $_ := set $tenants $tenantId $tenant -}}
{{- end -}}
{{- range $namespaceId, $namespace := .namespaces -}}
{{- $namespaceEnabled := ternary .enabled true (ne .enabled nil) -}}
{{- if not $namespaceEnabled -}}
{{- $_ := unset $tenant.namespaces $namespaceId -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{ $tenants | toYaml }}
{{- end -}}

{{/*{{- define "namespaces" -}}
{{- $tenants := include "tenants" $ -}}
{{- $namespaces := dict -}}
{{- range $tenantId, $tenant := .Values.tenants -}}
{{- range $namespace := .namespaces -}}
{{- $namespaceEnabled := ternary .enabled true (ne .enabled nil) -}}
{{- if $namespaceEnabled -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}*/}}