from app.database import engine
from app.models import User

User.metadata.create_all(bind=engine)
