from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from app import crud, schemas, models
from app.routers.auth import get_db, get_current_user
from app.models import Product
from app.schemas import ProductResponse, AddToCartRequest, CartItem
from typing import List


router = APIRouter()

@router.post("/products", response_model=schemas.Product)
def create_product(product: schemas.ProductCreate, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    if not current_user.is_admin:
        raise HTTPException(status_code=403, detail="Permission denied")
    
    return crud.create_product(db=db, product=product)

@router.get("/products")
def get_products(
    sort_by: str = "name", 
    sort_order: str = "asc", 
    skip: int = 0, 
    limit: int = 10,
    db: Session = Depends(get_db)
):
    if sort_order == "desc":
        products = db.query(Product).order_by(getattr(Product, sort_by).desc()).offset(skip).limit(limit).all()
    else:
        products = db.query(Product).order_by(getattr(Product, sort_by).asc()).offset(skip).limit(limit).all()
    return {"products": products}

@router.get("/products/search", response_model=List[schemas.ProductResponse])
def search_products(query: str, db: Session = Depends(get_db), skip: int = 0, limit: int = 10):
    products = db.query(Product).filter(
        Product.name.ilike(f"%{query}%") | Product.description.ilike(f"%{query}%")
    ).offset(skip).limit(limit).all()
    
    if not products:
        raise HTTPException(status_code=404, detail="No products found")
        
    return products

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

@router.post("/cart/add")
def add_to_cart(
    add_to_cart_request: schemas.AddToCartRequest,  # This is Pydantic model for validation
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    # Ensure quantity is a positive integer
    if add_to_cart_request.quantity <= 0:
        raise HTTPException(status_code=400, detail="Quantity must be a positive integer.")

    # Ensure product exists
    product = db.query(models.Product).filter(models.Product.id == add_to_cart_request.product_id).first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found.")
    
    # Check if the product is already in the user's cart
    cart_item = db.query(models.CartItem).filter(  # Use models.CartItem (SQLAlchemy model)
        models.CartItem.user_id == current_user.id,
        models.CartItem.product_id == add_to_cart_request.product_id
    ).first()
    
    if cart_item:
        # Update the quantity if it's already in the cart
        cart_item.quantity += add_to_cart_request.quantity
    else:
        # Otherwise, create a new cart item using SQLAlchemy model
        cart_item = models.CartItem(user_id=current_user.id, product_id=add_to_cart_request.product_id, quantity=add_to_cart_request.quantity)
        db.add(cart_item)

    db.commit()
    db.refresh(cart_item)

    return {"message": f"{product.name} has been added to your cart with quantity {add_to_cart_request.quantity}."}

@router.get("/cart")
def view_cart(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    # Query the cart items using the SQLAlchemy model `CartItem` (models.CartItem)
    cart_items = db.query(models.CartItem).filter(models.CartItem.user_id == current_user.id).all()
    
    if not cart_items:
        return {"message": "Your cart is empty.", "cart": []}
    
    cart = []
    for item in cart_items:
        product = item.product  # Using `product` relationship defined in SQLAlchemy
        cart.append({
            "product_id": product.id,
            "name": product.name,
            "price": product.price,
            "quantity": item.quantity,
            "total": product.price * item.quantity
        })
    
    return {"cart": cart}
