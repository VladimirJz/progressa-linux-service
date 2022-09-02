import logging
from modules import db

logger = logging.getLogger(f"main.{__name__}")
logging.basicConfig(filename="log.txt", level=logging.DEBUG)
# Keeps track of hom many times main() has run
RUN=0

def main(**kwargs):
    """
        This is an example of code you want to run on every iteration
        You can, and probably should move this to its own Python module

        This sample code intentionally crashes once in a while to show what
        happens when your code raises an exception
    """
    safi=db.Session(**kwargs)
    logger.info(type(safi))
    if(safi):
        logger.info("Continuar")
        safi.get_updates(type='detail')
        
        
    else:
        logger.error("CRITICAL:No existe conexión con la base de datos")
        raise Exception("NO DATABASE CONNECTION AVAILABLE")
    
    # Increment run counter
    global RUN
    RUN += 1

    # If the number of times we've run is a multiple of 3, crash!
    if RUN % 3 == 0:
        raise Exception("Something failed!")
    else:
        logger.info("Running our code")
        logger.info("Conectando a " + safi.db_name)

