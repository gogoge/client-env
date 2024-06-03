# istioctl
curl -sL https://istio.io/downloadIstioctl | sh -
export PATH=$HOME/.istioctl/bin:$PATH

kubectl create ns istio-system
istioctl install --set profile=minimal -y
