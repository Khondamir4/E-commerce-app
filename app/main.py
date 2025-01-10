from fastapi import FastAPI
from app.routers import auth
from app import database

app = FastAPI()

app.include_router(auth.router)

database.create_db()
