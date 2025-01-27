from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from app.routers import auth, products
from app import database
from app.database import Base, engine
from supabase import create_client, Client

supabase_url = "https://ayjebxgbypkqutowpdld.supabase.co"
supabase_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF5amVieGdieXBrcXV0b3dwZGxkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzgwMTM5NzEsImV4cCI6MjA1MzU4OTk3MX0.fk5g6oJoO6KZMI3mBe-Z4JCLqeOPGpjtBhFYg3LkLpw"
supabase: Client = create_client(supabase_url, supabase_key)

app = FastAPI()

app.include_router(auth.router)
app.include_router(products.router)

database.create_db()
