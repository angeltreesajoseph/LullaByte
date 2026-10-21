from pathlib import Path
import runpy
from alembic.migration import MigrationContext
from alembic.operations import Operations
from sqlalchemy import create_engine, inspect

def test_sharing_migration_up_and_down_in_isolated_database():
    migration = runpy.run_path(str(Path(__file__).parents[2] / 'alembic/versions/0004_baby_sharing.py'))
    engine = create_engine('sqlite:///:memory:')
    with engine.begin() as connection:
        with Operations.context(MigrationContext.configure(connection)):
            migration['upgrade']()
            schema = inspect(connection)
            assert 'baby_shares' in schema.get_table_names()
            assert {'baby_id', 'email', 'role', 'user_id', 'expires_at'} <= {c['name'] for c in schema.get_columns('baby_shares')}
            assert len(schema.get_indexes('baby_shares')) == 3
            migration['downgrade']()
            assert 'baby_shares' not in inspect(connection).get_table_names()
    engine.dispose()
