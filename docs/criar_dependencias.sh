#!/bin/bash

# Verifica se o script está sendo executado com privilégios de superusuário
if [ "$(id -u)" -ne "0" ]; then
    echo "Este script deve ser executado como root ou com sudo."
    exit 1
fi

# Atualizando repositórios e atualizando pacotes...
echo "Atualizando repositórios e atualizando pacotes..."

apt update && apt upgrade -y

#Instalando pacotes e dependências necessárias...
echo "Instalando pacotes e dependências necessárias..."

apt install -y apt-transport-https ca-certificates curl gnupg lsb-release openssl

# Instala Docker
echo "Instalando o Docker..."

# Adiciona o repositório oficial do Docker
curl -fsSL https://download.docker.com/linux/$(lsb_release -cs)/gpg | sudo apt-key add -
echo "deb [arch=amd64] https://download.docker.com/linux/$(lsb_release -cs) $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instala o Docker
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
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/
#!/bin/bash

# Verifica se o script está sendo executado com privilégios de superusuário
if [ "$(id -u)" -ne "0" ]; then
    echo "Este script deve ser executado como root ou com sudo."
    exit 1
fi

# Atualizando repositórios e atualizando pacotes...
echo "Atualizando repositórios e atualizando pacotes..."

apt update && apt upgrade -y

#Instalando pacotes e dependências necessárias...
echo "Instalando pacotes e dependências necessárias..."

apt install -y apt-transport-https ca-certificates curl gnupg lsb-release openssl

# Instala Docker
echo "Instalando o Docker..."

# Adiciona o repositório oficial do Docker
curl -fsSL https://download.docker.com/linux/$(lsb_release -cs)/gpg | sudo apt-key add -
echo "deb [arch=amd64] https://download.docker.com/linux/$(lsb_release -cs) $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instala o Docker
apt install -y docker-ce docker-ce-cli containerd.io

# Adiciona o usuário atual ao grupo docker (necessário para rodar o Docker sem sudo)
usermod -aG docker $USER

# Verifica se o Docker está instalado corretamente
docker --version

# Instala o Kubernetes (kind e kubectl)
echo "Instalando o kind e o kubectl..."

# Baixa e instala o kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-amd64
chmod +x ./kind
mv ./kind /usr/local/bin/

# Baixa e instala o kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/

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

git clone https://github.com/prometheus-operator/kube-prometheus
cd kube-prometheus
kubectl create -f manifests/setup
cd ..
echo "Instalação do Prometheus concluída!"
echo "Instalação concluída!"

# Atualiza o repositório de charts do Helm
echo "Atualizando o repositório de charts do Helm..."
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update

# Instala o Kyverno usando Helm
echo "Instalando o Kyverno..."
helm install kyverno kyverno/kyverno -n kyverno --create-namespace \
--set admissionController.replicas=3 \
--set backgroundController.replicas=2 \
--set cleanupController.replicas=2 \
--set reportsController.replicas=2

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

# Criando namespace do giropops senhas
Echo "Criando namespace giropops-senhas..."
kubectl create namespace giropops-senhas
kubectl get namespaces giropops-senhas

# Criando certificado
echo "Gerando chaves do certificado..." 
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout chave-privada.key -out certificado.crt

# Crie uma chave privada
openssl genrsa -out ca.key 2048

# Crie um certificado autoassinado
openssl req -new -x509 -key giropops-senhas-autoassinado.key -out giropops-senhas-autoassinado.crt -days 365 -subj /CN=localhost

# Criando secret no kubernetes
kubectl create secret tls giropops-senhas-as-secret --cert=giropops-senhas-autoassinado.crt --key=giropops-senhas-autoassinado.key --namespace giropops-senhas

helm repo add jetstack https://charts.jetstack.io
helm repo update

# Cria um namespace para o cert-manager
echo "Criando o namespace 'cert-manager'..."
kubectl create namespace cert-manager

# Instala o cert-manager usando Helm
echo "Instalando o cert-manager..."
helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.11.0 --set installCRDs=true

# Verifica se o cert-manager foi instalado corretamente
echo "Verificando o status da instalação..."
helm list --namespace cert-manager

# Verifica o status dos pods e serviços
echo "Verificando o status dos pods e serviços no namespace 'cert-manager'..."
kubectl get pods --namespace cert-manager
kubectl get services --namespace cert-manager

echo "Instalação do cert-manager concluída!"

# Instalação do Cosign

echo "Instalando Cosign..."
curl -O -L "https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64"
sudo mv cosign-linux-amd64 /usr/local/bin/cosign
sudo chmod +x /usr/local/bin/cosign

echo "Cosign instalado!"

# Define o domínio e o IP
DOMAIN="giropops-senhas.local"
IP="127.0.0.1"

# Adiciona a entrada ao /etc/hosts se não existir
if ! grep -q "$DOMAIN" /etc/hosts; then
    echo "Adicionando $DOMAIN com IP $IP ao /etc/hosts"
    echo "$IP $DOMAIN" >> /etc/hosts
else
    echo "A entrada para $DOMAIN já existe no /etc/hosts"
fi
# Verifica as versões instaladas
kind --version
kubectl version --client
