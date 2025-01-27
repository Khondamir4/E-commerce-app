from fastapi import HTTPException
from sqlalchemy.orm import Session
from passlib.context import CryptContext
from app.models import User, Product
from app.schemas import ProductCreate
from app.auth.utils import verify_token

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_password_hash(password: str):
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str):
    return pwd_context.verify(plain_password, hashed_password)

def get_user_by_username(db: Session, username: str):
    return db.query(User).filter(User.username == username).first()

def create_user(db: Session, username: str, password: str):
    hashed_password = get_password_hash(password)
    db_user = User(username=username, hashed_password=hashed_password)  
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def delete_user(db: Session, user_id: int):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        return None
    db.delete(user)
    db.commit()
    return user

def authenticate_user(db: Session, username: str, password: str):
    user = get_user_by_username(db, username)
    if user and verify_password(password, user.hashed_password):
        return user
    return None

def create_product(db: Session, name: str,description: str, price: float, quantity: int, image: str) -> Product:
    try:
        db_product = Product(
            name=name.strip(),
            description=description.strip(),
            price=round(price, 2),
            quantity=max(quantity, 0),
            image_path=image,
        )
        
        db.add(db_product)
        db.commit()
        db.refresh(db_product)
        return db_product
    except Exception as e:
        db.rollback()  
        raise HTTPException(status_code=500, detail=f"Error creating product in DB: {e}")


def get_user_by_token(db: Session, token: str):
    user_id = verify_token(token)  
    if user_id:
        return db.query(User).filter(User.id == user_id).first()
    return None

def get_all_products(db: Session, skip: int = 0, limit: int = 10):
    return db.query(Product).offset(skip).limit(limit).all()

def update_product(db: Session, product_id: int, product: ProductCreate):
    db_product = db.query(Product).filter(Product.id == product_id).first()

    if not db_product:
        return None  

    db_product.name = product.name
    db_product.description = product.description
    db_product.price = product.price
    db_product.quantity = product.quantity
    db.commit()
    db.refresh(db_product) 

    return db_product  

def delete_product(db: Session, product_id: int):
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        return None

    try:
        db.delete(product)
        db.commit()
        return product
    except Exception as e:
        db.rollback()
        raise e