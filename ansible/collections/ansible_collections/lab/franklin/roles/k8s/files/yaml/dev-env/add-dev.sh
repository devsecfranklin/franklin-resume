#/bin/bash

#set -o nounset  # Treat unset variables as an error

#Black        0;30     Dark Gray     1;30
#Red          0;31     Light Red     1;31
#Green        0;32     Light Green   1;32
#Brown/Orange 0;33     Yellow        1;33
#Blue         0;34     Light Blue    1;34
#Purple       0;35     Light Purple  1;35
#Cyan         0;36     Light Cyan    1;36
#Light Gray   0;37     White         1;37

RED='\033[0;31m'
#LRED='\033[1;31m'
#LGREEN='\033[1;32m'
CYAN='\033[0;36m'
#LPURP='\033[1;35m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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
  namespace: "${ns}"
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

echo "### ------------------- ###"
kubectl get resourcequota -n ${ns}
