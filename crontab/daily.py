import ftplib

import sys
 
# directory reach
# importing
import safi


import csv



FTP_HOST='10.90.0.76'
FTP_USER='pgsftpusr'
FTP_PASS='Progressa2022-'
FTP_DIR=' /var/www/html/progressa/reportes_entrada_safi'
ftp = ftplib.FTP(FTP_HOST, FTP_USER, FTP_PASS)
DB_NAME='microfin'
DB_HOST='10.186.22.164'
DB_USER='root'
DB_PASS='Vostro1310'
DB_PORT=3308

# force UTF-8 encoding
ftp.encoding = "utf-8"

filename = "saldos.txt"

def main(**kwargs):
    """
        This is an example of code you want to run on every iteration
        You can, and probably should move this to its own Python module

        This sample code intentionally crashes once in a while to show what
        happens when your code raises an exception
    """
    db=safi.Session(db_user=DB_USER,db_pass=DB_PASS,db_host=DB_HOST,db_name=DB_NAME,db_port=DB_PORT)
    if db.is_available :
        data=db.bulk_data()
        print(type(data))
        print(data)
        #print(data)
        l=[]
        for row in data:
            l.append( [i for i in row.values()])
        print(l)
   
        with open(filename, 'w') as f:  
            writer = csv.writer(f, delimiter ='|')          
            writer.writerows(l)
    
           # l=[]
            #for row in data:
             #   l = [i for i in row.values()]
              #  print(type(l))
               # print(l) # lista

        
 
    else:
        print('ERROR AL CONECTAR CON LA BASE DE DATOS')

        

    # local file name you want to upload
    ftp_message=''
    try:
        with open(filename, "rb") as file:
            # use FTP's STOR command to upload the file
            ftp_message=ftp.storbinary(f"STOR {filename}", file) 
    except:
        print('ERROR:' + ftp_message)
        print('ERROR AL CONECTAR CON SERVIDOR FTP!')
        print('===================================')
    else:
        print('ARCHIVO CARGADO EXITOSAMENTE')
main()
