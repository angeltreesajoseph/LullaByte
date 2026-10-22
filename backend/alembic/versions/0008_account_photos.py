"""Store private account avatars separately from baby records."""
from alembic import op
import sqlalchemy as sa

revision = '0008_account_photos'
down_revision = '0007_shared_alert_reads'
branch_labels = None
depends_on = None


def upgrade():
    op.create_table('account_photos',
        sa.Column('user_id', sa.Uuid(), sa.ForeignKey('users.id', ondelete='CASCADE'), primary_key=True),
        sa.Column('photo_data', sa.Text(), nullable=False))


def downgrade():
    op.drop_table('account_photos')
