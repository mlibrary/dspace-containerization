# Secret Steps

1. fetch the current secret
```
kubectl -n workshop get secret dspace-cfg -o jsonpath="{.data.dspace\.cfg}" | base64 --decode > from-kube.dspace.cfg
```
2. edit from-kube.dspace.cfg

3. convert it to base64
```
cat from-kube.dspace.cfg | base64 > from-kube.dspace.cfg.base64
```
4.  copy the contents of from-kube.dspace.cfg.base64 into config-secret.yaml

5. reapply the config secret
```
kubectl apply -f config-secret.yaml
```
6. delete and restart the backend pod