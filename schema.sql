CREATE TABLE SETTINGS
(
    current_date date,
    last_update datetime,
    db_user varchar(50),
    db_pass varchar(50),
    db_host varchar(100),
    db_port int,
    db_name varchar(50),
    last_id int
    
);
INSERT INTO SETTINGS(current_date,last_update,db_user,db_pass,db_host,db_port,db_name,last_id) VALUES ('2022-06-30','2022-06-30','app','Vostro1310','10.186.22.35',3306,'microfin','0');
