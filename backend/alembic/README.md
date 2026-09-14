# Alembic migrations

Run migrations from `backend/` after setting `LULLABYTE_DATABASE_URL`:

```powershell
.venv/Scripts/python.exe -m alembic upgrade head
```

The first migration creates only identity and baby-profile tables. Feature
tables must be introduced in separate reviewed migrations.

