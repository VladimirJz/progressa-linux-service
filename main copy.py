import logging
import sqlite3
import os
import mysql.connector


logger = logging.getLogger(f"main.{__name__}")

# Keeps track of hom many times main() has run
RUN=0
db_file = 'database.db'
schema_file = 'schema.sql'
GET_LAST_TRANSACCTION="SELECT NumTransaccion from CREDITOSMOVS ORDER BY NumTransaccion desc LIMIT 1;"
GET_PREVIOUS_TRANSACCTION="SELECT last_id from SETTINGS";

cnx = mysql.connector.connect(
    host="10.186.22.35",
    port=3306,
    user="app",
    password="Vostro1310",
    database='microfin')



def main():
    """
        This is an example of code you want to run on every iteration
        You can, and probably should move this to its own Python module

        This sample code intentionally crashes once in a while to show what
        happens when your code raises an exception
    """
    
    db_file = 'data.db'
    schema_file = 'schema.sql'

    if check_db(db_file):
        logger.info("Database file already exists")
        with sqlite3.connect(db_file) as conn:
            cursor = conn.cursor()
            cursor.execute(GET_PREVIOUS_TRANSACCTION)
            last_search=cursor.fetchone()
            print (last_search)
            print('done')
        
        with cnx as consafi:
            cursor = consafi.cursor()
            cursor.execute(GET_LAST_TRANSACCTION)
            last_transaction=cursor.fetchone()
            print (last_transaction)
     

        #exit(0)
    else:
        with open(schema_file, 'r') as rf:
            # Read the schema from the file
            schema = rf.read()
        
        with sqlite3.connect(db_file) as conn:
            logger.info("Create temporal schema.")
            # Execute the SQL query to create the table
            #load data from file settings 
            conn.executescript(schema)
            logger.info("CreateSchema")
            


    
    


    """
    Handler
    """

    # Increment run counter
    global RUN
    RUN += 1

    # If the number of times we've run is a multiple of 3, crash!
    if RUN % 3 == 0:
        raise Exception("Something failed!")
    else:
        logger.info("Running our code")

def check_db(filename):
    return os.path.exists(filename)

main()