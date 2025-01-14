# app/routers/products.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app import crud, schemas
from app.routers.auth import get_db, get_current_user
from app.models import User, Product

router = APIRouter()

@router.post("/products")
def create_product(
    product_data: schemas.ProductCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if not current_user.is_admin:
        raise HTTPException(
            status_code=403,
            detail="Permission denied",
        )
    new_product = crud.create_product(db, product_data)
    return {"message": "Product added successfully", "product": new_product}
