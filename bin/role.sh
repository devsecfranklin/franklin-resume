#/bin/bash

ns="dev-${1}"

if [ "${ns}" == "dev-" ]; then
  echo "Dont forget the username."
  exit 0
fi

echo "Create resource limits for ${1}."

cat <<EOF | kubectl create -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: limit-compute
  namespace: ${ns}
spec:
  hard:
    requests.cpu: "10"
    requests.memory: 100Gi
    limits.cpu: "10"
    limits.memory: 100Gi 
EOF

kubectl create namespace ${ns}
kubectl annotate namespace ${ns} dev=franklin

echo "Create a namespace for ${1}"

cat <<EOF | kubectl create -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ${ns}
  namespace: ${ns}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: edit
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: $(whoami)
EOF
