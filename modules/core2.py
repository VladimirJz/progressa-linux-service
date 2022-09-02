import logging
import sqlite3
import os
import mysql.connector
logger = logging.getLogger(f"main.{__name__}")

import logging
import sqlite3
import os
import mysql.connector


logger = logging.getLogger(f"main.{__name__}")

# Keeps track of hom many times main() has run
RUN=0
#db_file = 'database.db'
schema_file = 'schema.sql'
GET_LAST_TRANSACCTION="SELECT NumTransaccion from CREDITOSMOVS ORDER BY NumTransaccion desc LIMIT 1;"
GET_PREVIOUS_TRANSACCTION="SELECT last_id from SETTINGS";

cnx = mysql.connector.connect(
    host="10.186.22.35",
    port=3306,
    user="app",
    password="Vostro1310",
    database='microfin')



class settings():
    def __init__(self):
        self.last_id=0
        self._load()    
        self.read()

        pass
    @property
    def last_id(self):
        return self._last_id
    @last_id.setter
    def last_id(self,value):
        self._last_id=value

    @property
    def db_user(self):
        return self._db_user
    @last_id.setter
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







    DB_FILE = 'data.db'
    SCHEMA_FILE = 'schema.sql'
    SETTINGS_FILE = 'monitor.cfg'
    def read(self):
        LOAD_DATA="SELECT current_date,last_update,db_user,db_pass,last_id from SETTINGS"
        with sqlite3.connect(self.DB_FILE) as data:
            cursor = data.cursor()
            cursor.execute(LOAD_DATA)
            row=cursor.fetchone()
            db_user=row[2]
            db_pass=row[3]
            db_host=row[4]
            db_port=row[5]
            db_name=row[6]
            self.last_id=row[4]
            print(self.last_id)
            print(db_user)

            


    #check if data.db exists
    #load data 

    def _getlast(self):
        with sqlite3.connect(self.DB_FILE) as conn:
            cursor = conn.cursor()
            cursor.execute(GET_PREVIOUS_TRANSACCTION)
            last_search=cursor.fetchone()


    def _check_db(self,filename):
        return os.path.exists(filename)
    
    def _load(self):
        if self._check_db(self.DB_FILE):
            logger.info("Database file already exists")
     
        else:
            with open(schema_file, 'r') as rf:
                # Read the schema from the file
                schema = rf.read()
            
            with sqlite3.connect(self.DB_FILE) as conn:
                logger.info("Initialize schema.")
                # Execute the SQL query to create the table
                #load data from file settings 
                conn.executescript(schema)
                logger.info("Schema created")


    pass

class safi():
    pass