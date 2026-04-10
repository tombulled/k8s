{{- define "applicationSpec" -}}
{{- end -}}

{{- define "syncPolicy" -}}
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
{{- $_ := unset . "syncOptionsObject" -}}
{{- $_ := set . "syncOptions" $syncOptionsList -}}

{{- /* Output Sync Policy */ -}}
{{ . | toYaml }}
{{- end -}}

{{- define "applicationInfo" -}}
{{- $infoList := get . "list" | default list -}}
{{- $infoDict := get . "dict" | default dict -}}
{{- $info := dict }}
{{- range $item := $infoList }}
{{- $_ := set $info ($item.name) $item }}
{{- end }}
{{- range $key, $val := $infoDict }}
{{- $name := $key | snakecase | replace "_" " " | title }}
{{- $obj := dict "name" $name "value" $val }}
{{- $_ := set $info $name $obj }}
{{- end }}
{{- $output := list }}
{{- range $_, $val := $info }}
{{- $output = append $output $val }}
{{- end }}
info: {{- $output | toYaml | nindent 2 }}
{{- end -}}