
import os
import sys
import logging
import signal
import socket
import time
import traceback
from run import main
from lib.support import send_alert, format_exc_for_journald

import configparser



#---------------------------------------------------------------------------
# Congiguración de log
#---------------------------------------------------------------------------
logger = logging.getLogger(f"main.{__name__}")
log_output_format='%(asctime)s.%(msecs)03d [%(levelname)s] %(module)s - (%(funcName)s): %(message)s'
logging.basicConfig(filename="/opt/progressa/service.log", level=logging.DEBUG,   format=log_output_format,datefmt='%Y-%m-%d %H:%M:%S')



####################
# Global Variables #
####################

# If the DEBUG environment variable is set, uses that to set the DEBUG
# global variable
# If the environment variable isn't set, only sets DEBUG to True if we're
# running in a terminal (as opposed to systemd running our script)
if "DEBUG" in os.environ:
    # Use Environment Variable
    if os.environ["DEBUG"].lower() == "true":
        DEBUG = True
    elif os.environ["DEBUG"].lower() == "false":
        DEBUG = False
    else:
        raise ValueError("DEBUG environment variable not set to 'true' or 'false'")
else:
    # Use run mode
    if os.isatty(sys.stdin.fileno()):
        DEBUG = True
    else:
        DEBUG = False

# Script name
script_name = os.path.basename(__file__)

# Get logger
logger = logging.getLogger("main")

# How long to sleep, in seconds, when running in DEBUG mode
DEBUG_RUN_INTERVAL = 10

# How long to sleep, in seconds, when running in non-DEBUG mode
PRODUCTION_RUN_INTERVAL = 60

# List of email addresses to send emails to when something crashes
ADMIN_EMAILS = ["vladimir.jz@hotmail.com"]

# USR1 flag
USR1_KILL_SIGNAL_SET = False

############################
# User Settings Variables  #
############################



DB_NAME='microfin'
DB_HOST='10.186.22.37'
DB_PORT=3308
DB_USER='root'
DB_PASS='Vostro1310'
END_POINT='http://api2.bodesa.com/endpoint/'

################
# Setup Logger #
################

# Setup handler
logger.addHandler(logging.StreamHandler())

# Set logging level
if DEBUG:
    logger.setLevel(logging.DEBUG)
else:
    logger.setLevel(logging.INFO)

###########################
# Handler para el SIGTERM #
###########################

def signal_handler(*_):
    logger.debug("\nExiting...")
    sys.exit(0)

signal.signal(signal.SIGINT, signal_handler)
signal.signal(signal.SIGTERM, signal_handler)

def set_usr1_flag(*_):
    global USR1_KILL_SIGNAL_SET
    USR1_KILL_SIGNAL_SET = True

# If another process requests us to run main without waiting, do it
signal.signal(signal.SIGUSR1, set_usr1_flag)

#############################################
# Check if another instance already running #
#############################################

# Since systemd will never run 2 instances of a service at once, the only
# time this would happen is if a service was running, and someone tried to
# run the script manually from terminal at the same time

lock_socket = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)

try:
    lock_socket.bind('\0' + script_name)
except socket.error:
    logger.error(f"Another instance of {script_name} is already running")
    sys.exit(1)

#############
# Functions #
#############

def get_time_waited(last_run):
    """
        Given the lat time main() was run, looks at the current time
        (represented by time.perf_counter()) and figures out how long it's
        been (in seconds)
    """
    return time.perf_counter() - last_run

##############
# Properties #
##############


def load_settings(settings_file, settings_dict=None):
    config = configparser.ConfigParser()
    if settings_dict:
        config.read_dict(settings_dict)
    else:
        config.read(settings_file)
    
    debug = config["APP"].getboolean("DEBUG")
    print(type(debug))
    # <class 'bool'>
    name = config.get('APP', 'NAME', fallback='NAME is not defined')
    print(name)
    return debug




########
# Main #
########

# Keep track of the last time main() ran
# We start with -1000 so that on the first run, main() always triggers
# without waiting
last_run = -1000

while True:
    ###########################
    # Wait Between Iterations #
    ###########################

    time.sleep(1)


    if USR1_KILL_SIGNAL_SET:
        # Reset the flag and go on to run main()
        USR1_KILL_SIGNAL_SET = False
    elif DEBUG and get_time_waited(last_run) >= DEBUG_RUN_INTERVAL:
        # Go on to run main()
        pass
    elif not DEBUG and get_time_waited(last_run) >= PRODUCTION_RUN_INTERVAL:
        # Go on to run main()
        pass
    else:
        # Keep waiting
        continue

    try:
 
        print ("here")
        logger.info("Antes de main")
        main()

    except Exception:
        logger.error(format_exc_for_journald(traceback.format_exc(), indent_lines=False))
        send_alert(traceback.format_exc(), destination_addresses=ADMIN_EMAILS)
    finally:
        last_run = time.perf_counter()
        logger.debug(f"Waiting {DEBUG_RUN_INTERVAL} seconds...")
