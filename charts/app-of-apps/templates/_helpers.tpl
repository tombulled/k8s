{{- define "application-template" -}}
{{- $patchers := $.Files.Glob "files/patchers/*.tpl" -}}

{{- range $path, $_ := $patchers -}}
{{ cat "{{- /* " $path " */ -}}" }}
{{ $.Files.Get $path }}
{{ end }}

{{- range $path, $_ := $patchers -}}
{{- $patcher := (split "." (base $path))._0 -}}
{{ printf "{{- include \"application.patcher.%s\" . -}}" $patcher }}
{{ end }}

{{ $.Files.Get "files/application-template.yaml" }}
{{- end -}}

{{- define "application.patcher.sync-options-object" -}}
  {{- with .syncPolicy -}}
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
    {{- if $syncOptionsList -}}
      {{- $_ := set . "syncOptions" $syncOptionsList -}}
    {{- else -}}
      {{- $_ := unset . "syncOptions" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "application.patcher.info-object" -}}
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

{{- define "application.patcher.deletion" -}}
  {{- with .deletion -}}
    {{- if .cascade -}}
      {{- $finalizers := $.finalizers | default list -}}
      {{- $propagationPolicy := .propagationPolicy | default "foreground" -}}

      {{- with $propagationPolicy -}}
        {{- if eq . "foreground" -}}
          {{- $finalizers = append $finalizers "resources-finalizer.argocd.argoproj.io" -}}
        {{- else if eq . "background" -}}
          {{- $finalizers = append $finalizers "resources-finalizer.argocd.argoproj.io/background" -}}
        {{- else -}}
          {{- fail (printf "Unrecognised deletion propagation policy: '%s'" .) -}}
        {{- end -}}
      {{- end -}}

      {{- $_ := set $ "finalizers" $finalizers -}}
    {{- end -}}
  {{- end -}}
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
