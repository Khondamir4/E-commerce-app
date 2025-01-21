from pydantic import BaseModel, EmailStr
from typing import Optional
from pydantic import BaseModel

class UserProfile(BaseModel):
    username: str
    email: str
    full_name: str

    class Config:
        from_attributes = True  


class Login(BaseModel):
    username: str
    password: str


class User(BaseModel):
    username: str
    email: Optional[str] = None
    full_name: Optional[str] = None


class UserCreate(BaseModel):
    username: str
    password: str 
    email: EmailStr 
    full_name: str  

class RegisterResponse(BaseModel):
    message: str
    access_token: str

class UserResponse(BaseModel):
    username: str
    email: str
    full_name: str


    class Config:
        from_attributes = True

class UserUpdate(BaseModel):
    email: EmailStr
    full_name: str

class ProductCreate(BaseModel):
    name: str
    description: str
    price: float
    quantity: int

    class Config:
        from_attributes = True

class ProductBase(BaseModel):
    name: str
    description: str
    price: float
    quantity: int

    class Config:
        from_attributes = True

class Product(ProductBase):
    id: int
    name: str
    description: str
    price: float
    quantity: int
    
    class Config:
        from_attributes = True

class ProductResponse(BaseModel):
    id: int
    name: str
    description: str
    price: float
    quantity: int

    class Config:
        from_attributes = True

class CartItem(BaseModel):
    product_id: int
    quantity: int

class AddToCartRequest(BaseModel):
    product_id: int
    quantity: int

class CartItemBase(BaseModel):
    product_id: int
    quantity: int

class CartItemResponse(CartItemBase):
    id: int
    user_id: int

    class Config:
        from_attributes = True