from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from db.database import get_db
from schemas.forest_schema import ForestCreate, ForestOut
from services.forest_service import create_forest, delete_forest, get_all_forests, get_forest_by_id, convert_forest_boundary,assign_supervisor,get_non_occupied_forests
from services.user_service import get_user_by_id

router = APIRouter(prefix="/forest", tags=["Forest"])

@router.post("/", response_model=ForestOut)
def create_forest_route(forest_in: ForestCreate, db: Session = Depends(get_db)):
    forest = create_forest(db, forest_in)
    return ForestOut(
        id=forest.id,
        name=forest.name,
        description=forest.description,
        area_hectares=forest.area_hectares,
        risk_level=forest.risk_level,
        boundary=convert_forest_boundary(forest)
    )

@router.get("/", response_model=list[ForestOut])
def get_forests_route(db: Session = Depends(get_db)):
    forests = get_all_forests(db)
    return [
        ForestOut(
            id=f.id,
            name=f.name,
            description=f.description,
            area_hectares=f.area_hectares,
            risk_level=f.risk_level,
            boundary=convert_forest_boundary(f),
            supervisor_id=f.supervisor_id
        ) for f in forests
    ]

@router.get('/non_occupied_forests',response_model=list[ForestOut])
def get_non_supervised_forests(db: Session = Depends(get_db)):
    forests=get_non_occupied_forests(db)
    return [
        ForestOut(
            id=f.id,
            name=f.name,
            description=f.description,
            area_hectares=f.area_hectares,
            risk_level=f.risk_level,
            boundary=convert_forest_boundary(f),
            supervisor_id=f.supervisor_id
        ) for f in forests
    ]


@router.get("/{forest_id}", response_model=ForestOut)
def get_forest_route(forest_id: int, db: Session = Depends(get_db)):
    forest = get_forest_by_id(db, forest_id)
    if not forest:
        raise HTTPException(status_code=404, detail="Forest not found")
    return ForestOut(
        id=forest.id,
        name=forest.name,
        description=forest.description,
        area_hectares=forest.area_hectares,
        risk_level=forest.risk_level,
        boundary=convert_forest_boundary(forest),
        supervisor_id=forest.supervisor_id
    )

@router.delete("/{forest_id}")
def delete_forest_route(forest_id: int, db: Session = Depends(get_db)):
    success = delete_forest(db, forest_id)
    if not success:
        raise HTTPException(status_code=404, detail="Forest not found")
    return {"message": "Forest deleted successfully"}

@router.post("/{forest_id}/assign-supervisor/{user_id}")
def assign_supervisor_route(forest_id: int,user_id: int ,db: Session = Depends(get_db)):
    forest = get_forest_by_id(db,forest_id)
    if not forest:
        raise HTTPException(404, "Forest not found")
    
    user = get_user_by_id(db,user_id)
    if not user:
        raise HTTPException(404, "Supervisor not found")

    if user.role.name != "Superviseur":
        raise HTTPException(400, "User is Not Supervisor")
    
    if forest.supervisor_id :
        raise HTTPException(409, "Forest Occupied")
    
    assign_supervisor(db,user.id,forest)

    return {"message": "Supervisor assigned"}


        
