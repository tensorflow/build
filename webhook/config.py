import multiprocessing
import os


PORT = int(os.environ.get("PORT", 5000))
DEBUG_MODE = int(os.environ.get("DEBUG_MODE", 0))

ALLOWED_EVENTS = [
    'push',
]

ALLOWED_REPOS = [
    'tensorflow/build',
    'perfinion/build',
]

# Gunicorn config
bind = ":" + str(PORT)
workers = multiprocessing.cpu_count() * 2 + 1
threads = multiprocessing.cpu_count() * 2
