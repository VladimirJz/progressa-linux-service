from email import message
from sqlite3 import DatabaseError
from sre_constants import SUCCESS
import mysql.connector
from mysql.connector import errorcode
import sqlite3

import logging
from modules import safi 

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
    
    def __init__(self,**kwargs):
        self.db_name=kwargs.pop('db_name')
        self.db_user=kwargs.pop('db_user')
        self.db_pass=kwargs.pop('db_pass')
        self.db_host=kwargs.pop('db_host')
        
    def _execute(self):
        self.connection
        pass    

    def connection(self):
        success_connection=False
        try:
            db_connection=mysql.connector.connect(user=self.db_user,
                                    password=self.db_pass,
                                    host=self.db_host,
                                    database=self.db_name)
            message="Conectado a la BD Exitosamente."
            success_connection=True

        except mysql.connector.Error as err:
            if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
                message="Usuario o contraseña incorrecta."
            elif err.errno == errorcode.ER_BAD_DB_ERROR:
                message="La base de datos no exists."
            else:
                message=err
        else:
            db_connection.close()
        logger.info(message)
        return db_connection #success_connection


    def get_updates(self,**kwargs):
        type=kwargs.pop('type')
        last_id=self.service.get(LAST_TRASACCTION_ID)
        logger.info("Ultima transaccion: " + str(last_id))



        

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



    pass
