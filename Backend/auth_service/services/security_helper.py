import httpx
import os

N8N_WEBHOOK_URL = os.getenv("N8N_WEBHOOK_URL", "http://localhost:5678/webhook/security-event")

async def send_security_event(payload:dict):
    try:
        async with httpx.AsyncClient(timeout=5) as client:
            await client.post(N8N_WEBHOOK_URL, json=payload)
    except Exception as e:
        print(f"Failed to send security event: {e}")

async def check_tunisian_ip(payload:dict):
    try:
        ip = payload.get("ip")
        async with httpx.AsyncClient(timeout=5) as client:
            response = await client.get(f"https://ipapi.co/{ip}/json/")
            if response.status_code == 200:
                data = response.json()
                payload["country"]=data.get("country")
                payload["is_tunisian_ip"]=data.get("country_code") == "TN"
    except Exception as e:
        print(f"Failed to check IP location: {e}")
    
    return payload

def should_send_event(payload: dict):
    return payload.get("is_tunisian_ip") is False

async def process_security_event(payload:dict):
    payload = await check_tunisian_ip(payload)
    if should_send_event(payload):
        await send_security_event(payload)