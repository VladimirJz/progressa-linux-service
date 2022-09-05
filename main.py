from configparser import SafeConfigParser
import logging
from modules import safi

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
    db=safi.Session(**kwargs)
    logger.info(type(db))
    if db.is_available :
        logger.info("Continuar")
        db.get_updates(type='detail')
        
        
    else:
        logger.error("CRITICAL:No existe conexión con la base de datos")
        raise Exception("NO DATABASE CONNECTION AVAILABLE")
        print ("Error de conexion")
    

    # Increment run counter
    # global RUN
    # RUN += 1

    # # If the number of times we've run is a multiple of 3, crash!
    # if RUN % 3 == 0:
    #     raise Exception("Something failed!")
    # else:
    #     logger.info("Running our code")
    #     logger.info("Conectando a " + safi.db_name)


