import configparser
import sys
import safi
from  os import path
from datetime import datetime
import logging


logger = logging.getLogger(f"main.{__name__}")
logging.basicConfig(filename="jobs.log", level=logging.DEBUG,   format='%(asctime)s.%(msecs)03d %(levelname)s %(module)s - %(funcName)s: %(message)s',datefmt='%Y-%m-%d %H:%M:%S',)
formatter = logging.Formatter("%(asctime)s;%(levelname)s;%(message)s","%Y-%m-%d %H:%M:%S")
config = configparser.ConfigParser()

def load_settings():
    if(not path.exists('pgss.cfg')):      
        logger.error( datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + '-' + 'El archivo de configuración no Existe')
        sys.exit()
    config.read('pgss.cfg')
    settings=dict(config.items('DATABASE'))
    settings.update(dict(config.items('FTP')))
    print(settings)

    return settings



filename = "saldos.txt"

def main(**kwargs):
    file_name='saldos_dia.txt'
    db=safi.Session(**kwargs)
    print('session')
    print(db.is_available)
    if db.is_available :
        print('available')
        data=db.bulk_data(to_list=True)
        print(type(data))
        if(safi.Utils.to_csv(data,file_name)):
            print('Ok')
            if(safi.Utils.ftp_upload(file_name,**kwargs)):
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
