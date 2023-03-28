import logging.config

logging.config.fileConfig(
    "logging.conf",
    defaults={"logfilename": "mmmbot.log"},
    disable_existing_loggers=False,
)
