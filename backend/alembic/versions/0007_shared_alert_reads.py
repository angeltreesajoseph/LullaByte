"""Persist per-recipient shared alert read status independently of push delivery."""
from alembic import op
import sqlalchemy as sa

revision = '0007_shared_alert_reads'
down_revision = '0006_shared_activity'
branch_labels = None
depends_on = None

def upgrade():
    op.add_column('care_deliveries', sa.Column('read_at', sa.DateTime(timezone=True), nullable=True))

def downgrade():
    op.drop_column('care_deliveries', 'read_at')
