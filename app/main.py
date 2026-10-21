from fastapi import FastAPI
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from mysql.connector import Error as MySQLError

from app.api.router import api_router
from app.core.errors import (
    ApiException,
    api_exception_handler,
    mysql_exception_handler,
    validation_exception_handler,
)


app = FastAPI(
    title="Event Management APIs",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.add_exception_handler(ApiException, api_exception_handler)
app.add_exception_handler(RequestValidationError, validation_exception_handler)
app.add_exception_handler(MySQLError, mysql_exception_handler)

app.include_router(api_router)


@app.get("/health", tags=["System"])
def health():
    return {"status": "ok"}
