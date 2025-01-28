import base64
from uuid import uuid4
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form, Request
from sqlalchemy.orm import Session
import supabase
from app import crud, schemas, models
from app.routers.auth import get_db, get_current_user
from app.models import Product
import os
from datetime import datetime
import shutil
from typing import Union
from supabase import create_client, Client

supabase_url = "https://ayjebxgbypkqutowpdld.supabase.co"
supabase_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF5amVieGdieXBrcXV0b3dwZGxkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzgwMTM5NzEsImV4cCI6MjA1MzU4OTk3MX0.fk5g6oJoO6KZMI3mBe-Z4JCLqeOPGpjtBhFYg3LkLpw"
supabase: Client = create_client(supabase_url, supabase_key)


router = APIRouter()

def save_image(image: UploadFile, bucket_name: str = "shoppy-storage") -> str:
    """
    Uploads the image to Supabase Storage and returns the public URL.
    """
    if image.content_type not in ["image/jpeg", "image/png"]:
    # Check the file extension manually for .jpg or .jpeg
        imagename = image.filename.lower()
        if not (imagename.endswith(".jpg") or imagename.endswith(".jpeg") or imagename.endswith(".png")):
            raise HTTPException(
                status_code=400, detail="Only JPEG and PNG images are supported"
            )


    now = datetime.now()
    formated_time=now.strftime("%Y-%m-%d %H:%M:%S.%f")
    # Generate a unique file name
    filename = f"{image.filename}-{formated_time}".replace(" ", "").replace(".jpg","").replace(".jpeg","").replace(".png","")

    try:
        with image.file as file:
            filecontent = file.read()
            res = supabase.storage.from_(bucket_name).upload(filename, filecontent, {
                "content-type": image.content_type
            })


        supabase.storage.from_(bucket_name).get_public_url(filename)
        return filename

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
        saved_image = save_image(image)
        image_url = f"https://ayjebxgbypkqutowpdld.supabase.co/storage/v1/object/public/shoppy-storage//{saved_image}" 
        print(image_url)
        created_product = crud.create_product(db=db, name=name,description=description,price=price,quantity=quantity,image=image_url)
        print(created_product.image_path)
        return created_product
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error creating product: {e}")
    

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
    for product in products:
        if product.image_path:
            product.image_path = str(product.image_path)
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
    name: str = Form(...),
    description: str =Form(...),
    price: float = Form(),
    quantity: int = Form(),
    image: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    if not current_user.is_admin:
        raise HTTPException(
            status_code=403,
            detail="Permission denied"
        )
    saved_image = save_image(image)
    image_url = f"https://ayjebxgbypkqutowpdld.supabase.co/storage/v1/object/public/shoppy-storage//{saved_image}" 


    updated_product = crud.update_product(db=db, product_id=product_id, name=name,description=description,price=price,quantity=quantity,image=image_url)

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