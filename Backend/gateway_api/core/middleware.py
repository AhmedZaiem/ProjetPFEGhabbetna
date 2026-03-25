from fastapi import Request
from fastapi.responses import JSONResponse
import jwt

SECRET_KEY = "your_secret_key"
ALGORITHM = "HS256"

PUBLIC_ROUTES = [
    "/auth/login",
    "/auth/refresh",
    "/auth/logout",
    "/docs",
    "/openapi.json",
    "/docs/oauth2-redirect",
    "/auth/activate",
    "/auth/reset-password",
    "/auth/forgot-password"
]

async def auth_middleware(request: Request, call_next):

    path = request.url.path

    if path in PUBLIC_ROUTES:
        return await call_next(request)
    
    auth_header = request.headers.get("Authorization")
    print("AUTH HEADER:", auth_header)

    if not auth_header or not auth_header.startswith("Bearer "):
        return JSONResponse(status_code=401, content={"detail": "Unauthorized"})
    
    token = auth_header.split(" ")[1]

    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        request.state.user = payload
    except:
        return JSONResponse(status_code=401, content={"detail": "Invalid token"})

    return await call_next(request)
        