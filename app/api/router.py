from fastapi import APIRouter

from app.api.routes.availability import router as availability_router
from app.api.routes.discography import router as discography_router
from app.api.routes.manufacturing import router as manufacturing_router


api_router = APIRouter()
api_router.include_router(discography_router)
api_router.include_router(manufacturing_router)
api_router.include_router(availability_router)
