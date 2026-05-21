import httpx
import json
import os
from core.redis import redis_client

ADMIN_SERVICE_URL = os.getenv(
    "ADMIN_SERVICE_URL",
    "http://admin_service:8000"
)


def get_supervisor_forests(supervisor_id: int):
    cache_key = f"supervisor:forests:{supervisor_id}"
    cached = redis_client.get(cache_key)

    if cached:
        return json.loads(cached)

    with httpx.Client() as client:
        res = client.get(
            f"{ADMIN_SERVICE_URL}/forest/supervisor/{supervisor_id}"
        )

    if res.status_code != 200:
        return []

    forests = res.json()

    redis_client.setex(cache_key, 600, json.dumps(forests))

    return forests