from models.forest import Forest
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from db.database import get_db
from shapely.geometry import Point
from geoalchemy2.shape import to_shape
from schemas.forest_schema import ForestCreate, ForestOut , ForestUpdate
from services.forest_service import create_forest, delete_forest, get_all_forests, get_forest_by_id, convert_forest_boundary,assign_supervisor, get_forests_by_supervisor_id,get_non_occupied_forests,update_forest
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
        boundary=convert_forest_boundary(forest),
        region=forest.region
    )

@router.put("/{forest_id}", response_model=ForestOut)
def update_forest_route(
    forest_id: int,
    forest_in: ForestUpdate,
    db: Session = Depends(get_db)
):
    try:
        forest = update_forest(db, forest_id, forest_in)

        if not forest:
            raise HTTPException(status_code=404, detail="Forest not found")

        return ForestOut(
            id=forest.id,
            name=forest.name,
            description=forest.description,
            area_hectares=forest.area_hectares,
            risk_level=forest.risk_level,
            boundary=convert_forest_boundary(forest),
            supervisor_id=forest.supervisor_id,
            region=forest.region
        )

    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

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
            supervisor_id=f.supervisor_id,
            region=f.region
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
            supervisor_id=f.supervisor_id,
            region=f.region
        ) for f in forests
    ]

@router.get("/by_location/")
def get_forest_by_location(lat: float, lon: float, db: Session = Depends(get_db)):
    point = Point(lon, lat)
    forests = db.query(Forest).all()
    for forest in forests:
        polygon = to_shape(forest.boundary)
        if polygon.contains(point):
            return {"forest_id": forest.id}
    raise HTTPException(status_code=404, detail="No forest found")


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
        supervisor_id=forest.supervisor_id,
        region=forest.region
    )

@router.get("/supervisor/{supervisor_id}", response_model=list[ForestOut])
def get_forest_by_supervisor_id_route(supervisor_id: int, db: Session = Depends(get_db)):
    forests = get_forests_by_supervisor_id(db, supervisor_id)
    return [
        ForestOut(
            id=f.id,
            name=f.name,
            description=f.description,
            area_hectares=f.area_hectares,
            risk_level=f.risk_level,
            boundary=convert_forest_boundary(f),
            supervisor_id=f.supervisor_id,
            region=f.region
        ) for f in forests
    ]

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

@router.get("/assigned/{user_id}")
def check_assigned_forest(user_id: int, db: Session = Depends(get_db)):
    forest = db.query(Forest).filter(Forest.supervisor_id == user_id).first()
    if forest:
        return {"assigned": True, "forest": {"id": forest.id, "name": forest.name}}
    return {"assigned": False, "forest": None}


        
