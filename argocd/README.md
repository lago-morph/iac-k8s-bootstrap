# Creating

Did this:

```
./install.sh
```

Install ArgoCD CLI with:

```
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64
```

Get initial password in one of two ways (they are the same under the hood):

```
argocd admin initial-password -n argocd
```

Or

```
kubectl get secret \
    -n argocd \
    argocd-initial-admin-secret \
    -o jsonpath='{.data.password}' \
    | base64 -d
```
