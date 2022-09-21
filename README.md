# Service chart

> Current default cluster: **circuit-1**

This the helm chart definition for Circuit's services running in Kubernetes. It follows the deployment pattern using [github pages](https://helm.sh/docs/howto/chart_releaser_action/).

## Configuration

Use the chart as dependency to declare a new service:

```diff
apiVersion: v2
name: service-template
version: 0.0.1
dependencies:
+ - name: service
+   version: "1.*.*"
+   repository: "https://getcircuit.github.io/service-chart"
```

The service should be configured at `values.yaml`, here's its API:

### `Service`

| Field        | Description                                                       | Type          | Required | Default                                                   |
| ------------ | ----------------------------------------------------------------- | ------------- | -------- | --------------------------------------------------------- |
| name         | Service name                                                      | string        | true     | N/A                                                       |
| repo         | Container image repo address (final image url will be: repo/name) | string        | false    | europe-west2-docker.pkg.dev/circuit-api-284012/getcircuit |
| imageName    | Overrides default image name (service name)                       | string        | false    | N/A                                                       |
| cluster      | Cluster to deploy the service to                                  | string        | false    | circuit-1                                                 |
| environments | Service environments definition                                   | Environment[] | false    | []                                                        |

### `Environment`

| Field           | Description                                                                                                                                                                                                                                   | Type                    | Required                             | Default                                |
| --------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------- | ------------------------------------ | -------------------------------------- |
| name            | Environment name (defines environment host: {{environment-name}}.{{service-name}}.{{cluster-id}}.getcircuit.io                                                                                                                                | string                  | true (if `production` is not `true`) | N/A                                    |
| port            | Port number the container will expose                                                                                                                                                                                                         | number                  | false                                | 8080                                   |
| production      | Defines if the environment is production. Production host is {{service-name}}.{{cluster-id}}.getcircuit.io. A production environment does not require a name (its name will be the service name). **Only one environment can be production**. | bool                    | false                                | false                                  |
| minReplicas     | Minimum number of service horizontal replicas                                                                                                                                                                                                 | number                  | false                                | 1                                      |
| maxReplicas     | Maximum number of service horizontal replicas                                                                                                                                                                                                 | number                  | false                                | 10                                     |
| version         | Version id from the image repo                                                                                                                                                                                                                | string                  | false                                | latest                                 |
| targetCPU       | Average CPU usage in percentage before the autoscaler decides it needs to scale up                                                                                                                                                            | number                  | false                                | 50                                     |
| public          | Defines whether a public host should be provided for the service or not                                                                                                                                                                       | bool                    | false                                | true                                   |
| env             | Defines environment's env vars                                                                                                                                                                                                                | map[string]string       | false                                | N/A                                    |
| secret          | Service secret's properties                                                                                                                                                                                                                   | Secret                  | false                                | N/A                                    |
| volumes         | Volumes properties                                                                                                                                                                                                                            | Volume                  | false                                | N/A                                    |
| config          | Service config's properties                                                                                                                                                                                                                   | Config                  | false                                | N/A                                    |
| resources       | Defines environment's resources                                                                                                                                                                                                               | Resources               | false                                | See Resources                          |
| metrics         | Defines metric scraping                                                                                                                                                                                                                       | Metrics                 | false                                | N/A                                    |
| customDomain    | A custom domain that is going the server should respond (this field is not automatic, a DNS rule must be set)                                                                                                                                 | string                  | false                                | N/A                                    |
| rolloutStrategy | Defines custom [rollout strategy steps](https://argoproj.github.io/argo-rollouts/features/canary/)                                                                                                                                            | See link in description | false                                | Every 30s increase 1/5/10/25/50/75/100 |

### `Volume`

| Field   | Description                                            | Type   | Required | Default |
| ------- | ------------------------------------------------------ | ------ | -------- | ------- |
| secrets | List of secrets to me mounted as a volume on the image | Secret | false    | N/A     |

### `Secret`

Either:

| Field | Description                                          | Type        | Required | Default |
| ----- | ---------------------------------------------------- | ----------- | -------- | ------- |
| name  | Name of the secret to be mounted, must already exist | String      | true     | N/A     |
| path  | The path to mount the secret on                      | String      | true     | N/A     |
| items | List of secret keys to mount                         | SecretItems | true     | N/A     |

Or:

| Field      | Description                                                              | Type       | Required | Default |
| ---------- | ------------------------------------------------------------------------ | ---------- | -------- | ------- |
| name       | Name of the secret to be mounted, must already exist                     | String     | true     | N/A     |
| path       | The path to mount the secret on                                          | String     | true     | N/A     |
| file       | The file, under the provided path, to mount the secret on                | String     | true     | N/A     |
| fromRemote | Map with name and version of the secret on the remote GCP Secret Manager | FromRemote | true     | N/A     |

### `FromRemote`

| Field   | Description                                   | Type   | Required | Default |
| ------- | --------------------------------------------- | ------ | -------- | ------- |
| name    | Name of the secret key on GCPSM to be mounted | String | true     | N/A     |
| version | Version of the secret on GCPSM to be mounted  | Number | true     | N/A     |

### `SecretItems`

| Field | Description                          | Type   | Required | Default |
| ----- | ------------------------------------ | ------ | -------- | ------- |
| name  | Name of the secret key to be mounted | String | true     | N/A     |
| path  | The file to mount the secret on      | String | true     | N/A     |

### `Config`

| Field | Description                                                                                                                 | Type   | Required | Default |
| ----- | --------------------------------------------------------------------------------------------------------------------------- | ------ | -------- | ------- |
| name  | Name of the config will be created (the config will be available for the service at path: /etc/config/{{config-name.yaml}}) | Secret | true     | N/A     |
| data  | Config yaml                                                                                                                 | map    | true     | N/A     |

### `Metrics`

| Field    | Description                                                                                                                              | Type   | Required | Default |
| -------- | ---------------------------------------------------------------------------------------------------------------------------------------- | ------ | -------- | ------- |
| enabled  | If metric scraping should be enabled. Only use this if your app [was instrumented](https://prometheus.io/docs/instrumenting/clientlibs/) | bool   | false    | false   |
| interval | What interval the metrics should be scraped (e.g 10s)                                                                                    | string | false    | 15s     |

### `Resources`

| Field    | Description                                                                 | Type     | Required | Default      |
| -------- | --------------------------------------------------------------------------- | -------- | -------- | ------------ |
| requests | Defines the minimum resources that the environment requires to properly run | Resource | false    | See Resource |
| limits   | Defines the service's node usage limits                                     | Resource | false    | See Resource |

### `Resource`

| Field  | Description                           | Type   | Required | Default                            |
| ------ | ------------------------------------- | ------ | -------- | ---------------------------------- |
| cpu    | Amount of CPU in milicores (e.g 500m) | string | false    | For limit: 500m For requests: N/A  |
| memory | Amount of memory (e.g 512Mi)          | string | false    | For limit: 512Mi For requests: N/A |

### `env`

If the `env` value is a `map` with the values `fromSecret.name` and
`fromSecret.version` then the Chart will create a Kubernetes secret which
retrieves this secret from GCP Secret Manager and makes it available on the
container as an environment variable.

## Example configuration values.yaml

all fields:

```yaml
service:
  environments:
  - env:
      TEST_ENV: Example env var
    metrics:
      enabled: true
      interval: 10s
    minReplicas: 1
    maxReplicas: 5
    port: 3000
    production: true
    version: v0.0.2
    targetCPU: 80
    production: true
    public: true
    resources:
      requests:
        cpu: 500m
        memory: 512Mi
      limits:
        cpu: 1
        memory: 1Gi
   - env:
      TEST_ENV: Staging env var
    metrics:
      enabled: true
      interval: 60s
    minReplicas: 1
    maxReplicas: 5
    port: 3000
    production: false
    name: staging
    version: v0.0.2
    targetCPU: 95
    production: false
    public: true
    resources:
      requests:
        cpu: 200m
        memory: 64Mi
      limits:
        cpu: 500m
        memory: 256Mi
  name: service-template
```

minimal:

```yaml
service:
  name: service-template
  environments:
    - name: staging
    - production: true
```
