from enum import Enum

class UserRole(str,Enum):
    SUPERVISEUR = "superviseur"
    AGENT="agent"
    ADMIN = "admin"