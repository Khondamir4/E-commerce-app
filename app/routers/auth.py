from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app import crud, schemas, database, models
from app.auth.utils import get_current_user, create_access_token
from app.database import get_db
from passlib.context import CryptContext
from app.schemas import UserResponse, UserCreate
from sqlalchemy.exc import IntegrityError


pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

router = APIRouter()

def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/register", response_model=UserResponse)
def register(user_data: UserCreate, db: Session = Depends(get_db)):
    # Check if username or email already exists
    existing_user = db.query(models.User).filter(
        models.User.username == user_data.username).first()
    
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Username already exists"
        )

    # Hash the password before saving
    hashed_password = pwd_context.hash(user_data.password)

    # Create the user and add to the DB
    new_user = models.User(
        username=user_data.username,
        email=user_data.email,
        full_name=user_data.full_name,
        hashed_password=hashed_password,
    )
    try:
        db.add(new_user)
        db.commit()
        db.refresh(new_user)
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already exists"
        )
    
    return new_user  # Returning the user without sensitive info


@router.post("/login")
def login(credentials: schemas.Login, db: Session = Depends(get_db)):
    user = crud.authenticate_user(db, credentials.username, credentials.password)
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    
    # Generate access token (assuming it's defined elsewhere)
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

