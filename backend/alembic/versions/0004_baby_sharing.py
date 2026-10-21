"""Per-baby sharing grants."""
from alembic import op
import sqlalchemy as sa
revision = '0004_baby_sharing'
down_revision = '0003_baby_photo'
branch_labels = None
depends_on = None

def upgrade():
    op.create_table('baby_shares',
        sa.Column('id', sa.Uuid(), primary_key=True),
        sa.Column('baby_id', sa.Uuid(), sa.ForeignKey('babies.id', ondelete='CASCADE'), nullable=False),
        sa.Column('email', sa.String(320), nullable=False),
        sa.Column('role', sa.String(20), nullable=False),
        sa.Column('user_id', sa.Uuid(), sa.ForeignKey('users.id', ondelete='CASCADE')),
        sa.Column('expires_at', sa.DateTime(timezone=True), nullable=False),
        sa.UniqueConstraint('baby_id', 'email', name='uq_baby_share_email'),
        sa.UniqueConstraint('baby_id', 'user_id', name='uq_baby_share_user'))
    for column in ('baby_id', 'email', 'user_id'):
        op.create_index('ix_baby_shares_' + column, 'baby_shares', [column])

def downgrade():
    op.drop_table('baby_shares')
