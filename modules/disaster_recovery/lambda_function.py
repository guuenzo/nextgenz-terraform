import boto3
import os
import logging
from datetime import datetime

# Configuração do log
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Variáveis de ambiente vindas do Terraform
ENVIRONMENT = os.getenv("ENVIRONMENT")
RDS_INSTANCE_ID = os.getenv("RDS_INSTANCE_ID")
DR_COPY_REGION = os.getenv("DR_COPY_REGION")

def lambda_handler(event, context):
    timestamp = datetime.utcnow().strftime("%Y%m%d-%H%M%S")
    snapshot_id = f"nextgenz-snap-{RDS_INSTANCE_ID}-{timestamp}"

    rds = boto3.client("rds")
    logger.info(f"Criando snapshot manual: {snapshot_id}")

    # Criar snapshot manual do RDS
    rds.create_db_snapshot(
        DBSnapshotIdentifier=snapshot_id,
        DBInstanceIdentifier=RDS_INSTANCE_ID
    )

    logger.info(f"Snapshot {snapshot_id} criado com sucesso")

    # Copiar snapshot para a região secundária
    logger.info(f"Copiando snapshot para região de DR: {DR_COPY_REGION}")

    rds_dr = boto3.client("rds", region_name=DR_COPY_REGION)

    copied_snapshot_id = f"{snapshot_id}-copy"

    rds_dr.copy_db_snapshot(
        SourceDBSnapshotIdentifier=f"arn:aws:rds:{os.getenv('AWS_REGION')}:{os.getenv('AWS_ACCOUNT_ID')}:snapshot:{snapshot_id}",
        TargetDBSnapshotIdentifier=copied_snapshot_id,
        SourceRegion=os.getenv("AWS_REGION")
    )

    logger.info(f"Snapshot copiado para região de DR: {copied_snapshot_id}")

    return {
        "status": "ok",
        "snapshot_primary": snapshot_id,
        "snapshot_copy": copied_snapshot_id
    }

















