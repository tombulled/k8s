{{- define "application.patcher.name-prefix" -}}
  {{- with .namePrefix -}}
    {{- $_ := set $ "name" (printf "%s-%s" . ($.name | default "")) -}}
  {{- end -}}
{{- end -}}
