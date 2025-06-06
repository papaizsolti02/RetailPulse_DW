"""
Configures the root logger with basic settings.

- Sets the logging level to INFO, so all INFO, WARNING, ERROR, and CRITICAL messages are logged.
- Defines the log message format to include:
    - Timestamp (hours:minutes:seconds)
    - Log level name
    - Logger name
    - Log message
- Specifies the timestamp format as HH:MM:SS.

This configuration applies globally to all loggers unless overridden.
"""

import logging

logging.basicConfig(
    level=logging.INFO,
    format='[%(asctime)s] [%(levelname)s] %(name)s: %(message)s',
    datefmt='%H:%M:%S'
)
