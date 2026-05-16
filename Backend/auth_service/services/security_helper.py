import httpx

async def send_security_event(payload:dict):
    try:
        async with httpx.AsyncClient(timeout=5) as client:
            await client.post("http://localhost:5678/webhook/security-event", json=payload)
    except Exception as e:
        print(f"Failed to send security event: {e}")