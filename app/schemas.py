from pydantic import BaseModel
from typing import Optional

class UserProfile(BaseModel):
    email: str
    full_name: str  

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

class UserResponse(BaseModel):
    username: str

    class Config:
        from_attributes = True

