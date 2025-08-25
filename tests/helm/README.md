To get admin secret:

`kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d`

Username is `admin`.

Get URL from service `argocd-server-lb`.  Access via HTTP.
