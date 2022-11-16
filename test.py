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
logging.basicConfig(datasetname="/opt/progressa/service.log", level=logging.DEBUG,   format=log_output_format,datefmt='%Y-%m-%d %H:%M:%S')


#---------------------------------------------------------------------------
# Nota: Toda la funcionalidad debe estar contenida en main
#---------------------------------------------------------------------------

def main():
    POOL_SIZE=20
    settings=support.load_settings()        
    db=safi.Session(**settings)

    if db.is_available :
        vencimientos=safi.Request.Cartera('vencimientos').add(FechaInicio='2022-09-01',FechaFin='2022-09-12')
        
        data=db.get(vencimientos,format='raw')
        #dataset=safi.Utils.to_csv(data,**kwargs)
        if(data):                       
            data_block=safi.Utils.paginate(data,POOL_SIZE)
            n=0
            request_list=[]
            for row in data_block:
                n+=1
                #print (row)
                #print('vuelta='+str(n))
                request_list=safi.Request.Bulk('pago-credito',row).parse(CreditoID='CreditoID', MontoPagar='Pago',CuentaID='CuentaID')
                #print((request_list))
                
                for request in  request_list:
                    print(request.routine)
                    print(request.parameters)
                    resultado=db.get(request,format='raw')[0]
                    #print((resultado))
                    #if(resultado['NumErr']>0):
                    print(resultado['ErrMen'])

                

        #print(data)
        #print('done..')
 
#-------------------------------------------------------------------------
#  RUN !
#-------------------------------------------------------------------------
     
main()

#--------------------------------------------------------------------------






