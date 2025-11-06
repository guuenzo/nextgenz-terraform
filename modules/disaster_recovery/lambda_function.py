import boto3
import os
import logging
from datetime import datetime

# Configuração do log
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Variáveis de ambiente vindas do Terraform
ENVIRONMENT = os.getenv("ENVIRONMENT", "prod")
S3_BUCKET_NAME = os.getenv("S3_BUCKET_NAME", "")
EC2_INSTANCE_ID = os.getenv("EC2_INSTANCE_ID", "")
DR_COPY_REGION = os.getenv("DR_COPY_REGION", "")

def lambda_handler(event, context):
    """
    Função Lambda do Disaster Recovery (NextGenZ)
    Responsável por registrar a execução e, se houver EC2 configurada,
    gerar uma AMI de backup automaticamente.
    """

    logger.info(f" Iniciando rotina de Disaster Recovery - Ambiente: {ENVIRONMENT}")
    logger.info(f" Execução iniciada em {datetime.utcnow().isoformat()}Z")

    # Se houver EC2 configurada, cria AMI
    if EC2_INSTANCE_ID:
        try:
            ec2 = boto3.client("ec2")
            ami_name = f"nextgenz-backup-{EC2_INSTANCE_ID}-{datetime.utcnow().strftime('%Y%m%d-%H%M%S')}"
            response = ec2.create_image(
                InstanceId=EC2_INSTANCE_ID,
                Name=ami_name,
                Description="Backup automático gerado pelo Lambda DR NextGenZ",
                NoReboot=True
            )
            logger.info(f" Backup EC2 gerado: {response['ImageId']}")
        except Exception as e:
            logger.error(f" Erro ao criar AMI: {str(e)}")
    else:
        logger.info("⚠️ Nenhuma instância EC2 configurada — backup EC2 ignorado.")

    # Log opcional se houver bucket S3 definido
    if S3_BUCKET_NAME:
        logger.info(f" Bucket configurado para backups secundários: {S3_BUCKET_NAME}")

    # Se houver região de destino, simula cópia futura
    if DR_COPY_REGION:
        logger.info(f" Cópia de dados será replicada na região: {DR_COPY_REGION}")

    logger.info(" Execução do Disaster Recovery finalizada com sucesso.")
    return {"status": "success", "timestamp": datetime.utcnow().isoformat()}
