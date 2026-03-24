from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from db.database import get_db

from schemas.service_schema import ServiceCreate , ServiceOut , ServiceUpdate
from services.service_methodes import create_service , delete_service , update_service ,get_services

router = APIRouter(prefix="/service", tags=["Service"])

@router.get("/services", response_model=list[ServiceOut])
def get_services_route(db: Session = Depends(get_db)):
    services = get_services(db)
    return services

@router.post("/create_service", response_model=ServiceOut)
def create_service_route(service_in: ServiceCreate, db: Session = Depends(get_db)):
    service = create_service(db, service_in)
    return service


@router.put("/service_update/{service_id}", response_model=ServiceOut)
def update_service_route(service_id: int, service_in: ServiceUpdate, db: Session = Depends(get_db)):
    service = update_service(db, service_id, service_in)
    if not service:
        raise HTTPException(status_code=404, detail="Service not found")
    return service


@router.delete("/{service_id}")
def delete_service_route(service_id : int ,db : Session = Depends(get_db) ):
    success = delete_service(db,service_id)
    if not success :
        raise HTTPException(status_code=404 , detail="Service not found")
    return {"message" : "Service deleted successfully"}