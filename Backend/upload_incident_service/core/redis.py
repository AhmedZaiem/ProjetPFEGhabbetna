import redis
import os

redis_client = redis.Redis(
    host="localhost",
    port=os.getenv("REDIS_PORT", 6379),
    decode_responses=True
)
