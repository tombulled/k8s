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

{{- define "applicationset.patcher.xGitGenerator" -}}
  {{- $xGitKey := "x-git" -}}

  {{- range $generator := (.generators | default list) -}}
    {{- $xGit := get $generator $xGitKey -}}

    {{- if not $xGit -}}
      {{- continue -}}
    {{- end -}}

    {{- $values := $xGit.values | default dict -}}
    {{- $_ := set $values "mergeKey" (printf "{{ $_ := set . \"mergeKey\" .%s }}" ($xGit.mergeKey | default "path.path")) -}}

    {{- $gitGenerators := list -}}

    {{- range $valueFile := $xGit.valueFiles | default list -}}
      {{- $gitGenerator := (dict
        "git" (dict
          "repoURL" $xGit.repoURL
          "revision" $xGit.revision
          "files" (list
            (dict
              "path" (printf "%s/%s" $xGit.path $valueFile)
            )
          )
          "values" $values
        )
      ) -}}

      {{- $gitGenerators = append $gitGenerators $gitGenerator -}}
    {{- end -}}

    {{- $generatorType := "" -}}
    {{- $generatorData := dict -}}

    {{- if eq (len $gitGenerators) 1 -}}
      {{- $generatorType = "git" -}}
      {{- $generatorData = get (index $gitGenerators 0) "git" -}}
    {{- else -}}
      {{- $generatorType = "merge" -}}
      {{- $generatorData = (dict
        "mergeKeys" (list "mergeKey")
        "generators" $gitGenerators
      ) -}}
    {{- end -}}

    {{- $_ := unset $generator $xGitKey -}}
    {{- $_ := set $generator $generatorType $generatorData -}}
  {{- end -}}
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
  {{- $data = mustMergeOverwrite (dict "metadata" $root.Values.metadata) (deepCopy $defaults) (deepCopy $data) }}

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
      {{- $_ = set $data "name" (printf "%s-%s" . $data.name) }}
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