from sqlalchemy.orm import Session
from models.service import Service
from schemas.service_schema import ServiceCreate, ServiceUpdate

def create_service(db: Session, service: ServiceCreate) -> Service:
    new_service = Service(
        name=service.name,
        type=service.type,
        description=service.description
    )
    db.add(new_service)
    db.commit()
    db.refresh(new_service)
    return new_service


def update_service(db: Session, service_id: int, service_update: ServiceUpdate) -> Service | None:
    service = db.query(Service).filter(Service.id == service_id).first()
    if not service :
        return None
    
    if service_update.name is not None:
        service.name = service_update.name
    if service_update.type is not None:
        service.type = service_update.type
    if service_update.description is not None:
        service.description = service_update.description

    db.commit()
    db.refresh(service)
    return service


def delete_service(db: Session, service_id: int) -> bool:
    service = db.query(Service).filter(Service.id == service_id).first()

    if not service:
        return False
    
    db.delete(service)
    db.commit()
    return True


def get_services(db: Session) -> list[Service]:
    services = db.query(Service).all()
    return services