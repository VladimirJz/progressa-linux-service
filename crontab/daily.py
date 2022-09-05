import ftplib

import sys
 
# directory reach
# importing
import safi





FTP_HOST='10.90.0.76'
FTP_USER='pgsftpusr'
FTP_PASS='Progressa2022-'
FTP_DIR=' /var/www/html/progressa/reportes_entrada_safi'

ftp = ftplib.FTP(FTP_HOST, FTP_USER, FTP_PASS)
# force UTF-8 encoding
ftp.encoding = "utf-8"


def main(**kwargs):
    """
        This is an example of code you want to run on every iteration
        You can, and probably should move this to its own Python module

        This sample code intentionally crashes once in a while to show what
        happens when your code raises an exception
    """
    db=safi.Session(db_user='app',db_pass='Vostro1310',db_host='10.186.22.35',db_name='microfin')
    if db.is_available :
        data=db.bulk_data
        with open("saldos.txt", "w") as file:
            for row in data :
                file.write(row)   
    else:
        print('no available')

        

  



    # local file name you want to upload
    filename = "saldos.txt"
    with open(filename, "rb") as file:
        # use FTP's STOR command to upload the file
        ftp.storbinary(f"STOR {filename}", file) 

main()