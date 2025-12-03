import os
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker, declarative_base
from tenacity import retry, stop_after_attempt, wait_fixed, retry_if_exception_type

POSTGRES_USER = os.getenv("POSTGRES_USER", "devuser")
POSTGRES_PASSWORD = os.getenv("POSTGRES_PASSWORD", "mysecretpassword")
POSTGRES_DB = os.getenv("POSTGRES_DB", "devdb")
POSTGRES_HOST = os.getenv("POSTGRES_HOST", "db")
POSTGRES_PORT = os.getenv("POSTGRES_PORT", "5432")

DATABASE_URL = f"postgresql+psycopg2://{POSTGRES_USER}:{POSTGRES_PASSWORD}@{POSTGRES_HOST}:{POSTGRES_PORT}/{POSTGRES_DB}"

@retry(
    stop=stop_after_attempt(10),
    wait=wait_fixed(2),
    retry=retry_if_exception_type(Exception),
    reraise=True
)
def initialize_database_engine():
    print("Attempting to connect to the database...")

    engine_instance = create_engine(
        DATABASE_URL,
        echo=True,
        pool_pre_ping=True
    )

    with engine_instance.connect() as connection:
        connection.execute(text("SELECT 1"))

    print("Database connection successful!")
    return engine_instance

engine = initialize_database_engine()

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()