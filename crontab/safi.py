from distutils.log import debug
from email import message
from sqlite3 import DatabaseError
from sre_constants import SUCCESS
import mysql.connector
from mysql.connector import errorcode
import sqlite3
import json
import requests
from decimal import *
from datetime import datetime
from sys import exit
import csv
from os import path
import  ftplib



import logging
#from modules import safi 

logger = logging.getLogger(f"main.{__name__}")
#logging.basicConfig(filename="log.txt", level=logging.DEBUG)
LAST_TRASACCTION_ID="SELECT savings_transaccion_id from SAFI"
CLIENTS_LIST="select Distinct ClienteID from CUENTASAHOMOV cm inner join CUENTASAHO c on c.CuentaAhoID=cm.CuentaAhoID   where cm.NumTransaccion>70000"
DB_FILE='/opt/progressa/data.db'
class service_stats():
    def get(self,sql_command):
        with sqlite3.connect(DB_FILE) as data:
            cursor = data.cursor()
            cursor.execute(sql_command)
            row=cursor.fetchone()
            id=row[0]
        return id


class Session():
    service=service_stats()
    
    @property
    def db_name(self):
        return self._db_name
    @db_name.setter
    def db_name(self,value):
        self._db_name=value

    @property
    def db_user(self):
        return self._db_user
    @db_user.setter
    def db_user(self,value):
        self._db_user=value
    
    @property
    def db_pass(self):
        return self._db_pass
    @db_pass.setter
    def db_pass(self,value):
        self._db_pass=value

    @property
    def db_host(self):
        return self._db_host
    @db_host.setter
    def db_host(self,value):
        self._db_host=value
    

    @property
    def db_port(self):
        return self._db_port
    @db_port.setter
    def db_port(self,value):
        self._db_port=value
    


    @property
    def db_strcon(self):
        return self._db_strcon
    @db_strcon.setter
    def db_strcon(self,value):
        self._db_strcon=value
    
    @property
    def is_available(self):
        return self._is_available
    @is_available.setter
    def is_available(self,value):
        self._is_available=value

    def __init__(self,**kwargs):
        self.db_name=kwargs.pop('dbname')
        self.db_user=kwargs.pop('dbuser')
        self.db_pass=kwargs.pop('dbpassword')
        self.db_host=kwargs.pop('dbhost')
        self.db_port=kwargs.pop('dbport')
        self.db_strcon=self._set_strconx()
        print('_init_'+ str(self._testConnection()))
        self._is_available=self._testConnection()
        #is_available=self._testConnection()

    
    def is_connected(self):
        if self.connect():
            return True
        else:
            return False
        
    
    def get_updates(self,type):
        #type=kwargs.pop('type')
        args=list()
        args.append(1)
        API_ENDPOINT='https://httpbin.org/post'
        last_id=self.service.get(LAST_TRASACCTION_ID)
        logger.info("Ultima transaccion: " + str(last_id))
        #cursor.execute('SELECT * from USUARIOS')
        db=self.connect()
        cursor=db.cursor(dictionary=True)
        cursor.execute('call PGS_MAESTROSALDOS') 
        result=cursor.fetchall()
        for row in result:
            app_json = json.dumps(row,cls=CustomEncoder)
            print(app_json)
            r = requests.post(url = API_ENDPOINT, data = app_json)
            print(r)

    def _execute_routine(self,routine,to_dict=False):
        db=self.connect()
        if(not db):
            logger.error("MySQL: Lost connection whit ["+  self.db_name +  "] ")
            exit()
        cursor=db.cursor(dictionary=True)
        try:
            cursor.execute(routine)
            #db.commit()

        except mysql.connector.Error as err:
            print(err)
            message="MySQL: On Execute ["+ routine + "] >" +str(err)
    
            logger.error(message)
            return None
        else: 
            message='MySQL:[' + routine  + '] executed sucessfully.'
            logger.info(message)
       
        return cursor.fetchall()
        
  
    def bulk_data(self,to_list=False):
        
        def to_list():
            l=[]
            for row in result:
                l.append( [i for i in row.values()])
            return l

        args=list()
        ROUTINE="call PGS_MAESTROSALDOS('G','',0,'N') "
        
        args.append(1)
        result=self._execute_routine(ROUTINE,to_dict=True)
        if not result:
            exit()
        if to_list:
            return to_list()
        else:  
            return result

   
    def _testConnection(self):
        success_connection=False
        print('init:' + str(success_connection))
        try:
            db_connection=mysql.connector.connect(**self.db_strcon)
            message="MySQL: The database is available"
            print(message)
            success_connection= True
            print('try')

        except mysql.connector.Error as err:
            if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
                message="MySQL: Authentication failed, wrong username or password"
            
            elif err.errno == errorcode.ER_BAD_DB_ERROR:
                message="MySQL: The database [" +  self.db_name +  "] don't exists"
            
            else:
                message=err
            logger.error(message)
            success_connection=False
        else:
            logger.info(message)
        return success_connection


    def connect(self):
        success_connection=False
        try:
            db_connection=mysql.connector.connect(**self.db_strcon)
            message="MySQL: Database connection is open."
            success_connection=True

        except mysql.connector.Error as err:
            if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
                message="MySQL: Authentication failed, wrong username or password"
            elif err.errno == errorcode.ER_BAD_DB_ERROR:
                message="MySQL: The database [" +  self.db_name +  "] don't exists"
            else:
                message=err        
            logger.error(message)
            return None
        else:
        #     db_connection.close()
            logger.info(message)
        return db_connection #success_connection

    def _set_strconx(self):
        str_cnx=dict( user=self.db_user,
                                    password=self.db_pass,
                                    host=self.db_host,
                                    database=self.db_name,
                                    port=self.db_port)
        print (str_cnx)
        return str_cnx


## UTISL


class CustomEncoder(json.JSONEncoder):
    def default(self, obj):
        # 👇️ if passed in object is instance of Decimal
        # convert it to a string
        if isinstance(obj, Decimal):
            return str(obj)
        if isinstance(obj, datetime):
            return str(obj)
        # 👇️ otherwise use the default behavior
        return json.JSONEncoder.default(self, obj)

class Utils:
    def to_csv(data,filename):
        with open(filename, 'w') as f:  
            writer = csv.writer(f, delimiter ='|')          
            writer.writerows(data)
        if not path.exists(filename):
            message="IO/OS: the file don't was generate."
            logger.error(message)
            return False
        else:
            message="IO/OS: Bulk data on ["+filename +"] file sucessfully."
            logger.info(message)

            
        return True

        
    def ftp_upload(file,**kwargs):
        ftp_user=kwargs.pop('ftpuser')
        ftp_pass=kwargs.pop('ftppassword')
        ftp_port=kwargs.pop('ftpport')
        ftp_dir=kwargs.pop('ftpremotedir')
        ftp_host=kwargs.pop('ftphost')
        print(ftp_host + ftp_user + ftp_pass)
        try:
            ftp = ftplib.FTP(ftp_host, ftp_user, ftp_pass)
            print(ftp_dir)
            ftp.cwd(ftp_dir)
        except ftplib.all_errors as e:
            message='FTP:' + str(e) + ''
            logger.error(message)
            return False

        else:
            message='FTP:Open conection whit server'
            logger.info(message)
        ftp.encoding = "utf-8"
        ftp_message=''
        
        try:
            with open(file, "rb") as f:
                # use FTP's STOR command to upload the file
                message= 'FTP:' +  ftp.storbinary(f"STOR {file}", f)
                logger.Info(message)
        except ftplib.all_errors as e:
            message='FTP:' + str(e) + ''
            logger.error(message)
            return False
        else:
            message='FTP: File upload successfully'
            logger.Info(message)
            return True
        pass