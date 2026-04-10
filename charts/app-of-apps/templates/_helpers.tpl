{{- define "application-template" -}}
{{- $patchers := $.Files.Glob "files/patchers/*.tpl" -}}

{{- range $path, $_ := $patchers -}}
{{ cat "{{- /* " $path " */ -}}" }}
{{ $.Files.Get $path }}
{{ end }}

{{- range $path, $_ := $patchers -}}
{{- $patcher := (split "." (base $path))._0 -}}
{{ printf "{{- template \"application.patcher.%s\" . -}}" $patcher }}
{{ end }}

{{ $.Files.Get "files/application-template.yaml" }}
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
