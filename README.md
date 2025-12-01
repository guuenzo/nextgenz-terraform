# ☁️ TCC - Infraestrutura Cloud NextGenZ

![Terraform](https://img.shields.io/badge/Terraform-v1.0+-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-Cloud-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)
![SENAI](https://img.shields.io/badge/Instituição-SENAI-red?style=for-the-badge)

Este repositório contém o código de **Infraestrutura como Código (IaC)** desenvolvido como **Trabalho de Conclusão de Curso (TCC)** na unidade **SENAI Paulo Antonio Skaf**.

A problemática e o cenário técnico foram propostos pela empresa parceira **Darede**, desafiando os alunos a arquitetarem uma solução robusta de migração para a nuvem AWS.

---

## 🚩 O Desafio: Case "NextGenZ"

A **Darede** apresentou o cenário da empresa fictícia **NextGenZ**, que buscava modernizar suas aplicações legadas.

**Cenário Proposto:**
A NextGenZ operava com aplicações monolíticas on-premise, enfrentando:
* Dificuldade de escalabilidade vertical e horizontal.
* Altos custos operacionais e riscos elevados de indisponibilidade.
* Processos manuais de infraestrutura.

**Objetivo do TCC:**
Projetar e provisionar uma infraestrutura na AWS que garantisse alta disponibilidade, segurança e automação, utilizando práticas de DevOps e IaC.

---

## 🏗️ Arquitetura da Solução

A solução foi desenvolvida seguindo os pilares do *AWS Well-Architected Framework*, focando em resiliência e segurança.

### Stack Tecnológica

| Componente | Tecnologia | Descrição |
| :--- | :--- | :--- |
| **IaC** | Terraform | Provisionamento automatizado e modular de todo o ambiente. |
| **Cloud** | AWS | Provedor de nuvem escolhido para a migração. |
| **Rede** | VPC | Segmentação de rede com subnets Públicas e Privadas em Multi-AZ. |
| **Banco de Dados** | Amazon RDS | Banco relacional gerenciado, isolado em subnets privadas. |
| **Segurança** | AWS WAF & IAM | Proteção contra exploits web e controle granular de acesso. |
| **Gestão de Segredos** | Secrets Manager | Rotação e armazenamento seguro de credenciais (sem hardcode). |
| **Containers** | Amazon ECR | Repositório privado para imagens Docker da aplicação. |

---

## 📦 Estrutura dos Módulos

O código (`main.tf`) orquestra módulos customizados e remotos para compor o ambiente:

### 1. Networking & Identidade
* **Networking:** Criação da VPC `nextgenz` (CIDR `172.16.0.0/16`) com alta disponibilidade distribuída entre zonas `a` e `b`.
* **IAM:** Definição de Roles (ClusterRole e NodeRole) essenciais para a futura implementação de Kubernetes (EKS).

### 2. Dados e Persistência
* **Database:** Instância RDS (`db.t3.micro`) configurada para eficiência de custo, com retenção de backup de 7 dias.
* **Secrets Manager:** Gerenciamento da senha do banco (`nextgenz-rds`), injetando a credencial diretamente no módulo de banco de dados.

### 3. Segurança e Aplicação
* **WAF (Web Application Firewall):** Web ACL regional para filtragem de tráfego malicioso.
* **ECR:** Registry criado para armazenar os artefatos da aplicação migrada.

> ℹ️ **Nota:** A estrutura está preparada para receber o cluster Kubernetes (EKS). Os módulos de orquestração (`eks`, `alb_controller`, `argocd`, `keda`) constam no código, mas estão comentados para permitir uma entrega faseada da infraestrutura.

---

## 🚀 Como Executar o Projeto

### Pré-requisitos
* [Terraform CLI](https://www.terraform.io/) instalado.
* AWS CLI configurado com credenciais válidas.

### Passos

1.  **Clone o repositório:**
    ```bash
    git clone <url-do-repositorio>
    cd <nome-da-pasta>
    ```

2.  **Inicialize o Terraform:**
    ```bash
    terraform init
    ```

3.  **Planeje a Infraestrutura:**
    ```bash
    terraform plan -out=tfplan
    ```

4.  **Aplique a Configuração:**
    ```bash
    terraform apply tfplan
    ```

---

## 🎓 Créditos e Parcerias

**Instituição de Ensino:** SENAI Paulo Antonio Skaf  
**Empresa Parceira (Proponente do Desafio):** Darede  
**Desenvolvedor(es):** [Seu Nome Aqui]

---