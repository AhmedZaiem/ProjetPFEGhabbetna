from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from db.database import get_db
from schemas.parcelle_schema import ParcelleCreate, ParcelleOut , ParcelleUpdate
from services.parcelle_service import (
    create_parcelle, convert_parcelle_boundary, delete_parcelle,
    get_all_parcelles, get_parcelle_by_id,assign_agent,get_parcelle_by_agent_id,get_non_occupied_parcelles ,update_parcelle
)
from services.forest_service import calculate_area_hectares
from services.user_service import get_user_by_id
from models.parcelle import Parcelle
from models.user import User

router = APIRouter(prefix="/parcelles", tags=["Parcelles"])

@router.post("/", response_model=ParcelleOut)
def create_parcelle_route(parcelle_in: ParcelleCreate, db: Session = Depends(get_db)):
    parcelle = create_parcelle(db, parcelle_in)
    return ParcelleOut(
        id=parcelle.id,
        name=parcelle.name,
        area_hectares=parcelle.area_hectares,
        boundary=convert_parcelle_boundary(parcelle),
        forest_id=parcelle.forest_id,
        region=parcelle.region
    )

@router.put("/{parcelle_id}", response_model=ParcelleOut)
def update_parcelle_route(
    parcelle_id: int,
    parcelle_in: ParcelleUpdate,
    db: Session = Depends(get_db)
):
    try:
        parcelle = update_parcelle(db, parcelle_id, parcelle_in)

        if not parcelle:
            raise HTTPException(status_code=404, detail="Parcelle not found")

        return ParcelleOut(
            id=parcelle.id,
            name=parcelle.name,
            area_hectares=parcelle.area_hectares,
            boundary=convert_parcelle_boundary(parcelle),
            forest_id=parcelle.forest_id,
            agent_id=parcelle.agent_id,
            region=parcelle.region
        )

    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/", response_model=list[ParcelleOut])
def get_parcelles_route(db: Session = Depends(get_db)):
    parcelles = get_all_parcelles(db)
    return [
        ParcelleOut(
            id=p.id,
            name=p.name,
            area_hectares=p.area_hectares,
            boundary=convert_parcelle_boundary(p),
            forest_id=p.forest_id,
            agent_id=p.agent_id,
            region=p.region
        ) for p in parcelles
    ]

@router.get('/non_occupied_parcelles',response_model=list[ParcelleOut])
def get_non_patrolled_parcelles(db: Session = Depends(get_db)):
    parcelles=get_non_occupied_parcelles(db)
    return [
        ParcelleOut(
            id=p.id,
            name=p.name,
            area_hectares=p.area_hectares,
            boundary=convert_parcelle_boundary(p),
            forest_id=p.forest_id,
            agent_id=p.agent_id,
            region=p.region
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
        forest_id=parcelle.forest_id,
        agent_id=parcelle.agent_id,
        region=parcelle.region
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
    
    if user.parcelle:
        raise HTTPException(409, "Agent already assigned to another parcelle")

    if parcelle.agent_id :
        raise HTTPException(409, "Parcelle Occupied")
    
    assign_agent(db,user.id,parcelle)

    return {"message": "Agent assigned"}

@router.get("/assigned/{user_id}")
def check_assigned_parcelle(user_id: int, db: Session = Depends(get_db)):
    parcelle = db.query(Parcelle).filter(Parcelle.agent_id == user_id).first()
    if parcelle:
        return {"assigned": True, "parcelle": {"id": parcelle.id, "name": parcelle.name}}
    return {"assigned": False, "parcelle": None}

@router.get("/byforest/")
def get_parcelles_by_forest_ids(forest_ids: list[int]=Query(...), db: Session = Depends(get_db)):
    parcelles = db.query(Parcelle).join(User, Parcelle.agent_id == User.id).filter(Parcelle.forest_id.in_(forest_ids)).all()
    result = []
    for p in parcelles:
        result.append({
            "id": p.id,
            "name": p.name,
            "area_hectares": p.area_hectares,
            "boundary": convert_parcelle_boundary(p),
            "forest_id": p.forest_id,
            "agent": {
                "id": p.agent.id,
                "name": p.agent.username,
                "email": p.agent.email,
                "tel": p.agent.tel,
                "region": p.agent.region
            } if p.agent else None,
            "region": p.region
        })
    return result


