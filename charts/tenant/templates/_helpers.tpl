{{- define "application-template" -}}
{{ "{{- /* Apply defaults */ -}}" }}
{{ join "" (list "{{- $defaults := `" ($.Values.applicationDefaults | toJson) "` | fromJson -}}") }}
{{ "{{- $applicationData := mustMergeOverwrite $defaults (deepCopy .) -}}" }}

{{ "{{- /* Set metadata */ -}}" }}
{{ join "" (list "{{- $metadata := `" ($.Values.metadata | toJson) "` | fromJson -}}") }}
{{ "{{- $_ := set $applicationData \"metadata\" ($metadata | default dict) -}}" }}

{{ "{{- /* Template values */ -}}" }}
{{ "{{- $applicationDataString := $applicationData | toYaml -}}" }}
{{ "{{- range $match := regexFindAll \"{{ *\\\\..*? *}}\" $applicationDataString -1 -}}" }}
{{ "{{- $keys := substr 2 (int (sub (len $match) 2)) $match | trim | substr 1 -1 | splitList \".\" -}}" }}
{{ "{{- $obj := $applicationData -}}" }}
{{ "{{- range $key := $keys -}}" }}
{{ "{{- if or (not $obj) (ne (kindOf $obj) \"map\") -}}" }}
{{ "{{- $obj = \"\" -}}" }}
{{ "{{- break -}}" }}
{{ "{{- end -}}" }}
{{ "{{- $obj = get $obj $key -}}" }}
{{ "{{- end -}}" }}
{{ "{{- $applicationDataString = replace $match ($obj | default \"\") $applicationDataString -}}" }}
{{ "{{- end -}}" }}
{{ "{{- $applicationData = $applicationDataString | fromYaml -}}" }}

{{ $patchers := $.Files.Glob "files/patchers/*.tpl" }}

{{- range $path, $_ := $patchers -}}
{{ join "" (list "{{- /* " $path " */ -}}") }}
{{ $.Files.Get $path }}
{{ end }}

{{- "{{- with $applicationData -}}" }}

{{ range $path, $_ := $patchers }}
{{- $patcher := (split "." (base $path))._0 }}
{{- printf "{{- template \"application.patcher.%s\" . -}}" $patcher }}
{{ end }}

{{ $.Files.Get "files/application-template.yaml" }}
{{ "{{- end -}}" }}
{{- end -}}

{{- define "applicationset.patcher.goTemplateOptionsObject" -}}
  {{- with .goTemplateOptionsObject -}}
    {{- $goTemplateOptions := $.goTemplateOptions | default list -}}

    {{- range $key, $val := . -}}
      {{- $goTemplateOptions = append $goTemplateOptions (printf "%s=%s" $key (toString $val)) -}}
    {{- end -}}

    {{- $_ := set $ "goTemplateOptions" $goTemplateOptions -}}
  {{- end -}}
{{- end -}}

{{- define "applicationset.patcher.namePrefix" -}}
  {{- with .namePrefix -}}
    {{- $_ := set $ "name" (printf "%s-%s" . $.name) -}}
  {{- end -}}
{{- end -}}
