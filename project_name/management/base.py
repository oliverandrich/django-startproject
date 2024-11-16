import logging
import os
import sys
from logging.handlers import RotatingFileHandler
from pathlib import Path
from typing import Any, Dict

from django.conf import settings
from django_typer.management import TyperCommand
from environs import Env

# Constants
DEFAULT_MAX_LOG_FILE_SIZE = 10 * 1024 * 1024  # 10 MB
DEFAULT_MAX_LOG_BACKUP_COUNT = 10


class BaseCommand(TyperCommand):
    def execute(self, *args: Any, **options: Dict[str, Any]) -> Any:
        """
        Set up logging and execute the command.

        This method overrides the default execute method to set up logging before running the
        command. It configures a logger with both file and console handlers (if run from the
        command line).

        Args:
            *args: Variable length argument list.
            **options: Arbitrary keyword arguments. Notable options include:
                - debug (bool): If True, sets logging level to DEBUG. Otherwise, sets to INFO.

        Returns:
            Any: The result of the superclass's execute method.

        Behavior:
        1. Sets up a logger named after the command being executed.
        2. Configures logging level based on the 'debug' option.
        3. Sets up a RotatingFileHandler for log files:
           - Log files are stored in the 'logs' directory with the name '{command_name}.log'.
           - Max log file size and backup count are configurable via environment variables.
        4. If run from a terminal, adds a StreamHandler for console output.
        5. Calls the superclass's execute method to run the actual command.

        Note:
        - Log file rotation settings can be customized using environment variables:
          {COMMAND_NAME}_MAX_LOG_FILE_SIZE and {COMMAND_NAME}_MAX_LOG_BACKUP_COUNT
        """
        command_name = sys.argv[1]

        # Set up the logger for the current command
        self.logger = logging.getLogger(command_name)

        # Set the logging level based on the debug option
        self.logger.setLevel(logging.DEBUG if options.get("debug") else logging.INFO)

        # Disable logging propagation to avoid duplicate logs
        self.logger.propagate = False

        # Define the logging format used for logfiles and the console handler.
        formatter = logging.Formatter("%(levelname)-8s %(asctime)s [%(process)-8d] %(message)s")

        # Set up the rotating file handler for the current command's log file.
        env = Env()
        env.read_env()
        logfile = Path(settings.BASE_DIR) / "logs" / f"{command_name}.log"
        max_bytes = env.int(
            f"{command_name.upper()}_MAX_LOG_FILE_SIZE", default=DEFAULT_MAX_LOG_FILE_SIZE
        )
        backup_count = env.int(
            f"{command_name.upper()}_MAX_LOG_BACKUP_COUNT", default=DEFAULT_MAX_LOG_BACKUP_COUNT
        )
        filehandler = RotatingFileHandler(
            logfile,
            maxBytes=max_bytes,
            backupCount=backup_count,
            encoding="utf-8",
        )
        filehandler.setFormatter(formatter)
        self.logger.addHandler(filehandler)

        # If the management command is run from the command line, add a console handler to display
        # logs in real-time.
        if os.isatty(sys.stdout.fileno()):
            consolehandler = logging.StreamHandler()
            consolehandler.setFormatter(formatter)
            self.logger.addHandler(consolehandler)

        return super().execute(*args, **options)
