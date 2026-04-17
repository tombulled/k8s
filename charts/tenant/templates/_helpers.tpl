{{- define "application-template" -}}
{{ "{{- /* Apply defaults */ -}}" }}
{{ join "" (list "{{- $defaults := `" ($.Values.applicationDefaults | toJson) "` | fromJson -}}") }}
{{ "{{- $applicationData := mustMergeOverwrite $defaults (deepCopy .) -}}" }}

{{ "{{- /* Set metadata */ -}}" }}
{{ join "" (list "{{- $metadata := `" ($.Values.metadata | toJson) "` | fromJson -}}") }}
{{ "{{- $_ := set $applicationData \"metadata\" ($metadata | default dict) -}}" }}

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

{{- define "applicationset.patcher.generatorsObject" -}}
  {{- with .generatorsObject -}}
    {{- $generators := $.generators | default list -}}

    {{- range $generatorId, $generator := . -}}
      {{- $generators = append $generators $generator -}}
    {{- end -}}

    {{- $_ := set $ "generators" $generators -}}
  {{- end -}}
{{- end -}}
