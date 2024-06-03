helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update

kubectl create namespace istio-ingress
helm install istio-ingress istio/gateway -n istio-ingress --wait
