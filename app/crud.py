from sqlalchemy.orm import Session
from passlib.context import CryptContext
from app.models import User
from app.models import Product
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

def create_product(db: Session, product: ProductCreate):
    db_product = Product(
        name=product.name,
        description=product.description,
        price=product.price,
        quantity=product.quantity,
    )
    db.add(db_product)
    db.commit()
    db.refresh(db_product)
    return db_product


def get_user_by_token(db: Session, token: str):
    user_id = verify_token(token)  
    if user_id:
        return db.query(User).filter(User.id == user_id).first()
    return None

def get_all_products(db: Session):
    return db.query(Product).all()

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
    # Get the product by id
    product = db.query(Product).filter(Product.id == product_id).first()
    
    # If product doesn't exist, return None (or you can raise an exception)
    if not product:
        return None

    db.delete(product)
    db.commit()
    
    return product