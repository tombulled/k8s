{{- define "build-patchers" -}}
  {{- /* Extract arguments */ -}}
  {{- $ := .root -}}
  {{- $path := .path -}}

  {{- range $path, $_ := $.Files.Glob $path -}}
    {{- $patcherId := $path | base | splitList "." | first }}
    {{- printf "{{- /* %s */ -}}" $path | nindent 0 }}
    {{- printf "{{- block \"application.patcher.%s\" . -}}" $patcherId | nindent 0 }}
    {{- $.Files.Get $path | trim | nindent 2 }}
    {{- "{{- end -}}" | nindent 0 }}
    {{- "" | nindent 0 }}
  {{- end -}}
{{- end -}}

{{- define "application-template" -}}
{{ "{{- /* Apply defaults */ -}}" }}
{{ join "" (list "{{- $commonDefaults := `" ($.Values.common | toJson) "` | fromJson -}}") }}
{{ join "" (list "{{- $appDefaults := `" ($.Values.applicationDefaults | toJson) "` | fromJson -}}") }}
{{ "{{- $applicationData := mustMergeOverwrite $commonDefaults $appDefaults (deepCopy .) -}}" }}

{{ "{{- /* Set the application name if unspecified */ -}}" }}
{{ "{{- $_ := set $applicationData \"name\" ($applicationData.name | default $applicationData.id) -}}" }}

{{ "{{- with $applicationData -}}" }}

{{ include "build-patchers" (dict "root" $ "path" "files/application-patchers/*.tpl") | trim }}
{{- "" }}

{{ $.Files.Get "files/application-template.yaml" }}
{{ "{{- end -}}" }}
{{- end -}}

{{- define "build-resource-data" -}}
  {{- /* Extract arguments */ -}}
  {{- $root := .root -}}
  {{- $id := .id -}}
  {{- $data := .data -}}
  {{- $defaults := .defaults -}}

  {{- /* If the resource data is nil, disable this resource (it is considered unwanted) */ -}}
  {{- if eq $data nil -}}
    {{- $data = dict "enabled" false -}}
  {{- end -}}

  {{- /* Apply defaults */ -}}
  {{- $data = mustMergeOverwrite (deepCopy $root.Values.common) (deepCopy $defaults) (deepCopy $data) }}

  {{- /* Only create a resource if it is enabled (defaults to enabled unless told otherwise) */ -}}
  {{- $enabled := ternary $data.enabled true (ne $data.enabled nil) }}
  {{- if $enabled -}}
    {{- /* If unspecified, default the resource name to the resource's ID */ -}}
    {{- if eq $data.name nil -}}
      {{- $_ := set $data "name" $id -}}
    {{- end -}}

    {{- /* Template the resource's data using itself (inception!) */ -}}
    {{- $data = tpl ($data | toYaml) $data | fromYaml -}}

    {{- /* If a name prefix was configured, update the name to use the configured prefix */ -}}
    {{- with $data.namePrefix }}
      {{- $_ := set $data "name" (printf "%s-%s" . $data.name) }}
    {{- end }}

    {{- /* Finally, output the new resource data */ -}}
    {{- $data | toYaml -}}
  {{- end -}}
{{- end -}}

{{- define "filter" -}}
  {{- $data := .data -}}
  {{- $keys := .keys -}}

  {{- $filteredData := dict -}}

  {{- range $key := $keys }}
    {{- $val := index $data $key -}}

    {{- if ne $val nil }}
      {{- $_ := set $filteredData $key $val }}
    {{- end }}
  {{- end }}

  {{- $filteredData | toYaml -}}
{{- end -}}
