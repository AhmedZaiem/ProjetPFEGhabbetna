from enum import Enum

class Status(str, Enum):
    not_accepted = "not_accepted"
    pending = "pending"
    completed = "completed"
    