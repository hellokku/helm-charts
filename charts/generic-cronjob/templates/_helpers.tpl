{{/*
Expand the name of the chart.
*/}}
{{- define "generic-cronjob.name" -}}
{{- if .Values.appVersionSelector }}
{{- required "if appVersionSelector is enabled, appName is required" .Values.appName | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- default .Values.appName .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "generic-cronjob.fullname" -}}
{{- if .Values.fullappName }}
{{- .Values.fullappName | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.appName }}
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
{{- define "generic-cronjob.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "generic-cronjob.labels" -}}
helm.sh/chart: {{ include "generic-cronjob.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/name: {{ include "generic-cronjob.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if not .Values.appVersionSelector }}
app.kubernetes.io/version: {{ include "generic-cronjob.version" . }}
{{- end }}
{{- end }}

{{/*
deployments matchLabels
*/}}
{{- define "generic-cronjob.matchLabels" }}
{{- if .Values.appVersionSelector -}}
app.kubernetes.io/name: {{ include "generic-cronjob.name" . }}
app.kubernetes.io/version: {{ include "generic-cronjob.version" . }}
{{- else -}}
app.kubernetes.io/name: {{ include "generic-cronjob.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
{{- end }}

{{/*
deployments matchLabels
*/}}
{{- define "generic-cronjob.podLabels" }}
{{- if .Values.podLabels }}
{{- toYaml .Values.podLabels }}
{{- end }}
app.kubernetes.io/name: {{ include "generic-cronjob.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ include "generic-cronjob.version" . }}
{{- if .Values.appName }}
app: {{ .Values.appName }}
{{- end }}
{{- end }}

{{/*
pod annotations in deployment
*/}}
{{ define "generic-cronjob.podAnnotations" }}
    {{- range $k, $v := .Values.podAnnotations }}
        {{- if (not (kindIs "invalid" $v)) }}
{{ $k }}: {{ $v | toYaml }}
        {{- end }}
    {{- end }}
{{- end }}


{{/*
Service Selector labels to Pod
*/}}
{{- define "generic-cronjob.serviceSelectorLabels" -}}
{{- if .Values.appVersionSelector -}}
app.kubernetes.io/name: {{ include "generic-cronjob.name" . }}
{{- else -}}
app.kubernetes.io/name: {{ include "generic-cronjob.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
{{- end }}


{{/*
Create the name of the service account to use
*/}}
{{- define "generic-cronjob.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "generic-cronjob.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Applicaton version
*/}}
{{- define "generic-cronjob.version" -}}
{{- .Values.appVersion | default .Values.image.tag }}
{{- end}}