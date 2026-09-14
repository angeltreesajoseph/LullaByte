"""Create users and babies tables.

Revision ID: 0001_initial_identity
Revises:
"""

from alembic import op
import sqlalchemy as sa

revision = "0001_initial_identity"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "users",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("firebase_uid", sa.String(length=128), nullable=True),
        sa.Column("email", sa.String(length=320), nullable=True),
        sa.Column("display_name", sa.String(length=160), nullable=True),
        sa.Column("is_active", sa.Boolean(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("email"),
        sa.UniqueConstraint("firebase_uid"),
    )
    op.create_table(
        "babies",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("owner_user_id", sa.Uuid(), nullable=False),
        sa.Column("name", sa.String(length=120), nullable=False),
        sa.Column("birth_date", sa.Date(), nullable=True),
        sa.Column("gender", sa.String(length=32), nullable=True),
        sa.Column("birth_weight_kg", sa.Numeric(precision=5, scale=2), nullable=True),
        sa.Column("birth_length_cm", sa.Numeric(precision=5, scale=2), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["owner_user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_babies_owner_user_id", "babies", ["owner_user_id"])


def downgrade() -> None:
    op.drop_index("ix_babies_owner_user_id", table_name="babies")
    op.drop_table("babies")
    op.drop_table("users")

