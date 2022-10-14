import configparser
import sys
from  lib import safi
from  os import path
from datetime import datetime
import logging


logger = logging.getLogger(f"main.{__name__}")
logging.basicConfig(filename="/opt/progressa/crontab/jobs.log", level=logging.DEBUG,   format='%(asctime)s.%(msecs)03d %(levelname)s %(module)s - %(funcName)s: %(message)s',datefmt='%Y-%m-%d %H:%M:%S',)
formatter = logging.Formatter("%(asctime)s;%(levelname)s;%(message)s","%Y-%m-%d %H:%M:%S")
config = configparser.ConfigParser()
current_dir = path.dirname(path.realpath(__file__))
#parent_dir=path.dirname(current_dir)
parent_dir=path.dirname(current_dir)
print (parent_dir)
config_file=parent_dir + '/' +'pgss.cfg'
config_file=current_dir + '/' +'pgss.cfg'
print(config_file)



def load_settings():
    if(not path.exists(config_file)):      
        logger.error( datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + '-' + 'El archivo de configuración no Existe')
        sys.exit()
    config.read(config_file)
    settings=dict(config.items('DATABASE'))
    settings.update(dict(config.items('FTP')))
    settings.update(dict(config.items('SALDOSDIARIOS')))
    print(settings)

    return settings


config_file
filename = "saldos.txt"

def main(**kwargs):


    db=safi.Session(**kwargs)

    if db.is_available :
        print('data base is available')
        #direccion_cliente=db.Request.Client('address').add(ClienteID=cliente_pk,NumList=option)
        #raw_data=db.get(direccion_cliente)
        saldos_globales=safi.Request.Integracion('saldos_diarios').add()
        #data=db.bulk_data(to_list=True)
        data=db.get(saldos_globales)
        #print(type(data))
        print(data)
        file=safi.Utils.to_csv(data,**kwargs)
        if(file):
            print('File generated')
            if(safi.Utils.ftp_upload(fie,**kwargs)):
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

settings=load_settings()        
print(type(settings))
main(**settings)


