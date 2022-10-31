import sys
import logging
import configparser
from datetime import datetime
from  os import path
import smtplib, ssl



#---------------------------------------------------------------------------
# Congiguración de log
#---------------------------------------------------------------------------
logger = logging.getLogger(f"main.{__name__}")
log_output_format='%(asctime)s.%(msecs)03d [%(levelname)s] %(module)s - (%(funcName)s): %(message)s'
logging.basicConfig(filename="service.log", level=logging.DEBUG,   format=log_output_format,datefmt='%Y-%m-%d %H:%M:%S')



def send_alert(tback, destination_addresses):
    """
        Genera la alerta para notificar una excepción no controlada en el servicio.
    """

    subject = "Service Exception Raised"

    body = "El servicio PGSS-MONITOR generó una excepción:\n [Traceback:]\n\n"
    body += tback

    # Send the actual email
    send_mail(subject=subject, body=body, to=destination_addresses)

def send_mail(subject, body, to):
    """
        Send the email
    """


    logger.warning("="*80)
    logger.warning(f"Sending email to '{to}' with subject '{subject}' about an exception being raised with body:")
    logger.warning(body)
    logger.warning("="*80)
    port = 587  # For SSL
    smtp_server = "smtp-mail.outlook.com"
    sender_email = "vladimir.jz@hotmail.com"  # Enter your address
    receiver_email = "vjimenezv@ieepo.gob.mx"  # Enter receiver address
    password = "Vostro1310"
    message = """\
    Subject: Hi there

    This message is sent from Python."""

    context = ssl.create_default_context()
    with smtplib.SMTP_SSL(smtp_server, port, context=context) as server:
        server.login(sender_email, password)
        server.sendmail(sender_email, receiver_email, message)


def format_exc_for_journald(ex, indent_lines=False):
    """
        Journald removes leading whitespace from every line, making it very
        hard to read python traceback messages. This tricks journald into
        not removing leading whitespace by adding a dot at the beginning of
        every line
    """

    result = ''
    for line in ex.splitlines():
        if indent_lines:
            result += ".    " + line + "\n"
        else:
            result += "." + line + "\n"
    return result.rstrip()


## ARchivo de configuración
# TODO:debe recibir como parametro  las secciones a cargar.

def load_settings():
    config = configparser.ConfigParser()
    current_dir = path.dirname(path.realpath(__file__))
    parent_dir=path.dirname(current_dir)
    print (parent_dir)
    print (current_dir)
    config_file=current_dir + '/' +'pgss.cfg'
    config_file=parent_dir + '/' +'pgss.cfg'
    if(not path.exists(config_file)):      
        logger.error('pgss.cfg: El archivo de configuración no existe ' + config_file + '.')
        sys.exit()
    config.read(config_file)
    settings=dict(config.items('DATABASE'))
    settings.update(dict(config.items('FTP')))
    settings.update(dict(config.items('SALDOSDIARIOS')))
    settings.update(dict(config.items('WEBSERVICES')))

    print(settings)

    return settings