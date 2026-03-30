from sqlalchemy.orm import Session
from models.forest import Forest
from schemas.forest_schema import ForestCreate, Coordinates
from shapely.geometry import Polygon
from geoalchemy2.shape import from_shape,to_shape
from typing import List
from shapely.ops import transform
from shapely.geometry import Polygon
import pyproj
from sqlalchemy import func

def create_forest(db: Session, forest_in: ForestCreate) -> Forest:
    coords = [(p.lng, p.lat) for p in forest_in.boundary]
    if coords[0] != coords[-1]:
        coords.append(coords[0])
    geom = from_shape(Polygon(coords), srid=4326)

    if forest_overlap(db, geom):
        raise ValueError("Forest boundary overlaps with an existing forest")

    forest = Forest(
        name=forest_in.name,
        description=forest_in.description,
        area_hectares=calculate_area_hectares(geom),
        region=forest_in.region,
        boundary=geom, 
    )
    db.add(forest)
    db.commit()
    db.refresh(forest)
    return forest

def convert_forest_boundary(forest: Forest) -> List[Coordinates]:
    polygon = to_shape(forest.boundary)
    return [Coordinates(lng=lng, lat=lat) for lng,lat in polygon.exterior.coords]

def get_all_forests(db: Session) -> List[Forest]:
    return db.query(Forest).all()

def get_forest_by_id(db: Session,forest_id: int) -> Forest | None:
    return db.query(Forest).get(forest_id)

def get_forests_by_supervisor_id(db: Session, supervisor_id: int) -> List[Forest]:
    return db.query(Forest).filter(Forest.supervisor_id == supervisor_id).all()

def get_non_occupied_forests(db: Session) -> Forest | None:
    return db.query(Forest).filter(Forest.supervisor_id==None).all()

def delete_forest(db: Session, forest_id: int) -> bool:
    forest = db.query(Forest).get(forest_id)
    if not forest:
        return False
    db.delete(forest)
    db.commit()
    return True

def calculate_area_hectares(boundary_geom) -> float:
    polygon : Polygon= to_shape(boundary_geom)
    project = pyproj.Transformer.from_proj(
        "EPSG:4326",
        "EPSG:3857",
        always_xy=True
    ).transform
    polygon_m = transform(project, polygon)
    area_sqm = polygon_m.area
    area_hectares = area_sqm / 10000
    return area_hectares

def forest_overlap(db: Session,  polygon):
    existing = db.query(Forest).filter(
        func.ST_Overlaps(Forest.boundary, polygon) |
        func.ST_Within(polygon, Forest.boundary) |
        func.ST_Equals(Forest.boundary, polygon)
    ).first()
    return existing is not None

def assign_supervisor(db: Session, supervisor_id:int,forest: Forest):
    forest.supervisor_id = supervisor_id
    db.commit()    
    db.refresh(forest)
    return True
