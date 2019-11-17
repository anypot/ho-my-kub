#!/bin/bash

usage() { echo "Usage: $0 <-c create | -d destroy> [-h]"; }

while getopts "hcd" option; do
    case "${option}" in
        h) usage && exit 0;;
	c) ACTION=create;;
	d) ACTION=destroy;;
        *) usage && exit 1;;
    esac
done

BASEDIR=$(dirname $(readlink -f $0))
INFRADIR=$BASEDIR/k8s_infra
HELMDIR=$BASEDIR/helm
. $BASEDIR/setup

case $PROVIDER in
    digitalocean) TFVARS=k8s_infra_do.tfvars;;
    *) echo "$PROVIDER is not a supported provider!" && usage && exit 1;;
esac

[[ ! -f $TFVARS ]] && echo "Terraform variables file $TFVARS not found !" && exit 1

if [[ $ACTION == "destroy" ]]; then
    # PROTIP TO DESTROY CLOUD MANAGED LB
    echo "Deleting the ingress controller"
    kubectl delete service traefik --namespace kube-system
    echo "Destroying Kubernetes cluster in $PROVIDER with Terraform"
    cd $INFRADIR/$PROVIDER &&
    terraform destroy -var "do_token=$TOKEN" -var-file="$TFVARS" || exit 1
    exit 0
fi

if [[ $ACTION == "create" || $ACTION == "terraform" ]]; then
    echo "Building Kubernetes cluster in $PROVIDER with Terraform"
    cd $INFRADIR/$PROVIDER &&
    terraform init &&
    terraform plan -var "do_token=$TOKEN" -var-file="$TFVARS" &&
    terraform apply -var "do_token=$TOKEN" -var-file="$TFVARS" || exit 1
fi

if [[ $ACTION == "create" || $ACTION == "init_helm" ]]; then
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash || exit 1
    helm repo add stable https://kubernetes-charts.storage.googleapis.com/
    helm repo update
    envsubst < $HELMDIR/traefik/values.tpl.yaml > $HELMDIR/traefik/values.yaml
    helm upgrade --install traefik --namespace kube-system --values $HELMDIR/traefik/values.yaml stable/traefik || exit 1
    external_ip=""
    while [ -z $external_ip ]; do
      echo "Waiting for end point..."
      external_ip=$(kubectl get svc traefik --namespace=kube-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
      [[ -z $external_ip ]] && sleep 10
    done
    echo 'Endpoint ready:' && echo $external_ip
    # DNS terraform  type A name * value $external_ip
    #kubectl run test --image=mendhak/http-https-echo --port 80
    #kubectl expose deployment test --type=ClusterIP
    #kubectl apply -f $BASEDIR/k8s_deployments/manifests/ingress.yaml
fi

exit 0
