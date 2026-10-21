from contextlib import contextmanager
from threading import Lock
from typing import Iterator, Optional

from mysql.connector import pooling
from mysql.connector.connection import MySQLConnection

from app.core.config import settings


_pool: Optional[pooling.MySQLConnectionPool] = None
_pool_lock = Lock()


def _get_pool() -> pooling.MySQLConnectionPool:
    global _pool

    if _pool is None:
        with _pool_lock:
            if _pool is None:
                _pool = pooling.MySQLConnectionPool(
                    pool_name="event_api_pool",
                    pool_size=settings.db_pool_size,
                    host=settings.db_host,
                    port=settings.db_port,
                    user=settings.db_user,
                    password=settings.db_password,
                    database=settings.db_name,
                    autocommit=False,
                )

    return _pool


@contextmanager
def get_connection() -> Iterator[MySQLConnection]:
    connection = _get_pool().get_connection()
    try:
        yield connection
    finally:
        connection.close()


@contextmanager
def transaction() -> Iterator[MySQLConnection]:
    with get_connection() as connection:
        try:
            connection.start_transaction()
            yield connection
            connection.commit()
        except Exception:
            connection.rollback()
            raise
