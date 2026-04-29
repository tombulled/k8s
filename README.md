# k8s

To install:
* argo
    * argo-cd
    * argo rollouts
    * argo events
    * argo workflows
* harbor
    * harbor
    * harbor satellite
* CNI
    * cilium
* ingress
    * traefik
* monitoring
    * prometheus
    * grafana
    * thanos?
    * loki
* auth
    * keycloak
    * dex?
* certs
    * cert-manager
    * trust-manager
    * self-signed issuer
    * ca issuer
* secrets
    * sealed-secrets
    * sealed-secrets-web
* mattermost
    * mattermost
    * mattermost-operator
    * minio
    * minio-operator
    * postgres
    * postgres-operator
* storage
    * openebs
    * ceph
    * local-path-provisioner / local-volume-provisioner
* ci/cd
    * jenkins

Other:
* kro / crossplane

# Bootstrap
## 1. Create Cluster
```sh
K3D_FIX_DNS=1 k3d cluster create --config cluster.yaml
```

## 2. Create Required Namespaces
```sh
kubectl create namespace sealed-secrets
```

## 3. Install Sealed Secrets Key
```sh
kubectl apply -f secrets/sealed-secrets/secret.yaml -n sealed-secrets
```

```sh
helm install --repo https://argoproj.github.io/argo-helm argo-cd argo-cd --version 9.5.0 -n argocd --create-namespace -f ../values/argo-cd/values.yaml
```

```sh
kubectl -n argocd create secret generic github-ssh --from-literal=url=git@github.com:tombulled --from-file=sshPrivateKey=$HOME/.ssh/id_rsa
kubectl -n argocd label secret github-ssh argocd.argoproj.io/secret-type=repo-creds
```

```sh
kubectl apply -f root.yaml
```

```sh
helm uninstall argo-cd -n argocd
```

```sh
while :; do kubectl port-forward service/argocd-server -n argocd 8080:443; sleep 1; done
```

```sh
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

```sh
helm upgrade --repo https://argoproj.github.io/argo-helm argo-cd argo-cd --version 9.5.0 -n argocd -f values/argo-cd/values.yaml
```

# Sealed Secrets
## Encrypt
```sh
kubeseal --cert secrets/sealed-secrets/tls.crt -f secrets/argocd/argocd-secret.yaml -o yaml
```
