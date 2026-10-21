from fastapi import Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from mysql.connector import Error as MySQLError


class ApiException(Exception):
    def __init__(self, status_code: int, code: str, message: str):
        self.status_code = status_code
        self.code = code
        self.message = message
        super().__init__(message)


async def api_exception_handler(request: Request, exc: ApiException):
    return JSONResponse(
        status_code=exc.status_code,
        content={"code": exc.code, "message": exc.message},
    )


async def validation_exception_handler(request: Request, exc: RequestValidationError):
    first = exc.errors()[0] if exc.errors() else {}
    location = ".".join(str(x) for x in first.get("loc", []))
    message = first.get("msg", "Invalid request data")

    if location:
        message = f"{location}: {message}"

    return JSONResponse(
        status_code=422,
        content={"code": "VALIDATION_ERROR", "message": message},
    )


async def mysql_exception_handler(request: Request, exc: MySQLError):
    return JSONResponse(
        status_code=500,
        content={
            "code": "DATABASE_ERROR",
            "message": "The database operation could not be completed.",
        },
    )
