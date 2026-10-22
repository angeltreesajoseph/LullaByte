from pathlib import Path
import runpy
from alembic.migration import MigrationContext
from alembic.operations import Operations
from sqlalchemy import create_engine, inspect, text


def test_account_photo_migration_preserves_users_and_babies():
    migration = runpy.run_path(str(Path(__file__).parents[2] / 'alembic/versions/0008_account_photos.py'))
    engine = create_engine('sqlite:///:memory:')
    with engine.begin() as conn:
        conn.execute(text('CREATE TABLE users (id TEXT PRIMARY KEY, display_name TEXT)'))
        conn.execute(text("INSERT INTO users VALUES ('one', 'Parent')"))
        conn.execute(text('CREATE TABLE babies (id TEXT PRIMARY KEY, name TEXT)'))
        conn.execute(text("INSERT INTO babies VALUES ('baby', 'Anna')"))
        with Operations.context(MigrationContext.configure(conn)):
            migration['upgrade']()
            assert 'account_photos' in inspect(conn).get_table_names()
            assert conn.execute(text('SELECT display_name FROM users')).scalar_one() == 'Parent'
            assert conn.execute(text('SELECT name FROM babies')).scalar_one() == 'Anna'
            migration['downgrade']()
            assert 'account_photos' not in inspect(conn).get_table_names()
            assert conn.execute(text('SELECT name FROM babies')).scalar_one() == 'Anna'
    engine.dispose()
