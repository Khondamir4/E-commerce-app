from fastapi import FastAPI
from app.routers import auth
from app import database
from app.database import Base, engine

app = FastAPI()

app.include_router(auth.router)

database.create_db()

if __name__ == "__main__":
    print("Recreating database tables...")
    Base.metadata.create_all(bind=engine)
    print("Database initialization complete.")