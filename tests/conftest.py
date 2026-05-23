import os

# Use SQLite in-memory for fast, isolated tests (no MySQL needed)
os.environ['DATABASE_URL'] = 'sqlite:///:memory:'
os.environ.setdefault('DB_USER', 'test')
os.environ.setdefault('DB_PASS', 'test')
os.environ.setdefault('DB_HOST', 'localhost')
os.environ.setdefault('DB_NAME', 'test')
