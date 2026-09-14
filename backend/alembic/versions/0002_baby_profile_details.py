"""Add persisted baby profile detail fields."""
from alembic import op
import sqlalchemy as sa

revision = "0002_baby_profile_details"
down_revision = "0001_initial_identity"
branch_labels = None
depends_on = None

def upgrade() -> None:
    for name, typ in (("blood_group", sa.String(16)), ("allergies", sa.String(500)), ("pediatrician", sa.String(160)), ("hospital", sa.String(160)), ("head_circumference_cm", sa.Numeric(5, 2))):
        op.add_column("babies", sa.Column(name, typ, nullable=True))

def downgrade() -> None:
    for name in ("head_circumference_cm", "hospital", "pediatrician", "allergies", "blood_group"):
        op.drop_column("babies", name)
