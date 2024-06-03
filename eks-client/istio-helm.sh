helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update

kubectl create namespace istio-ingress
helm install istio-ingress istio/gateway -n istio-ingress \
  --set labels.istio=ingressgateway \
  --set service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-type"="external" \
  --set service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-nlb-target-type"="ip" \
  --set service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-scheme"="internet-facing" \
  --set service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-attributes"="load_balancing.cross_zone.enabled=true" \
  --wait
