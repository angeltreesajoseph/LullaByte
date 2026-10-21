"""Shared-care activity, chat and push registration/delivery."""
from alembic import op
import sqlalchemy as sa
revision = '0006_shared_activity'
down_revision = '0005_care_contacts'
branch_labels = None
depends_on = None

def upgrade():
    op.create_table('care_activity',
        sa.Column('id', sa.Integer(), primary_key=True, autoincrement=True),
        sa.Column('baby_id', sa.Uuid(), sa.ForeignKey('babies.id', ondelete='CASCADE'), nullable=False),
        sa.Column('actor_user_id', sa.Uuid(), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False),
        sa.Column('actor_name', sa.String(160), nullable=False),
        sa.Column('kind', sa.String(32), nullable=False),
        sa.Column('summary', sa.String(240), nullable=False),
        sa.Column('message', sa.Text()), sa.Column('client_id', sa.String(64)),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.UniqueConstraint('baby_id', 'actor_user_id', 'client_id', name='uq_care_message_retry'))
    op.create_index('ix_care_activity_baby_id', 'care_activity', ['baby_id'])
    op.create_index('ix_care_activity_created_at', 'care_activity', ['created_at'])
    op.create_table('care_devices',
        sa.Column('token', sa.String(4096), primary_key=True),
        sa.Column('registered_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('user_id', sa.Uuid(), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False))
    op.create_index('ix_care_devices_user_id', 'care_devices', ['user_id'])
    op.create_table('care_deliveries',
        sa.Column('id', sa.Integer(), primary_key=True, autoincrement=True),
        sa.Column('activity_id', sa.Integer(), sa.ForeignKey('care_activity.id', ondelete='CASCADE'), nullable=False),
        sa.Column('user_id', sa.Uuid(), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False),
        sa.Column('sent', sa.Boolean(), nullable=False),
        sa.Column('attempts', sa.Integer(), nullable=False),
        sa.Column('last_attempt', sa.DateTime(timezone=True)),
        sa.UniqueConstraint('activity_id', 'user_id', name='uq_care_delivery'))
    op.create_index('ix_care_deliveries_activity_id', 'care_deliveries', ['activity_id'])

def downgrade():
    op.drop_table('care_deliveries')
    op.drop_table('care_devices')
    op.drop_table('care_activity')
