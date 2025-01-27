from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app import crud, schemas, database, models
from app.auth.utils import get_current_user, create_access_token
from app.database import get_db
from passlib.context import CryptContext
from app.schemas import RegisterResponse, UserCreate
from sqlalchemy.exc import IntegrityError



pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

router = APIRouter()

def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/register", response_model=RegisterResponse, status_code=201)
def register(user_data: UserCreate, db: Session = Depends(get_db)):
    existing_user = db.query(models.User).filter(
        models.User.username == user_data.username).first()
    
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Username already exists"
        )

    hashed_password = pwd_context.hash(user_data.password)
    new_user = models.User(
        username=user_data.username,
        email=user_data.email,
        full_name=user_data.full_name,
        hashed_password=hashed_password,
        is_admin=False
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
    
    access_token = create_access_token(data={"sub": new_user.username})
    return {"message": "User registered successfully", "access_token": access_token}


@router.delete("/delete_user/{user_id}")
def delete_user(
    user_id: int, 
    db: Session = Depends(get_db), 
    current_user: models.User = Depends(get_current_user)
):
    if not current_user.is_admin:
        raise HTTPException(status_code=403, detail="Permission denied")
    user = crud.delete_user(db, user_id=user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return {"message": f"User with ID {user_id} has been deleted"}


@router.post("/login")
def login(credentials: schemas.Login, db: Session = Depends(get_db)):
    user = crud.authenticate_user(db, credentials.username, credentials.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials"
        )
    token = create_access_token({"sub": user.username})
    return {"message": "Login successful", "access_token": token, "token_type": "bearer","is_admin": user.is_admin}
    

@router.get("/profile", response_model=schemas.UserProfile)
async def profile(current_user: models.User = Depends(get_current_user)):
    return {"username": current_user.username,"email": current_user.email, "full_name": current_user.full_name}