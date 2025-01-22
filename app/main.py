from fastapi import FastAPI
from app.routers import auth, products
from app import database
from app.database import Base, engine

app = FastAPI()

app.include_router(auth.router)
app.include_router(products.router)

database.create_db()
