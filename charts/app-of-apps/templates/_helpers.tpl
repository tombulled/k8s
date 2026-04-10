{{- define "applicationSpec" -}}
{{- end -}}

{{- define "patcher.syncOptionsObject" -}}
{{- /* Build Sync Options Dictionary */ -}}
{{- $syncOptionsDict := dict -}}
{{- range $syncOption := .syncOptions | default list }}
{{- $key := (split "=" $syncOption)._0 }}
{{- $val := (split "=" $syncOption)._1 }}
{{- $_ := set $syncOptionsDict $key $val }}
{{- end }}
{{- range $key, $val := .syncOptionsObject | default dict }}
{{- $_ := set $syncOptionsDict (title $key) (toString $val) }}
{{- end }}

{{- /* Build Sync Options List*/ -}}
{{- $syncOptionsList := list -}}
{{- range $key, $val := $syncOptionsDict }}
{{- $syncOptionsList = append $syncOptionsList (printf "%s=%s" $key $val) }}
{{- end }}

{{- /* Patch Sync Policy */ -}}
{{- $_ := set . "syncOptions" $syncOptionsList -}}
{{- end -}}

{{- define "patcher.infoObject" -}}
  {{- with .infoObject -}}
    {{- $info := $.info | default list -}}

    {{- range $key, $val := . -}}
      {{- $name := $key | snakecase | replace "_" " " | title }}
      {{- $obj := dict "name" $name "value" $val }}

      {{- $info = append $info $obj -}}
    {{- end -}}

    {{- $_ := set $ "info" $info -}}
  {{- end -}}
{{- end -}}

{{- define "patcher.sourcesObject" -}}
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
