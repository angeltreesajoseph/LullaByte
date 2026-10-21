"""Optional per-baby care contact numbers."""
from alembic import op
import sqlalchemy as sa
revision = '0005_care_contacts'
down_revision = '0004_baby_sharing'
branch_labels = None
depends_on = None

def upgrade():
    op.add_column('babies', sa.Column('parent_phone', sa.String(32), nullable=True))
    op.add_column('babies', sa.Column('pediatrician_phone', sa.String(32), nullable=True))

def downgrade():
    op.drop_column('babies', 'pediatrician_phone')
    op.drop_column('babies', 'parent_phone')
