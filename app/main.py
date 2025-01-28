from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from app.routers import auth, products
from app import database
from app.database import Base, engine
import supabase
print(supabase.__version__)  # Ensure you are using the latest version

app = FastAPI()

app.include_router(auth.router)
app.include_router(products.router)

database.create_db()
