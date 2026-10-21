from pathlib import Path
import runpy
from alembic.migration import MigrationContext
from alembic.operations import Operations
from sqlalchemy import create_engine, inspect, text

def test_contacts_migration_preserves_existing_babies():
    migration = runpy.run_path(str(Path(__file__).parents[2] / 'alembic/versions/0005_care_contacts.py'))
    engine = create_engine('sqlite:///:memory:')
    with engine.begin() as connection:
        connection.execute(text('CREATE TABLE babies (id TEXT PRIMARY KEY, name TEXT NOT NULL)'))
        connection.execute(text("INSERT INTO babies VALUES ('one', 'Anna')"))
        with Operations.context(MigrationContext.configure(connection)):
            migration['upgrade']()
            row = connection.execute(text('SELECT name, parent_phone, pediatrician_phone FROM babies')).one()
            assert row == ('Anna', None, None)
            migration['downgrade']()
            assert {c['name'] for c in inspect(connection).get_columns('babies')} == {'id', 'name'}
            assert connection.execute(text('SELECT name FROM babies')).scalar_one() == 'Anna'
    engine.dispose()
