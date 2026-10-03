"""Persist compressed baby profile photos."""
from alembic import op
import sqlalchemy as sa

revision = '0003_baby_photo'
down_revision = '0002_baby_profile_details'
branch_labels = None
depends_on = None

def upgrade():
    op.add_column('babies', sa.Column('photo_data', sa.Text(), nullable=True))
    op.add_column('babies', sa.Column('tracker_data', sa.JSON(), nullable=True))

def downgrade():
    op.drop_column('babies', 'tracker_data')
    op.drop_column('babies', 'photo_data')
