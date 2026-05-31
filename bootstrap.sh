#!/bin/sh

# 1. Build CLuster
K3D_FIX_DNS=1 k3d cluster create --config cluster.yaml

# 2. Install Gateway API CRDs
helm install \
    gateway-api-crds \
    charts/gateway-api-crds \
    -f ../values/gateway-api-crds/values.yaml

# 3. Install Sealed Secrets
kubectl create namespace sealed-secrets
kubectl apply -f secrets/sealed-secrets/secret.yaml -n sealed-secrets
helm install \
    sealed-secrets \
    sealed-secrets \
    --version 2.18.5 \
    --repo https://bitnami-labs.github.io/sealed-secrets/ \
    -n sealed-secrets \
    -f ../values/sealed-secrets/values.yaml

# 4. Install ArgoCD
helm install \
    argo-cd \
    argo-cd \
    --version 9.5.0 \
    --repo https://argoproj.github.io/argo-helm \
    -n argocd \
    -f ../values/argo-cd/values.yaml \
    --create-namespace

# 5. Install ArgoCD Repo Credential (Not managed via Sealed Secrets for now as the keys are public)
kubectl -n argocd create secret generic github-ssh --from-literal=url=git@github.com:tombulled --from-file=sshPrivateKey=$HOME/.ssh/id_rsa
kubectl -n argocd label secret github-ssh argocd.argoproj.io/secret-type=repo-creds

# 6. Install Root App
kubectl apply -f root.yaml
