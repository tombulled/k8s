# k8s

To install:
* argo
* harbor
* ingress-nginx vs traefik
* 

```sh
K3D_FIX_DNS=1 k3d cluster create --config cluster.yaml
```

```sh
helm install --repo https://argoproj.github.io/argo-helm argo-cd argo-cd --version 9.4.3 -n argocd --create-namespace -f values/argo-cd/values.yaml
```

```sh
helm uninstall argo-cd -n argocd
```

```sh
while :; do kubectl port-forward service/argo-cd-argocd-server -n argocd 8080:443; sleep 1; done
```

```sh
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

```sh
helm upgrade --repo https://argoproj.github.io/argo-helm argo-cd argo-cd --version 9.4.3 -n argocd -f values/argo-cd/values.yaml
```

```sh
kubectl apply -f argo-cd.yaml
```

```sh
kubectl -n argocd create secret generic github-ssh --from-literal=url=git@github.com:tombulled --from-file=sshPrivateKey=$HOME/.ssh/id_rsa
kubectl -n argocd label secret github-ssh argocd.argoproj.io/secret-type=repo-creds
```