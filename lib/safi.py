from lib.database import Repository
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
from datetime import datetime,date
from sys import exit
import csv
from os import path
import  ftplib



import logging

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
    '''
    Gestiona la conexión con la base de datos 
    asi como la interacción con la misma
    '''
    REQUESTS_HEADER = {'Content-type': 'application/json'}
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
        #print('_init_'+ str(self._testConnection()))
        self._is_available=self._testConnection()



    def get(self,request,format='raw'):
        '''
        Obtiene de la base de datos la petición 'Safi.Request' y la devuelve en  el formato requerido
        Por default devuelve un objeto cursor.
        '''
        def json_str(resulset):
            data_json=[]
            for row in resulset:
                json_str = json.dumps(row,cls=Generic.CustomJsonEncoder)
                data_json.append(json_str)
            
            return data_json

        def only_data(resultset):
            '''
            Devuelve el resultset en formato de lista sin encabezados.
            '''
            data_no_headers=[]
            for row in resultset:
                data_no_headers.append( [i for i in row.values()])
            return data_no_headers
            pass
        
        def fetch_raw(resultset):
            '''
            Devuelve el resultset en formato de lista sin encabezados.
            '''
            #print("raw");
            results=[]
            #print(type(resultset))
            for a in resultset:
             #   print(type(a))
             #   print(a)
                results.append(a)
            return results
        print(type(request))
        params=request.parameters
        routine=request.routine
        resultset=self._run(routine,params)
        #print("AQUI")
                
        #print(type(resultset))
        if format=='json':
         #   print("JS")
            return json_str(resultset)
     
        if format=='onlydata':
          #  print("OD")
            return only_data(resultset)
            
        if format=='raw':
           #     print("RW")
                return fetch_raw(resultset) 
        raw_data=resultset
        return raw_data


        



    def fetch_raw_old(self, cursor):

        columns = [col[0] for col in cursor.description]
        #print (cursor.rowcount)
        #print (columns)
        if cursor.rowcount>1:
            results=[]
        else:
            results={}
        #results = []
        for row in cursor.fetchall():
            #print (row)
            if cursor.rowcount>1:
                results.append(dict(zip(columns, row))) # for list
            else:


                results=dict(zip(columns, row))
            #print(row)
            #print(results)
        return cursor.fetchall()

    
    def is_connected(self):
        '''
        Devuelve el ultimo estatus de la conexión.
        '''
        if self.connect():
            return True
        else:
            return False
        
    
    def get_updates(self,type):
        #type=kwargs.pop('type')
        args=list()
        args.append(1)
        API_ENDPOINT='http://localhost:8000/bodesa/api/saldosdetalle/'
        last_id=self.service.get(LAST_TRASACCTION_ID)
        logger.info("Ultima transaccion: " + str(last_id))
        #cursor.execute('SELECT * from USUARIOS')
        db=self.connect()
        cursor=db.cursor(dictionary=True)
        cursor.execute("call PGS_MAESTROSALDOS('I','T',556,'S') ") 
        result=cursor.fetchall()
        for row in result:
            app_json = json.dumps(row,cls=Utils.CustomJsonEncoder)
            #print(app_json)

            r = requests.post(url = API_ENDPOINT, data = app_json,headers=self.REQUESTS_HEADER)
            #print(r.status_code)


    def _run(self,routine,params):
        '''Devuelve un objeto Cursor'''
        db=self.connect()
        if(not db):
            logger.error("MySQL: Lost connection whit ["+  self.db_name +  "] ")
            exit()
        #cursor=db.cursor()
        print(routine)
        print(params)
        try:
            #cursor.callproc(routine,params)
            with db.cursor(dictionary=True) as cursor:  
                cursor.callproc(routine,params)
                for result in cursor.stored_results():
                    #print (result)
                    pass
                #    r
            
                #print(rows)
                #print('tupoCursor:',rows)
        except mysql.connector.Error as err:
            print(err)
            message="MySQL: On Execute ["+ routine + "] >" +str(err)    
            logger.error(message)
            return None
        else: 
            message='MySQL:[' + routine  + '] executed sucessfully.'
            logger.info(message)
        return result


    
    def _execute_routinde(self,routine,to_dict=True):
            db=self.connect()
            if(not db):
                logger.error("MySQL: Lost connection whit ["+  self.db_name +  "] ")
                exit()
            cursor=db.cursor(dictionary=to_dict)
            try:
                cursor.execute(routine)
                #db.commit()

            except mysql.connector.Error as err:
                #print(err)
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
        result=self.d(ROUTINE,to_dict=True)
        if not result:
            exit()
        if to_list:
            return to_list()
        else:  
            return result


   
    def _testConnection(self):
        success_connection=False
        #print('init:' + str(success_connection))
        try:
            db_connection=mysql.connector.connect(**self.db_strcon)
            message="MySQL: The database is available"
            #print(message)
            success_connection= True
            #print('try')

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
        '''
        Devuelve un objeto de  conexión con la Base de datos
        '''
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
        #print (str_cnx)
        return str_cnx


class Request():
    def __init__(self,user,Engine):
        #repo=Repository()
        #print(type(self))
        self._audit=[ 1, 1, datetime.now(), '127.0.0.1', 'api.rest', 1, 1]
        pass
     
      
    class GenericRequest():
        '''
        Permite instanciar las peticiones a la BD como instancias de clase SAFI.Request en lugar de 
        usar directamente las rutinas de BD.
        '''
        def __init__(self,request):
            #print(repo)
            self._properties=''
            self._parameters=[]
            self._routine=''
        
        def get_props(self,request, repository):
            '''
            Obtiene las propiedades de ejecucución del 'SAFI.Request' solicitado.
            '''
            return [element for element in repository if element['keyword'] == request]
        
        def add_bulk(self,**kwargs):
            class ParsedRequest():
                @property
                def parameters(self):
                    return self._parameters
                
                @parameters.setter
                def parameters(self,value):
                    self._parameters = value
                    
                @property
                def routine(self):
                    return self._routine
                
                @routine.setter
                def routine(self,value):
                    self.routine = value
                def __init__(self,outer,**kwargs):
                    self._parameters=kwargs
                    self._routine=outer.routine
                    pass
                pass

            parsed=ParsedRequest(self,**kwargs)
            return ParsedRequest
            

        def add(self,**kwargs):
            '''
            Agrega parametros al 'SAFI.Request' e inicializa con los valores default
            aquellos que no son proporcionados explicitamente.
            '''
            raw_parameters=[]
            #print(self.properties)
            unpack=self.properties[0]
            self._routine=unpack['routine']
            parameter_properties=unpack['parameters']
            for par in parameter_properties:
                #print(par['name'])
                value= kwargs.get(par['name'],par['default'])
                raw_parameters.append(value)
            self._parameters= raw_parameters
            print('raw')
            print (raw_parameters)
            return self
  
        
        @property
        def properties(self):
            return self._properties
        
        @properties.setter
        def properties(self,value):
            self._properties = value
        
        @property
        def parameters(self):
            return self._parameters
        
        @parameters.setter
        def parameters(self,value):
            self._parameters = value
            
        @property
        def routine(self):
            return self._routine
        
        @routine.setter
        def routine(self,value):
            self._routine = value 

    class Account(GenericRequest):
        def __init__(self,request):
            super().__init__(request)
            repository=Repository.Account
            self.properties=self.get_props(request,repository)
    
    class Integracion(GenericRequest):
        def __init__(self,request):
            super().__init__(request)
            repository=Repository.Integracion
            self.properties=self.get_props(request,repository)
    
    class Cartera(GenericRequest):
        def __init__(self,request):
            super().__init__(request)
            repository=Repository.Cartera
            self.properties=self.get_props(request,repository)


    
    class Bulk(GenericRequest):
        

        



        @property
        def source(self):
            return self._source
        
        @source.setter
        def source(self,value):
            self._source = value
        
        
        def __init__(self, request,datasource):
            super().__init__(request)
            repository=Repository.Bulk
            self.properties=self.get_props(request,repository)
            print(self.properties)
            self._source=datasource

            
        def parse(self,**kwargs):
            '''
            
            Mapea cada parametro <Key> de Kwargs con  el valor correspondiente del <value> (como key)
            dentro del origen de datos <dataset> por cada item del mismo, para generar una lista de 
            instancias Safi.Request  ejecutables.

            '''
            raw_parameters=[]
            print(type(kwargs))
            #print(self.properties)
            #unpack=self.properties[0]
            #self._routine=unpack['routine']
            #parameter_properties=unpack['parameters']
            #print (self._source)
            list_request=[]
            for row in self._source:
                #print (row)
                #for par in kwargs:
                add_args={}
                for  key, value in kwargs.items():
                    #print(key,value)
                    key_value=row.get(value,-1)
                    if key_value==-1:
                        raise Exception ("No existe un elemento: <" + value + "> dentro de la colección, <" + key + "> no puede ser mapeado." );
                    #print('Key: ' + key +', value: ' + str(key_value))
                    add_args[key]=key_value
                
                print ("add_args", add_args)
           
                #self._parameters=
              
                #self._parameters=add_args
                request_item=self.add_bulk(**add_args)
                print(type(request_item))
                #print(type(request_item))
                #request_item.__dict__ = self.__dict__.copy() 
                #request_item._parameters=add_args;
                print('objeto_instanciado:' + request_item.routine)
                list_request.append(request_item)
                print ('items' + str(list_request.__len__()))

                #value= kwargs.get(par['name'],par['default'])
                #raw_parameters.append(value)
            #self._parameters= raw_parameters
            
            return (list_request)

    class _BulkParsedRequest(GenericRequest):
        def __init__(self,request):
            super().__init__(request)
            repository=Repository.Bulk
            self.properties=self.get_props(request,repository)
        

#---------------------------------------------------------------------------
# Utilerias
#---------------------------------------------------------------------------


class Utils:
    
    def paginate(dataset,limit):
        '''
        Return a generator as a data subset by paginate a iterable object on set's of <limit> items using a lazy iterator.
        '''
        
        def _yield_row(dataset):                
           # i=0
            for row in dataset:
                yield row
            pass

        data=[]
        row_iterator=_yield_row(dataset)
        for item in row_iterator:
            data.append(item)
            if(len(data)>=limit):
                print("-"*10)
                row_list=data
                data=[]
                yield row_list

    def post(data,**kwargs):
        REQUESTS_HEADER = {'Content-type': 'application/json'}
        api_endpoint=kwargs.pop('apiupdateendpoint')
        message='API: POST:' + api_endpoint
        logger.info(api_endpoint)
        print(api_endpoint)
        for row in data:
            print (row)
            print(type(row))
            r = requests.post(url = api_endpoint, data = row,headers=REQUESTS_HEADER)
            print (r)
        pass
                
    def to_csv(data,**kwargs):
        '''
        file_extension=
        field_separator=
        file_name=
        '''
        current_date=datetime.now().strftime("%Y-%m-%d")
        file_extension=kwargs.pop('fileformat')
        field_separator=kwargs.pop('fieldseparator')
        file_name=kwargs.pop('filename') + '_'+ current_date + '.' +file_extension
        file_dir=kwargs.pop('directory') + '/'
        full_filename=file_dir + file_name 
        #file_dir=kwargs.pop('directory')
        print(file_dir)
        file=Generic.File(file_name,file_dir)
        

        with open(full_filename, 'w') as f:  
            writer = csv.writer(f, delimiter =field_separator)          
            writer.writerows(data)
        if not path.exists(full_filename):
            message="IO/OS: the file don't was generate."
            logger.error(message)
            return False
        else:
            message="IO/OS: Bulk data on ["+full_filename +"] file sucessfully."
            logger.info(message)

            
        return file


    def get_filename(**kwargs):
        file_name=kwargs.pop('filename')
        file_extension=kwargs.pop('fileformat')
        file_dir=kwargs.pop('directory')
     
        full_filename=file_dir + '/' + file_name + '' + file_extension
        #file_separator=kwargs.pop('fieldseparator')
        pass
        
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
        print ('full' + file.full_name)
        print(file.name)

        print(file.path)        
        try:
            with open(file.full_name, "rb") as f:
                # use FTP's STOR command to upload the file
                print(ftp.cwd(ftp_dir))
                print(ftp.nlst())
                print (file)
                message= 'FTP:' +  ftp.storbinary(f"STOR {file.name}", f)
                #f.storbinary('STOR ' + file.name,f)
                print((message))
                logger.info(message)

        except ftplib.all_errors as e:
            message='FTP:' + str(e) + ''
            logger.error(message)
            return False
        else:
            message='FTP: File upload successfully'
            logger.info(message)
            return True
        pass

#---------------------------------------------------------------------------
# Objetos genericos
#---------------------------------------------------------------------------

class Generic():
    
    class CustomJsonEncoder(json.JSONEncoder):
        def default(self, obj):
            # if passed in object is instance of Decimal
            # convert it to a string
            if isinstance(obj, Decimal):
                return str(obj)

            if isinstance(obj, datetime):
                return obj.isoformat()

            if isinstance(obj, date):
                return str(obj)
   
            #otherwise use the default behavior
            return json.JSONEncoder.default(self, obj)
    
    class File():
        @property
        def name(self):
            return self._name
        @name.setter
        def name(self,value):
            self._name=value

        @property
        def path(self):
            return self._path
        @path.setter
        def path(self,value):
            self._path=value
        
        @property
        def full_name(self):
            return self._full_name
        @full_name.setter
        def full_name(self,value):
            self._full_name=value

        def __init__(self,file_name,file_path):
            self.name=file_name
            self.path=file_path
            self.full_name=file_path + file_name


