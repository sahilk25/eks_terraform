aws eks update-kubeconfig --region $REGION_NAME --name $CLUSTER_NAME

eksctl create iamserviceaccount \
  --cluster=$CLUSTER_NAME \
  --namespace=$NAMESPACE \
  --name=aws-load-balancer-controller \
  --attach-policy-arn $LOADBALANCER_POLICY_ARN \
  --override-existing-serviceaccounts \
  --approve

eksctl create iamserviceaccount \
    --name efs-csi-controller-sa \
    --namespace $NAMESPACE \
    --cluster $CLUSTER_NAME \
    --attach-policy-arn $EFS_POLICY_ARN \
    --approve \
    --override-existing-serviceaccounts \
    --region $REGION_NAME

eksctl create iamserviceaccount \
  --cluster= $CLUSTER_NAME \
  --namespace=kube-system \
  --name=cluster-autoscaler \
  --attach-policy-arn= $AUTOSCALER_POLICY_ARN \
  --override-existing-serviceaccounts \
  --approve

kubectl apply -f ./jenkins/cluster-autoscaler-autodiscover.yaml

kubectl patch deployment cluster-autoscaler \
  -n kube-system \
  -p '{"spec":{"template":{"metadata":{"annotations":{"cluster-autoscaler.kubernetes.io/safe-to-evict": "false"}}}}}'