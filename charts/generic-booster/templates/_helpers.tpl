{{/*
Expand the name of the chart.
*/}}
{{- define "generic-booster.name" -}}
{{- if .Values.appVersionSelector }}
{{- required "if appVersionSelector is enabled, appName is required" .Values.appName | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- .Values.appName | default .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "generic-booster.fullname" -}}
{{- if .Values.fullappName }}
{{- .Values.fullappName | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := .Values.appName | default .Chart.Name }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}


{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "generic-booster.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "generic-booster.labels" -}}
helm.sh/chart: {{ include "generic-booster.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/name: {{ include "generic-booster.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if not .Values.appVersionSelector }}
app.kubernetes.io/version: {{ include "generic-booster.version" . }}
{{- end }}
{{- end }}

{{/*
deployments matchLabels
*/}}
{{- define "generic-booster.matchLabels" }}
{{- if .Values.appVersionSelector -}}
app.kubernetes.io/name: {{ include "generic-booster.name" . }}
app.kubernetes.io/version: {{ include "generic-booster.version" . }}
{{- else -}}
app.kubernetes.io/name: {{ include "generic-booster.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
{{- end }}

{{/*
datadog labels
*/}}
{{- define "generic-booster.datadogLabels" }}
tags.datadoghq.com/env: {{ .Values.datadog.env }}
tags.datadoghq.com/service: {{ .Values.datadog.serviceName | default .Values.appName }}
tags.datadoghq.com/version: {{ .Values.datadog.version | default .Values.image.tag }}
{{- end }}

{{/*
application environments
*/}}
{{- define "generic-booster.env" }}
{{- range .Values.env }}
- name: {{ .name }}
{{- if .value }}
{{- if and (eq .name "JAVA_TOOL_OPTIONS")  (eq $.Values.datadog.enabled true) (not (contains "dd-java-agent" .value)) }}
{{- $value := list .value "-javaagent:/datadog/apm/agent/dd-java-agent.jar" | join " " }}
  value: {{ $value | quote }}
{{- else }}
  value: {{ .value | quote }}
{{- end }}
{{- else }}
  valueFrom:
{{ toYaml .valueFrom | indent 6 }}
{{- end }}
{{- end }}
{{- end }}

{{/*
application extra environments
*/}}
{{- define "generic-booster.extraEnv" }}
{{- range .Values.extraEnv }}
- name: {{ .name }}
{{- if .value }}
{{- if and (eq .name "JAVA_TOOL_OPTIONS")  (eq $.Values.datadog.enabled true) (not (contains "dd-java-agent" .value)) }}
{{- $value := list .value "-javaagent:/datadog/apm/agent/dd-java-agent.jar" | join " " }}
  value: {{ $value | quote }}
{{- else }}
  value: {{ .value | quote }}
{{- end }}
{{- else }}
  valueFrom:
{{ toYaml .valueFrom | indent 6 }}
{{- end }}
{{- end }}
{{- end }}

{{/*
datadog environments
*/}}
{{- define "generic-booster.datadogEnv" }}
- name: DD_AGENT_HOST
  valueFrom:
    fieldRef:
      fieldPath: status.hostIP
- name: DD_SERVICE
  valueFrom:
    fieldRef:
      fieldPath: metadata.labels['tags.datadoghq.com/service']
- name: DD_ENV
  valueFrom:
    fieldRef:
      fieldPath: metadata.labels['tags.datadoghq.com/env']
- name: DD_VERSION
  valueFrom:
    fieldRef:
      fieldPath: metadata.labels['tags.datadoghq.com/version']
- name: DATADOG_TRACE_AGENT_HOSTNAME
  valueFrom:
    fieldRef:
      fieldPath: status.hostIP
{{- if .Values.datadog.enabled }}
{{- if eq .Values.datadog.language "nodejs" }}
- name: NODE_OPTIONS
  value: {{ printf "--require dd-trace/init" | quote }}
{{- end }}
{{- $dd_tags := list }}
{{- if .Values.datadog.configs.DD_TAGS }}
{{- $dd_tags = append $dd_tags .Values.datadog.configs.DD_TAGS }}
{{- end }}
{{- if and .Values.git.sha .Values.git.url }}
{{- $dd_tags = append $dd_tags (printf "git.commit.sha:%s,git.repository_url:%s" .Values.git.sha .Values.git.url) }}
{{- end }}
{{- if $dd_tags }}
- name: DD_TAGS
  value: {{ $dd_tags | join "," | quote }}
{{- end }}
{{- end }}
{{- range $key := (.Values.datadog.configs | keys | sortAlpha) }}
{{- if ne $key "DD_TAGS" }}
- name: {{ $key }}
  value: {{ get $.Values.datadog.configs $key | quote }}
{{- end }}
{{- end }}
{{- end }}



{{/*
deployments matchLabels
*/}}
{{- define "generic-booster.podLabels" }}
{{- if .Values.podLabels }}
{{- toYaml .Values.podLabels }}
{{- end }}
app.kubernetes.io/name: {{ include "generic-booster.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ include "generic-booster.version" . }}
{{- if .Values.appName }}
app: {{ .Values.appName }}
{{- end }}
{{- end }}

{{/*
pod annotations in deployment
*/}}
{{ define "generic-booster.podAnnotations" }}
    {{- range $k, $v := .Values.podAnnotations }}
        {{- if (not (kindIs "invalid" $v)) }}
{{ $k }}: {{ $v | toYaml }}
        {{- end }}
    {{- end }}
{{- end }}


{{/*
Service Selector labels to Pod
*/}}
{{- define "generic-booster.serviceSelectorLabels" -}}
{{- if .Values.appVersionSelector -}}
app.kubernetes.io/name: {{ include "generic-booster.name" . }}
{{- else -}}
app.kubernetes.io/name: {{ include "generic-booster.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
{{- if .Values.serviceVersionSelector }}
app.kubernetes.io/version: {{ include "generic-booster.version" . }}
{{- end -}}
{{- end }}

{{/*
Create the name of the service to use
*/}}
{{- define "generic-booster.serviceName" -}}
{{- if .Values.service.enabled }}
{{- default (include "generic-booster.fullname" .) .Values.service.name }}
{{- else }}
{{- default "default" .Values.service.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "generic-booster.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "generic-booster.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Applicaton version
*/}}
{{- define "generic-booster.version" -}}
{{- .Values.appVersion | default .Values.image.tag }}
{{- end}}