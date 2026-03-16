from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from db.database import get_db
from schemas.parcelle_schema import ParcelleCreate, ParcelleOut
from services.parcelle_service import (
    create_parcelle, convert_parcelle_boundary, delete_parcelle,
    get_all_parcelles, get_parcelle_by_id,assign_agent
)
from services.forest_service import calculate_area_hectares
from services.user_service import get_user_by_id

router = APIRouter(prefix="/parcelles", tags=["Parcelles"])

@router.post("/", response_model=ParcelleOut)
def create_parcelle_route(parcelle_in: ParcelleCreate, db: Session = Depends(get_db)):
    parcelle = create_parcelle(db, parcelle_in)
    return ParcelleOut(
        id=parcelle.id,
        name=parcelle.name,
        area_hectares=parcelle.area_hectares,
        boundary=convert_parcelle_boundary(parcelle),
        forest_id=parcelle.forest_id
    )

@router.get("/", response_model=list[ParcelleOut])
def get_parcelles_route(db: Session = Depends(get_db)):
    parcelles = get_all_parcelles(db)
    return [
        ParcelleOut(
            id=p.id,
            name=p.name,
            area_hectares=p.area_hectares,
            boundary=convert_parcelle_boundary(p),
            forest_id=p.forest_id
        ) for p in parcelles
    ]

@router.get("/{parcelle_id}", response_model=ParcelleOut)
def get_parcelle_route(parcelle_id: int, db: Session = Depends(get_db)):
    parcelle = get_parcelle_by_id(db, parcelle_id)
    if not parcelle:
        raise HTTPException(status_code=404, detail="Parcelle not found")
    return ParcelleOut(
        id=parcelle.id,
        name=parcelle.name,
        area_hectares=parcelle.area_hectares,
        boundary=convert_parcelle_boundary(parcelle),
        forest_id=parcelle.forest_id
    )

@router.delete("/{parcelle_id}")
def delete_parcelle_route(parcelle_id: int, db: Session = Depends(get_db)):
    success = delete_parcelle(db, parcelle_id)
    if not success:
        raise HTTPException(status_code=404, detail="Parcelle not found")
    return {"message": "Parcelle deleted successfully"}

@router.post("/{parcelle_id}/assign-agent/{user_id}")
def assign_agent_route(parcelle_id: int,user_id: int ,db: Session = Depends(get_db)):
    parcelle = get_parcelle_by_id(db,parcelle_id)
    if not parcelle:
        raise HTTPException(404, "parcelle not found")
    
    user = get_user_by_id(db,user_id)
    if not user:
        raise HTTPException(404, "Agent not found")
    
    if user.role.name != "Agent":
        raise HTTPException(400, "User is Not Agent")
    
    assign_agent(db,user.id,parcelle)

    return {"message": "Agent assigned"}