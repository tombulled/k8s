{{- $metadataKeys := (list
  "annotations"
  "finalizers"
  "labels"
  "name"
  "namespace"
) -}}
{{- $specKeys := (list
  "egress"
  "ingress"
  "podSelector"
  "policyTypes"
) -}}

{{- range $id, $_ := .Values.networkPolicies -}}
{{- $data := include "build-resource-data" (dict "root" $ "id" $id "data" . "defaults" $.Values.networkPolicyDefaults) | fromYaml -}}
{{- if not $data -}}{{- continue -}}{{- end -}}
{{- $metadata := include "filter" (dict "data" $data "keys" $metadataKeys) | fromYaml }}
{{- $spec := include "filter" (dict "data" $data "keys" $specKeys) | fromYaml }}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
{{- with $metadata }}
metadata: {{ . | toYaml | nindent 2 }}
{{- end -}}
{{- with $spec }}
spec: {{ . | toYaml | nindent 2 }}
{{- end }}
{{- end }}
