import configparser
import sys
import ftplib
import safi
from  os import path
from configparser import ConfigParser
from datetime import datetime
import logging
# directory reach
# importing

logger = logging.getLogger(f"main.{__name__}")
#logger = logging.getLogger(f"jobs.daily")
logging.basicConfig(filename="jobs.log", level=logging.DEBUG,   format='%(asctime)s.%(msecs)03d %(levelname)s %(module)s - %(funcName)s: %(message)s',datefmt='%Y-%m-%d %H:%M:%S',)
formatter = logging.Formatter("%(asctime)s;%(levelname)s;%(message)s","%Y-%m-%d %H:%M:%S")

config = configparser.ConfigParser()

def load_settings():
    if(not path.exists('pgss.cfg')):
        
        #logger.error("El archivo de configuración no Existe")
        logger.error( datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + '-' + 'El archivo de configuración no Existe')
        sys.exit()
    config.read('pgss.cfg')
    settings=dict(config.items('DATABASE'))
    settings.update(dict(config.items('FTP')))
    print(settings)
    #print(config.sections())
    return settings
# FTP_HOST='10.90.0.76'
# FTP_USER='pgsftpusr'
# FTP_PASS='Progressa2022-'
# FTP_DIR=' /var/www/html/progressa/reportes_entrada_safi'

# DB_NAME='microfin'
# DB_HOST='10.186.22.164'
# DB_USER='root'
# DB_PASS='Vostro1310'
# DB_PORT=3308

# force UTF-8 encoding


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
            safi.Utils.ftp_upload(file_name,**kwargs)
        else:
            exit()                #print(data)
        #print(data)
       
        #print(l)
   
       
    
           # l=[]
            #for row in data:
             #   l = [i for i in row.values()]
              #  print(type(l))
               # print(l) # lista
       
       


        
 
    else:
        print('ERROR AL CONECTAR CON LA BASE DE DATOS')

        

settings=load_settings()        
print(type(settings))
main(**settings)
