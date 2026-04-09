## Example tenant deployment

This folder shows the recommended pattern for **one lab = one namespace + one ZEO storage + multiple app pods**.

### Before applying

Replace all placeholders:

- `PROJECT_ID`
- image tag
- `REPLACE_WITH_GCP_SSL_CERT_NAME`
- hostnames
- passwords in `01-secrets.example.yaml`

### Apply order

```bash
kubectl apply -f 00-namespace.yaml
kubectl apply -f 02-networkpolicy.yaml
kubectl apply -f 03-zeo-statefulset.yaml
kubectl apply -f 05-backendconfig.yaml
kubectl apply -f 01-secrets.example.yaml
kubectl apply -f 04-web-deployment.yaml
kubectl apply -f 06-ingress.yaml
```

### Notes

- For production, do not store real secrets in git.
- Prefer syncing from Google Secret Manager using your delivery pipeline or an external secrets controller.
- The `plone/plone-zeo` image is used as a practical ZEO baseline. Validate compatibility against your exact SENAITE version.
