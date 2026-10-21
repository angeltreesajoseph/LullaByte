from pathlib import Path
import runpy
from alembic.migration import MigrationContext
from alembic.operations import Operations
from sqlalchemy import create_engine, inspect

def test_activity_migration_up_and_down():
    migration = runpy.run_path(str(Path(__file__).parents[2] / 'alembic/versions/0006_shared_activity.py'))
    engine = create_engine('sqlite:///:memory:')
    with engine.begin() as connection:
        with Operations.context(MigrationContext.configure(connection)):
            migration['upgrade']()
            assert {'care_activity', 'care_devices', 'care_deliveries'} <= set(inspect(connection).get_table_names())
            migration['downgrade']()
            assert inspect(connection).get_table_names() == []
    engine.dispose()
