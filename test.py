from configparser import SafeConfigParser
import logging
from modules import safi
from main import main

logger = logging.getLogger(f"main.{__name__}")
logging.basicConfig(filename="log.txt", level=logging.DEBUG)
# Keeps track of hom many times main() has run
RUN=0

DB_NAME='microfin'
DB_HOST='10.186.22.164'
DB_USER='root'
DB_PASS='Vostro1310'
DB_PORT=3308
END_POINT='http://localhost:8000/bodesa/api/saldosdetalle/'

main(db_name=DB_NAME,db_host=DB_HOST,db_port=3308,db_user=DB_USER,db_pass=DB_PASS)