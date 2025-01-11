from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app import crud, schemas, database, models
from app.auth.utils import get_current_user, create_access_token
from app.database import get_db
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

router = APIRouter()

def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/register")
def register(user_data: schemas.UserCreate, db: Session = Depends(get_db)):
    # Check if user already exists
    user = db.query(models.User).filter(models.User.username == user_data.username).first()
    if user:
        raise HTTPException(status_code=400, detail="Username already registered")
    
    # Create new user with provided email and full name
    hashed_password = pwd_context.hash(user_data.password)  # Assuming you're hashing passwords
    new_user = models.User(
        username=user_data.username,
        email=user_data.email,
        full_name=user_data.full_name,
        hashed_password=hashed_password,
    )
    
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    return {"message": "User successfully registered", "username": new_user.username, "email": new_user.email}


@router.post("/login")
def login(credentials: schemas.Login, db: Session = Depends(get_db)):
    user = crud.authenticate_user(db, credentials.username, credentials.password)
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    access_token = create_access_token(data={"sub": user.username})
    return {"message": "Login successful", "access_token": access_token, "token_type": "bearer"}
    

@router.get("/profile", response_model=schemas.User)
def get_profile(current_user: schemas.User = Depends(get_current_user)):
    return current_user

@router.put("/update_profile")
def update_profile(user_data: schemas.UserCreate, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    # Ensure user is logged in and can update their info
    current_user.email = user_data.email
    current_user.full_name = user_data.full_name
    
    db.commit()
    db.refresh(current_user)
    
    return {
        "message": "Profile updated successfully",
        "username": current_user.username,
        "email": current_user.email,
        "full_name": current_user.full_name
    }

