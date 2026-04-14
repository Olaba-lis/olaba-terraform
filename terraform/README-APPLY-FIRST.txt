1. Replace your current terraform/ folder with this one.
2. Keep Terraform Cloud workspace working directory = terraform
3. Keep your existing workspace variables as-is.
4. Make sure the Cloudflare API token has Zone:DNS:Edit and Zone:Zone:Read permissions.
5. Run a new plan.

Notes:
- This package removes Cloudflare Origin CA creation and uses cert-manager + Let's Encrypt DNS-01 through Cloudflare instead.
- CloudSQL and Backup for GKE default to enabled so Terraform does not try to delete the resources you already created.
- The package installs ingress-nginx and cert-manager via Helm and deploys SENAITE tenants through Terraform.
