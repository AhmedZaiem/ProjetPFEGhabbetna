from enum import Enum

class RiskLevel(str, Enum):
    no_data = "No Data"
    low = "Low"
    medium = "Medium"
    high = "High"