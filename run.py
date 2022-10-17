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
logging.basicConfig(filename="/opt/progressa/service.log", level=logging.DEBUG,   format=log_output_format,datefmt='%Y-%m-%d %H:%M:%S')


#---------------------------------------------------------------------------
# Nota: Toda la funcionalidad debe estar contenida en main
#---------------------------------------------------------------------------

def main():

    settings=support.load_settings()        
    db=safi.Session(**settings)

    if db.is_available :
        saldos_actualizados=safi.Request.Integracion('saldos_diarios').add()
        data=db.get(saldos_actualizados,format='onlydata')
        #file=safi.Utils.to_csv(data,**kwargs)
        print(data)

#-------------------------------------------------------------------------
#  RUN !
#-------------------------------------------------------------------------
     
main()

#--------------------------------------------------------------------------






