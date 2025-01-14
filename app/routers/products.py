# app/routers/products.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app import crud, schemas
from app.routers.auth import get_db, get_current_user
from app.models import User, Product
from app import models

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

@router.get("/products")
def get_products(db: Session = Depends(get_db)):
    products = crud.get_all_products(db)
    return {"products": products}

@router.get("/products/{product_id}", response_model=schemas.Product)
def get_product(product_id: int, db: Session = Depends(get_db)):
    product = db.query(models.Product).filter(models.Product.id == product_id).first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    return product

@router.put("/products/{product_id}", response_model=schemas.Product)
def update_product(product_id: int, product_data: schemas.ProductCreate, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    # Ensure the user is an admin
    if not current_user.is_admin:
        raise HTTPException(status_code=403, detail="Permission denied")

    product = db.query(models.Product).filter(models.Product.id == product_id).first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    # Update the product fields with the new data
    product.name = product_data.name
    product.description = product_data.description
    product.price = product_data.price
    product.quantity = product_data.quantity

    db.commit()
    db.refresh(product)
    
    return product

@router.delete("/products/{product_id}", response_model=schemas.Product)
def delete_product(product_id: int, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    # Ensure the user is an admin
    if not current_user.is_admin:
        raise HTTPException(status_code=403, detail="Permission denied")
    
    product = db.query(models.Product).filter(models.Product.id == product_id).first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    db.delete(product)
    db.commit()
    
    return product