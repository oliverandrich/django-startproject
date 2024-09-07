import logging
import os
import sys
from logging.handlers import RotatingFileHandler

from django.conf import settings
from django_typer.management import TyperCommand
from environs import Env


class BaseCommand(TyperCommand):
    def execute(self, *args, **options):
        command_name = sys.argv[1]

        # Set up the logger for the current command
        self.logger = logging.getLogger(command_name)

        # Set the logging level based on the debug option
        if options.get("debug"):
            self.logger.setLevel(logging.DEBUG)
        else:
            self.logger.setLevel(logging.INFO)

        # Disable logging propagation to avoid duplicate logs
        self.logger.propagate = False

        # Define the logging format used for logfiles and the console handler.
        formatter = logging.Formatter("%(levelname)-8s %(asctime)s [%(process)-8d] %(message)s")

        # Set up the rotating file handler for the current command's log file. By default it logs to
        # a file named after the command in the logs directory. The log file will be rotated after
        # reaching a certain size (default: 10 MB) and the maximum number of backups (default: 10).
        env = Env()
        env.read_env()
        logfile = settings.BASE_DIR / "logs" / f"{command_name}.log"
        max_bytes = env.int(f"{command_name.upper()}_MAX_LOG_FILE_SIZE", default=1024 * 1024 * 10)
        backup_count = env.int(f"{command_name.upper()}_MAX_LOG_BACKUP_COUNT", default=10)
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
