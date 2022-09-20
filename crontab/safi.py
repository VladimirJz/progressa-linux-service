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


  
    def bulk_data(self):
        args=list()
        args.append(1)
        #API_ENDPOINT='https://httpbin.org/post'
        #last_id=self.service.get(LAST_TRASACCTION_ID)
        #logger.info("Ultima transaccion: " + str(last_id))
        #cursor.execute('SELECT * from USUARIOS')
        db=self.connect()
        cursor=db.cursor(dictionary=True)
        #cursor.execute('SELECT ClienteID,NombreCompleto,Sexo,RFC from CLIENTES limit 3;') 
        cursor.execute("call PGS_MAESTROSALDOS('G','',0,'N') ") 

        print('execute')
        result=cursor.fetchall()
        #print(type)
        return result
           




        

    def __init__(self,**kwargs):
        self.db_name=kwargs.pop('db_name')
        self.db_user=kwargs.pop('db_user')
        self.db_pass=kwargs.pop('db_pass')
        self.db_host=kwargs.pop('db_host')
        self.db_port=kwargs.pop('db_port')

        self.db_strcon=self._set_strconx()

        self=is_available=self._is_available()


   
    def _is_available(self):
        success_connection=False
        try:
            db_connection=mysql.connector.connect(**self.db_strcon)
            message="Conectado a la BD Exitosamente."
            success_connection=True

        except mysql.connector.Error as err:
            if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
                message="Usuario o contraseña incorrecta."
            elif err.errno == errorcode.ER_BAD_DB_ERROR:
                message="La base de datos no exists."
            else:
                message=err
            success_connection=False
        else:
            db_connection.close()
        logger.info(message)
        return success_connection


    def connect(self):
        success_connection=False
        try:
            db_connection=mysql.connector.connect(**self.db_strcon)
            message="Conectado a la BD Exitosamente."
            success_connection=True

        except mysql.connector.Error as err:
            if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
                message="Usuario o contraseña incorrecta."
            elif err.errno == errorcode.ER_BAD_DB_ERROR:
                message="La base de datos no exists."
            else:
                message=err
        # else:
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
