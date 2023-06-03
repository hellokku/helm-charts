

# generic-booster

A Helm chart for Deployment Type Generic App,

![Version: 0.8.3](https://img.shields.io/badge/Version-0.8.3-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)
## features
* Support simply only single container (e.g. RestAPI Applications).
  single container means what not support  Multi-Container
* Support AWS Ingress(`networking.k8s.io/v1`). but You have to manage the Ingress manually on the Stage and Live Env
* Do not use this chart if the application configuration is a complex configuration such as policy, disk addition, multi-containers.

## requirement helm plugins
1. helm3 - see [FAQ-Changes since helm2](https://helm.sh/docs/faq/#changes-since-helm-2)
1. [helm plugins](https://helm.sh/docs/community/related/#helm-plugins) - Option
    * install [helm diff plugin](https://github.com/databus23/helm-diff)
    ```console
    helm plugin install https://github.com/databus23/helm-diff
    ```
    * install [helm s3 plugin](https://github.com/hypnoglow/helm-s3)
    ```console
    helm plugin install https://github.com/hypnoglow/helm-s3
    ```

## Install the `generic-booster` Chart

To install the chart with the release name `log-aggregator`:

```console
$ helm repo add mod-charts s3://nxm-mod-deploy/helm-charts/charts/
$ helm install log-aggregator mod-charts/generic-booster
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | affinity |
| appName | string | `""` |  |
| appVersion | string | `"stable"` | added specifically application app.kubernetes.io/version to pod Label, its default is image tag |
| appVersionSelector | bool | `true` | if true, app.kubernetes.io/application label to pod Selector  |
| args | list | `[]` | custom argument |
| autoscaling.annotations | object | `{}` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.metrics | list | `[]` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| command | list | `[]` | custom command |
| configMapMounts | list | `[]` | the name must be defined as config-maps |
| configMaps | list | `[]` | configmap list |
| containerPorts | list | `[{"name":"http","port":80,"protocol":"TCP","targetPort":"http"}]` | the name must be defined as config-maps |
| containerSecurityContext | object | `{}` | securityContext for container scope |
| emptDirMounts | list | `[]` | define emptyDir and Mount path |
| env | list | `[]` | additional environments |
| image | object | `{"pullPolicy":"IfNotPresent","repository":"nginx","tag":""}` | images.tag must be defined |
| imagePullSecrets | list | `[]` | secret to pull image |
| ingress.annotations | object | `{}` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"chart-example.local"` |  |
| ingress.hosts[0].paths | list | `[]` |  |
| ingress.tls | list | `[]` |  |
| labels | object | `{}` | it's an additional labels of the deployments |
| lifecycle | object | `{}` | container lifecycle, feel-free define    |
| livenessProbe | object | `{"httpGet":{"path":"/","port":"http"}}` | overwrite livenessProbe |
| matchLabels | object | `{}` | pod selector matchLabels, if you define this, there replace the matchLabels |
| nodeSelector | object | `{}` | nodeSelector |
| podAnnotations | object | `{}` | it's an additional annotations of the Pod |
| podInitContainers | list | `[]` |  |
| podLabels | object | `{}` |  |
| podSecurityContext | object | `{}` | it's Pod scope securityContext  |
| readinessProbe | object | `{"httpGet":{"path":"/","port":"http"}}` | overwrite readinessProble |
| replicaCount | int | `1` | if you use the HPA, set it to -1 |
| resources | object | `{}` | container resources, feel-free |
| secretMounts | list | `[]` | secrets mount |
| service.annotations | object | `{}` |  |
| service.enabled | bool | `true` |  |
| service.port | int | `80` |  |
| service.portName | string | `"http"` |  |
| service.ports | list | `[]` |  |
| service.targetPort | string | `"http"` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `false` |  |
| serviceAccount.name | string | `""` |  |
| startupProbe | object | `{}` | overwrite startupProbe |
| strategy.rollingUpdate.maxSurge | string | `"25%"` |  |
| strategy.rollingUpdate.maxUnavailable | string | `"25%"` |  |
| strategy.type | string | `"RollingUpdate"` |  |
| terminationGracePeriodSeconds | int | `30` | termination grace period seconds for Pod |
| tolerations | list | `[]` | tolerations |

## Basic Helm Chart
### install & upgrade
```
# helm upgrade --install <release name> <repository>/<chart name> -f values.yaml
# For example
helm upgrade --install log-aggregator labs-charts/generic-booster -f values.yaml
```

### preview manifest
```
helm template log-aggregator labs-charts/generic-booster -f values.yaml
```

### diff manifest
```
helm diff upgrade log-aggregator labs-charts/generic-booster -f values.yaml
```

## Generage Helm Doc
* helm-doc을 이용해 helm 문서를 Generate한다.
* 필요한 pre-commit을 통해 자동화 할 수 있다.
* 자세한 내용은 다음 URL을 참조 https://github.com/norwoodj/helm-docs
```
helm-docs --template-files=_templates.gotmpl --template-files=_README.md.gotmpl
```

### get current image tag
```
kubectl get deploy simple -o yaml | yq e '.spec.template.spec.containers[] | select(.name == "simple") | .image' - | cut -d ':' -f 2
helm template simple mod-charts/generic-booster -f simple.yaml --set image.tag=`kubectl get deploy simple -o yaml | yq e '.spec.template.spec.containers[] | select(.name == "simple") | .image' - | cut -d ':' -f 2`
```

## Package Helm Chart
* 아래 명령어 순서에 따라 helm chart를 packaging 하고 repository에 upload 한다.
```
# helm package --version <chart version> --app-version <image tag> ./
helm package --version 0.8.3 --app-version  ./

helm s3 push generic-booster-0.8.3.tgz labs-charts
```
## multi versioning
* 여러 버전을 rollout 하기 위한 구성
* 전통적인 고정형 canary 구성을 위한 리소스 이름 기반 구성  
`serviceVersionSelector=true` 로 Service selector에 `app.kubernetes.io/version`이 추가 된다. 
```
# -- production 구성, 시즈모드로 version selector로 구성
# -- release name http-echo
appName: http-echo
appVersion: stable
serviceVersionSelector: true
# -- 생성된 selector 결과 
kind: Service
  ...
  selector:
    app.kubernetes.io/name: http-echo
    app.kubernetes.io/version: stable

# ------------------------------
# -- 고정 canary 구성, private접근
# -- release name http-echo-canary
appName: http-echo
appVersion: canary
serviceVersionSelector: true
# -- 생성된 selector 결과
kind: Service
  ...
  selector:
    app.kubernetes.io/name: http-echo
    app.kubernetes.io/version: canary
```

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.5.0](https://github.com/norwoodj/helm-docs/releases/v1.5.0)