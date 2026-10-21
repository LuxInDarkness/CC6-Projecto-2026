import os
from dataclasses import dataclass

from dotenv import load_dotenv

load_dotenv()


@dataclass(frozen=True)
class Settings:
    db_host: str = os.getenv("DB_HOST", "localhost")
    db_port: int = int(os.getenv("DB_PORT", "3306"))
    db_user: str = os.getenv("DB_USER", "root")
    db_password: str = os.getenv("DB_PASSWORD", "Caramelit@1")
    db_name: str = os.getenv("DB_NAME", "event_management")
    db_pool_size: int = int(os.getenv("DB_POOL_SIZE", "10"))


settings = Settings()
