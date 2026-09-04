# Junior Full Stack AWS & DevOps Challenge

Aplicação full stack desenvolvida no âmbito de um desafio técnico para uma posição júnior.

A aplicação permite ao utilizador carregar num botão e obter uma mensagem armazenada numa base de dados PostgreSQL.

## Arquitetura

```text
Browser
   ↓
Frontend (React + Nginx)
   ↓
Backend API (Node.js)
   ↓
PostgreSQL
```

Na AWS, o frontend e o backend são executados em Amazon EKS, enquanto a base de dados PostgreSQL é executada em Amazon RDS.

O backend possui 2 réplicas Kubernetes.

## Tecnologias

- React + TypeScript
- Node.js + TypeScript
- PostgreSQL
- Docker
- Nginx
- Kubernetes
- Amazon EKS
- Amazon ECR
- Amazon RDS
- AWS Secrets Manager
- Terraform
- GitHub

## Estrutura

```text
junior-fullstack-challenge/
├── backend/
├── database/
├── frontend/
├── kubernetes/
├── terraform/
├── docker-compose.yml
└── README.md
```

## Execução local

Criar o ficheiro `.env`:

```powershell
Copy-Item .env.example .env
```

Iniciar a aplicação:

```bash
docker compose up -d --build
```

Abrir:

```text
http://localhost:8080
```

Ao carregar em **Obter mensagem**, deverá aparecer:

```text
Hello from PostgreSQL!
```

Para parar:

```bash
docker compose down
```

## Infraestrutura AWS

A infraestrutura AWS é gerida através de Terraform.

```bash
cd terraform
terraform init
terraform validate
terraform plan
terraform apply
```

A infraestrutura inclui:

- VPC e subnets
- Amazon EKS
- Amazon ECR
- Amazon RDS PostgreSQL
- Security Groups
- AWS Secrets Manager
- IAM e EKS Pod Identity

## Publicação das imagens

As imagens Docker do frontend e backend são publicadas no Amazon ECR.

Exemplo:

```bash
docker build -t junior-fullstack-frontend ./frontend
docker build -t junior-fullstack-backend ./backend
```

Depois da autenticação no ECR, as imagens podem ser identificadas com o endereço do respetivo repositório e publicadas através de:

```bash
docker push <FRONTEND_ECR_URL>:<TAG>
docker push <BACKEND_ECR_URL>:<TAG>
```

## Kubernetes

Configurar o acesso ao cluster:

```bash
aws eks update-kubeconfig --region eu-south-2 --name junior-fullstack-eks
```

Aplicar os manifests:

```bash
kubectl apply -f kubernetes/backend.yaml
kubectl apply -f kubernetes/frontend.yaml
```

Verificar os pods:

```bash
kubectl get pods
```

Para testar o frontend sem exposição pública:

```bash
kubectl port-forward service/frontend 8081:80
```

Abrir:

```text
http://localhost:8081
```

## Segurança

As credenciais da base de dados não são armazenadas no código.

A password do PostgreSQL é gerida pelo Amazon RDS e armazenada no AWS Secrets Manager.

O backend utiliza EKS Pod Identity e uma IAM Role com acesso apenas ao secret necessário.

A base de dados RDS encontra-se em subnets privadas e não é publicamente acessível.

## Estado atual

Implementado:

- Aplicação React + Node.js
- PostgreSQL
- Docker
- Terraform
- Amazon EKS
- Amazon ECR
- Amazon RDS
- Kubernetes
- 2 réplicas do backend
- Health checks
- AWS Secrets Manager
- EKS Pod Identity

As restantes funcionalidades do desafio, incluindo CI/CD, HTTPS, CloudWatch e alarmes, serão adicionadas nas fases seguintes.