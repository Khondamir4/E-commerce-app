from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app import crud, schemas, models
from app.routers.auth import get_db, get_current_user


router = APIRouter()

@router.post("/products", response_model=schemas.Product)
def create_product(product: schemas.ProductCreate, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    if not current_user.is_admin:
        raise HTTPException(status_code=403, detail="Permission denied")
    
    return crud.create_product(db=db, product=product)


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