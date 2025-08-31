This is still a little rough.

Run the shell script to create the TLS cert early on in the process, as it can take a while.

Provision the cluster, nodes, and addons using the `create_cluster.sh` script.

Edit the file `lb_config/icp.yaml` to have the right ARN from the cert requested in the first step.  Apply both `icp.yaml` and `ic.yaml`.

Edit the file `../tests/nginx/ingress.yaml` to make the `host` field correspond to the DNS name with the current environment.  Then apply (in that same directory) `nginx.yaml`, `service.yaml`, and `ingress.yaml`.  After a bit, you should be able to get to the nginx service through the load balancer at the DNS name registered.  Yay!
