#!/bin/bash

apt update && apt upgrade -y
apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Instala Docker
echo "Instalando o Docker..."

# Adiciona o repositório oficial do Docker
curl -fsSL https://download.docker.com/linux/$(lsb_release -cs)/gpg | sudo apt-key add -
echo "deb [arch=amd64] https://download.docker.com/linux/$(lsb_release -cs) $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instala o Docker
apt update
apt install -y docker-ce docker-ce-cli containerd.io

# Adiciona o usuário atual ao grupo docker (necessário para rodar o Docker sem sudo)
usermod -aG docker $USER

# Verifica se o Docker está instalado corretamente
docker --version

# Instala o Kubernetes (kind e kubectl)
echo "Instalando o kind e o kubectl..."

# Baixa e instala o kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.18.0/kind-linux-amd64
chmod +x ./kind
mv ./kind /usr/local/bin/

# Baixa e instala o kubectl
curl -LO "https://dl.k8s.io/release/v1.27.2/bin/linux/amd64/kubectl"
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/

# Verifica as versões instaladas
kind --version
kubectl version --client

# Instala o Helm
echo "Instalando o Helm..."

# Baixa e instala o Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# Verifica a versão do Helm
helm version

# Limpeza
rm get_helm.sh

# Atualiza o repositório de charts do Helm
echo "Atualizando o repositório de charts do Helm..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Cria um namespace para o Prometheus
echo "Criando o namespace 'monitoring'..."
kubectl create namespace monitoring

# Instala o Prometheus usando Helm
echo "Instalando o Prometheus..."
helm install prometheus prometheus-community/prometheus --namespace monitoring

# Verifica se o Prometheus foi instalado corretamente
echo "Verificando o status da instalação..."
helm list --namespace monitoring

echo "Instalação do Prometheus concluída!"
echo "Instalação concluída!"

# Atualiza o repositório de charts do Helm
echo "Atualizando o repositório de charts do Helm..."
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update

# Cria um namespace para o Kyverno
echo "Criando o namespace 'kyverno'..."
kubectl create namespace kyverno

# Instala o Kyverno usando Helm
echo "Instalando o Kyverno..."
helm install kyverno kyverno/kyverno --namespace kyverno

# Verifica se o Kyverno foi instalado corretamente
echo "Verificando o status da instalação..."
helm list --namespace kyverno

echo "Instalação do Kyverno concluída!"

# Atualiza o repositório de charts do Helm
echo "Atualizando o repositório de charts do Helm..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Cria um namespace para o Ingress NGINX
echo "Criando o namespace 'ingress-nginx'..."
kubectl create namespace ingress-nginx

# Instala o Ingress NGINX usando Helm
echo "Instalando o Ingress NGINX..."
helm install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx

# Verifica se o Ingress NGINX foi instalado corretamente
echo "Verificando o status da instalação..."
helm list --namespace ingress-nginx

# Verifica o status dos pods e serviços
echo "Verificando o status dos pods e serviços no namespace 'ingress-nginx'..."
kubectl get pods --namespace ingress-nginx
kubectl get services --namespace ingress-nginx

echo "Instalação do Ingress NGINX concluída!"
