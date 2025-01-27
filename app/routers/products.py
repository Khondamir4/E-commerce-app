import base64
from uuid import uuid4
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form, Request
from sqlalchemy.orm import Session
import supabase
from app import crud, schemas, models
from app.routers.auth import get_db, get_current_user
from app.models import Product
import os
import shutil
from typing import Union
# from supabase import 

router = APIRouter()

def save_image(image: UploadFile, bucket_name: str = "shoppy-storage") -> str:
    """
    Uploads the image to Supabase Storage and returns the public URL.
    """
    if image.content_type not in ["image/jpeg", "image/png"]:
        raise HTTPException(
            status_code=400, detail="Only JPEG and PNG images are supported"
        )

    # Generate a unique file name
    filename = f"{image.filename}".replace(" ", "")

    try:
        with image.file as file:
            filecontent = file.read()
            res = supabase.storage.from_(bucket_name).upload(filename, filecontent, {
                "content-type": image.content_type
            })
            print(res)

        publicurl = supabase.storage.from_(bucket_name).get_public_url(filename)
        return publicurl

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error uploading file to Supabase: {e}")

@router.post("/products", response_model=schemas.Product, status_code=201)
def create_product(
    name: str = Form(...),
    description: str =Form(...),
    price: float = Form(),
    quantity: int = Form(),
    image: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    if not current_user.is_admin:
        raise HTTPException(status_code=403, detail="Only admins can create products")
    # product = schemas.ProductCreate(name=name, description=description,price=price,quantity=quantity,image=image_url)

    try:
        # image_url = save_image(image) 
        created_product = crud.create_product(db=db, name=name,description=description,price=price,quantity=quantity,image="image_url")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error creating product: {e}")
    return {
        "id": created_product.id,
        "name": created_product.name,
        "description": created_product.description,
        "price": created_product.price,
        "quantity": created_product.quantity,
        "image_data": "image_url",  # Return base64-encoded image
    }

@router.get("/products")
def get_products(
    sort_by: str = "name", 
    sort_order: str = "asc", 
    skip: int = 0, 
    limit: int = 10,
    db: Session = Depends(get_db)
):
    if not hasattr(Product, sort_by):
        raise HTTPException(status_code=400, detail="Invalid sort field")
    
    order_by = getattr(Product, sort_by).desc() if sort_order == "desc" else getattr(Product, sort_by).asc()
    products = db.query(Product).order_by(order_by).offset(skip).limit(limit).all()
    return {"products": products}

@router.get("/products/{product_id}", response_model=schemas.Product)
def get_product(product_id: int, db: Session = Depends(get_db)):
    product = db.query(models.Product).filter(models.Product.id == product_id).first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    return product

@router.put("/products/{product_id}", response_model=schemas.ProductBase)
def update_product(
    product_id: int,
    product: schemas.ProductCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    if not current_user.is_admin:
        raise HTTPException(
            status_code=403,
            detail="Permission denied"
        )

    updated_product = crud.update_product(db=db, product_id=product_id, product=product)

    if not updated_product:
        raise HTTPException(
            status_code = 404,
            detail="Product not found"
        )

    return updated_product

@router.delete("/products/{product_id}", status_code=204)
def delete_product(
    product_id: int, 
    db: Session = Depends(get_db), 
    current_user: models.User = Depends(get_current_user)
):
    if not current_user.is_admin:
        raise HTTPException(
            status_code=403,
            detail="Permission denied"
        )
    
    deleted_product = crud.delete_product(db=db, product_id=product_id)

    if not deleted_product:
        raise HTTPException(
            status_code=404,
            detail="Product not found"
        )

    return deleted_product