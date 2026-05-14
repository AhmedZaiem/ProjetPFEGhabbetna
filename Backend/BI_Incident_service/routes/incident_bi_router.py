from fastapi import APIRouter
from services.incident_bi_controller import IncidentBIController

router = APIRouter(prefix="/bi_incidents", tags=["Incident BI"])


@router.get("/over-time")
def over_time():
    return IncidentBIController.incidents_over_time()


@router.get("/by-status")
def by_status():
    return IncidentBIController.incidents_by_status()


@router.get("/by-region")
def by_region():
    return IncidentBIController.incidents_by_region()


@router.get("/top-forests")
def top_forests():
    return IncidentBIController.top_forests_by_incidents()


@router.get("/top-agents")
def top_agents():
    return IncidentBIController.top_agents_by_incidents()



# agent routes
@router.get("/agent/{agent_id}/over-time")
def agent_over_time(agent_id: int):
    return IncidentBIController.agent_incidents_over_time(agent_id)


@router.get("/agent/{agent_id}/by-status")
def agent_by_status(agent_id: int):
    return IncidentBIController.agent_incidents_by_status(agent_id)

# supervisors routes