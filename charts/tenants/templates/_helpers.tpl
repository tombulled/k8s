{{- define "tenants" -}}
{{- $tenantDefaults := .Values.tenantDefaults -}}
{{- $tenants := dict -}}
{{- range $tenantId, $tenantVal := .Values.tenants -}}
{{- $tenant := mustMergeOverwrite (dict) (deepCopy $tenantDefaults) (deepCopy $tenantVal) -}}
{{- if $tenant.enabled -}}
{{- $_ := set $tenants $tenantId $tenant -}}
{{- end -}}
{{- end -}}
{{ $tenants | toYaml }}
{{- end -}}
