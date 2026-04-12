{{- define "application.patcher.sources-object" -}}
  {{- with .sourcesObject -}}
    {{- $sources := $.sources | default list -}}

    {{- range $sourceId, $source := . -}}
      {{- $_ := set . "ref" (.ref | default $sourceId) -}}
      {{- $_ := set . "name" (.name | default $sourceId) -}}

      {{- $sources = append $sources $source -}}
    {{- end -}}

    {{- $_ := set $ "sources" $sources -}}
  {{- end -}}
{{- end -}}
