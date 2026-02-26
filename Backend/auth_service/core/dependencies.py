from fastapi import Depends, HTTPException
from models.user import User, UserRole
from services.user_service import get_current_user

