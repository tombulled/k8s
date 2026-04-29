#!/bin/sh

# Generate TLS Cert & Key
openssl req \
    -new \
    -newkey rsa:4096 \
    -days 3650 \
    -nodes \
    -x509 \
    -subj "/" \
    -keyout tls.key \
    -out tls.crt

# Generate Secret YAML
kubectl create \
    secret \
    tls \
    sealed-secrets-key \
    -n sealed-secrets \
    --cert=tls.crt \
    --key=tls.key \
    --dry-run=client \
    -o yaml | \
        kubectl label \
            -f - \
            --local \
            sealedsecrets.bitnami.com/sealed-secrets-key=active \
            --dry-run=client \
            -o yaml \
            > secret.yaml
