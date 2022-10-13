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
current_dir = path.dirname(path.realpath(__file__))
parent_dir=path.dirname(current_dir)
print (parent_dir)
config_file=parent_dir + '/' +'pgss.cfg'
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
    print()
    #file_name='saldos_dia.txt'
    #file_name=safi.Utils.get_filename(*kwargs)
    #kwargs.pop('SaldosDiariosFileName') 

    db=safi.Session(**kwargs)
    #print('session')
    #print(db.is_available)
    if db.is_available :
        print('data base is available')
        data=db.bulk_data(to_list=True)
        print(type(data))
        file_name=safi.Utils.to_csv(data,**kwargs)
        if(file_name):
            print('File generated')
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

