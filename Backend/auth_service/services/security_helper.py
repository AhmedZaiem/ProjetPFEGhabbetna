import httpx
import os

N8N_WEBHOOK_URL = os.getenv("N8N_WEBHOOK_URL", "http://localhost:5678/webhook/security-event")

async def send_security_event(payload:dict):
    try:
        async with httpx.AsyncClient(timeout=5) as client:
            await client.post(N8N_WEBHOOK_URL, json=payload)
    except Exception as e:
        print(f"Failed to send security event: {e}")