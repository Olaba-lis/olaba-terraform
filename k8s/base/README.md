Apply these shared objects once per cluster:

```bash
kubectl apply -f k8s/base/storageclass-regional.yaml
```

Apply the NetworkPolicies inside each tenant namespace after the namespace exists.
