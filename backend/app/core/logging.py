"""Consistent process logging configuration."""

import logging
from logging.config import dictConfig


def configure_logging(level: str) -> None:
    """Configure concise structured-ish console logs without third parties."""

    dictConfig(
        {
            "version": 1,
            "disable_existing_loggers": False,
            "formatters": {
                "default": {
                    "format": "%(asctime)s %(levelname)s %(name)s %(message)s",
                }
            },
            "handlers": {
                "console": {
                    "class": "logging.StreamHandler",
                    "formatter": "default",
                }
            },
            "root": {"handlers": ["console"], "level": level},
        }
    )
    logging.getLogger("lullabyte").debug("Logging configured", extra={"level": level})

