import sys
from  lib import safi,support
#from  os import path
from datetime import datetime
import logging

#---------------------------------------------------------------------------
# Congiguración de log
#---------------------------------------------------------------------------
logger = logging.getLogger(f"main.{__name__}")
log_output_format='%(asctime)s.%(msecs)03d [%(levelname)s] %(module)s - (%(funcName)s): %(message)s'
logging.basicConfig(filename="crontab/jobs.log", level=logging.DEBUG,   format=log_output_format,datefmt='%Y-%m-%d %H:%M:%S')

#---------------------------------------------------------------------------
# Nota: Toda la funcionalidad debe estar contenida en main
#---------------------------------------------------------------------------

def main():

    settings=support.load_settings()        
    db=safi.Session(**settings)

    if db.is_available :
        saldos_globales=safi.Request.Integracion('saldos_diarios').add()
        data=db.get(saldos_globales,format='onlydata')
        file=safi.Utils.to_csv(data,**settings)
        if(file):
            if(safi.Utils.ftp_upload(file,**settings)):
                message='FTP: Connection closed.'
                logger.info(message)
            else:
                message='FTP: Failed to upload file'
                logger.error(message)
        else:
            message='IO/OS:Failed to create the file'
            logger.error(message)
            exit()                   
    else:
        message='MySQL: No database connection available'
        logger.error(message)


#-------------------------------------------------------------------------
# Run !
#-------------------------------------------------------------------------
   
main()

# -------------------------------------------------------------------------



