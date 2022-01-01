delimiter ; 
DROP PROCEDURE IF EXISTS PGS_ENROLLAMIENTOPRO;
delimiter $$
CREATE PROCEDURE PGS_ENROLLAMIENTOPRO
(   Par_SucursalAlta int,
    Par_PrimeroNombre varchar(50),
    Par_SegundoNombre varchar(50),
    Par_ApellidoPat varchar(50),
    Par_ApellicoMat varchar(50),
	Par_RFC varchar(20),
	Par_CURP varchar(24),
    
    Par_FechaNacimiento date,
    Par_PaisNacionalidad int,
    Par_EstadoNacimiento int,
    Par_Genero char(1),
    Par_TelefonoCelular varchar(20),
    
	Par_Email varchar(200),
    Par_EdoCivil char(4),
    Par_OcupacionID int, 
    Par_Puesto varchar(70),
    Par_CentroTrabajo varchar(200),
    
    Par_AntiguedadTrabajo int,
    Par_DireccionTrabajo varchar(200),
    Par_TelefonoTrabajo varchar(20),
	Par_ActividadBMX varchar(15),
	Par_PromotorID int,
    
    Par_DomicilioEstado int,
	Par_DomicilioMunicipio int,
    Par_DomicilioLocalidad int,
    Par_DomicilioColonia int,
    Par_DomicilioCalle varchar(200),
    Par_DomicilioNumero int,
    
    Par_DomicilioEntreCalle varchar(80),
    Par_DomicilioCP int,
    Par_DomicilioAniosResidencia int, 
    -- identificacion 
	Par_IdentifiFolio varchar(50),
    Par_IdentiFechaVenc date,
    
    Par_CCtaEsPEP char,
    Par_CCtaParientePEP char,
    Par_CCtaCobertura char,
    Par_CCtaExporta decimal(12,2),
    Par_CCtaImporta decimal(12,2),
    
    Par_CCtaIngresosMes decimal(12,2),
    Par_CCtaMontoDepositos decimal(12,2),
    Par_CCtaMontoRetiro decimal(12,2),
    Par_CCtaDepositos int,
    Par_CCtaCargos int,
    
    Par_FrecDepositos int,
    Par_FrecCargos int,
    Par_CCtaProceRecursos varchar(300),
    Par_PerfilMontoDepositos decimal(12,2),
    Par_PerfilMontoRetiros decimal(12,2),
    
    Par_PerfilNumeroDepositos decimal(12,2),
    Par_PerfilNumeroRetiros decimal(12,2)
)
TerminaStore : BEGIN

DECLARE Var_Titulo varchar(4);
DECLARE PERSONA_FISICA char;
DECLARE CADENA_VACIA char;
DECLARE PAIS_MEXICO int;
DECLARE NAC_MEXICANA char;
DECLARE SIN_RAZON_SOCIAL char;
DECLARE SIN_FAX char;
DECLARE ENTERO_CERO int;
DECLARE ENTERO_UNO int;
DECLARE CLIENTE_INDEPEND char;
DECLARE MOTIVO_CREDITO int;
DECLARE SI_PAGAIVA char;
DECLARE SI_PAGAISR char;
DECLARE SI_PAGAIDE char;
DECLARE RIESGO_BAJO char;
DECLARE SECTOR_PRIVADO int;
DECLARE Var_Act_FOMUR int;
DECLARE Var_Act_FR varchar(40);
DECLARE Var_Act_INEGI int;
DECLARE SIN_PROSPESCTO int;
DECLARE NO_MENOREDAD char;
DECLARE VALOR_NO char;
DECLARE FECHA_VACIA date;
DECLARE SIN_TEL_FIJO char;
DECLARE Var_LineaCreditoID bigint;

DECLARE Var_NumErr int;
DECLARE Var_ErrMen varchar(300);
DECLARE Var_ClienteID int;
DECLARE SIN_EJECUTIVOCAP int;
DECLARE Aud_EmpresaID int;
DECLARE Aud_Usuario int;
DECLARE Aud_FechaActual datetime;
DECLARE Aud_DireccionIP varchar(12);
DECLARE Aud_Programa varchar(200);
DECLARE Aud_Sucursal int;
DECLARE Aud_NumTransaccion bigint;
DECLARE SIN_PROSPECTO int;
DECLARE Var_Sector_Econ int;
DECLARE COMPROBANTE_DOM int;
DECLARE DESC_COMPROBANTE varchar(200);
DECLARE PATH_ARCHIVO varchar(100);
DECLARE ARCHIVO_EXT varchar(4);
DECLARE DIRECC_CASA int;
DECLARE Var_NombreColonia varchar(200);
DECLARE Var_DireccionCompleta varchar(500);
DECLARE VALOR_SI char;
DECLARE CUENTA_EJE int;
DECLARE Var_CuentaAhoID int;

SET ENTERO_CERO=0;
SET ENTERO_UNO=0;
SET SECTOR_PRIVADO=30;
SET SIN_FAX='';
SET SIN_RAZON_SOCIAL='';
SET MOTIVO_CREDITO='1';
SET CLIENTE_INDEPEND='I';
SET SI_PAGAISR='S';
SET SI_PAGAIVA='S';
SET SI_PAGAIDE='S';
SET RIESGO_BAJO='B';
SET SIN_PROSPECTO =0;
SET Var_Titulo='Sr';
SET PERSONA_FISICA='F';
SET CADENA_VACIA='';
SET PAIS_MEXICO=700;
SET NAC_MEXICANA='N';
SET NO_MENOREDAD='N';
SET VALOR_NO='N';
SET Var_ErrMen='';
SET Var_NumErr=0;
SET Var_ClienteID=0;
SET SIN_TEL_FIJO='';
SET SIN_EJECUTIVOCAP=0;

-- Datos de auditoria
SET Aud_Usuario= 1; -- Setear el numero de Usuario del Promotor.
SET Aud_FechaActual=now();
SET Aud_DireccionIP='127.0.0.1';
SET Aud_Programa='PGS_ENROLL';
SET Aud_Sucursal=5; -- Set Sucursal de Promotor
SET Aud_NumTransaccion=0;
SET Aud_EmpresaID=1;

-- SET catalogos de actividades tomando como referencia la actividad BMX
SET Var_Act_INEGI= 99999;
SET Var_Act_FR='999999999999';
SET Var_Act_FOMUR=99999999;
SET Var_Sector_Econ=0;
SET FECHA_VACIA='1900-01-01';



call CLIENTESALT(Par_SucursalAlta,      PERSONA_FISICA, 		Var_Titulo, 			Par_PrimeroNombre,		Par_SegundoNombre,
                 CADENA_VACIA,          Par_ApellidoPat,    	Par_ApellicoMat,  		Par_FechaNacimiento,  	PAIS_MEXICO,
                 Par_EstadoNacimiento,  NAC_MEXICANA, 			PAIS_MEXICO,			Par_Genero,				Par_CURP,
				 Par_RFC,				Par_EdoCivil,			Par_TelefonoCelular,	SIN_TEL_FIJO,			Par_Email,
				 SIN_RAZON_SOCIAL,		ENTERO_CERO,			CADENA_VACIA,			ENTERO_CERO,			SIN_FAX,
				 Par_OcupacionID,		Par_Puesto,				Par_CentroTrabajo,		Par_AntiguedadTrabajo,	Par_DireccionTrabajo,
				 Par_TelefonoTrabajo,	CLIENTE_INDEPEND,		MOTIVO_CREDITO,			SI_PAGAIVA,				SI_PAGAISR,
				 SI_PAGAIDE,			RIESGO_BAJO,			SECTOR_PRIVADO,			Par_ActividadBMX,		Var_Act_INEGI,
				 Var_Sector_Econ,		Var_Act_FR,				Var_Act_FOMUR,			Par_PromotorID,			Par_PromotorID,			
				 SIN_PROSPECTO,			NO_MENOREDAD,			ENTERO_CERO,			VALOR_NO,				ENTERO_CERO,
				 ENTERO_CERO,			CADENA_VACIA,			ENTERO_CERO,			CADENA_VACIA,			CADENA_VACIA,
				 CADENA_VACIA,			SIN_EJECUTIVOCAP,		SIN_EJECUTIVOCAP,		ENTERO_CERO,			FECHA_VACIA,
				 ENTERO_CERO,			CADENA_VACIA,			ENTERO_CERO,			FECHA_VACIA,			ENTERO_CERO,
				 CADENA_VACIA,			CADENA_VACIA,			ENTERO_CERO,			CADENA_VACIA,			CADENA_VACIA,
				 PAIS_MEXICO,			ENTERO_UNO,				VALOR_NO,				Var_NumErr,				Var_ErrMen,
				 Var_ClienteID,			Aud_Usuario,			Aud_FechaActual,		Aud_DireccionIP,		Aud_Programa,
				 Aud_Sucursal,			Aud_NumTransaccion);

SELECT Var_ClienteID,Var_NumErr,Var_ErrMen,Var_CuentaAhoID;


SET CUENTA_EJE =3;
SET VALOR_SI='S';
SET COMPROBANTE_DOM=8;
SET DESC_COMPROBANTE="COMPROBANTE DE DOMICILIO (APP/DIGITAL).";
SET PATH_ARCHIVO:=CONCAT('/var/Archivos/Clientes/Cliente',LPAD(Var_ClienteID,10,"0"),"/");
SET ARCHIVO_EXT='.png';
SET DIRECC_CASA=1;
SET Var_NombreColonia='NOMBRE COLONIA';
SET Var_DireccionCompleta ="Concatener la direccion completa normalizada";
SET Var_CuentaAhoID=0;

-- Registro de Comprobante de Domicilio
call CLIENTEARCHIVOSALT(Var_ClienteID,SIN_PROSPECTO,COMPROBANTE_DOM,DESC_COMPROBANTE,PATH_ARCHIVO, ARCHIVO_EXT,ENTERO_CERO,date(now()),VALOR_NO,Var_NumErr, Var_ErrMen, Aud_EmpresaID,Aud_Usuario,Aud_FechaActual,Aud_DireccionIP,Aud_Programa,Aud_Sucursal,Aud_NumTransaccion);

-- Registro de Domiclio
call DIRECCLIENTEALT(Var_ClienteID,DIRECC_CASA,Par_DomicilioEstado,Par_DomicilioMunicipio,  Par_DomicilioLocalidad,Par_DomicilioColonia,
Var_NombreColonia,Par_DomicilioCalle,Par_DomicilioNumero,CADENA_VACIA, CADENA_VACIA,Par_DomicilioEntreCalle,CADENA_VACIA,Par_DomicilioCP,
CADENA_VACIA,  CADENA_VACIA,CADENA_VACIA,VALOR_SI,VALOR_SI,Aud_EmpresaID, CADENA_VACIA,CADENA_VACIA,Var_DireccionCompleta,PAIS_MEXICO,Par_DomicilioAniosResidencia,  
VALOR_NO,Var_NumErr,Var_ErrMen,Aud_Usuario,Aud_FechaActual, Aud_DireccionIP,Aud_Programa,Aud_Sucursal,Aud_NumTransaccion);

-- Registro de Identificacion
call IDENTIFICLIENTEALT(Var_ClienteID,1,'S',Par_IdentifiFolio,'1900-01-01', Par_IdentiFechaVenc,1,'S',Var_NumErr,Var_ErrMen,  2,'2022-09-13','172.17.0.1','IdentifiClienteDAO.alta',6, 75571);

-- Registro de CUenta de Ahorro
call CUENTASAHOALT(Par_SucursalAlta,Var_ClienteID,'',1,CUENTA_EJE,date(now()),'CUENTA EJE (ENROLL)','D',0,'S',Par_TelefonoCelular,Var_CuentaAhoID,VALOR_NO,Var_NumErr,Var_ErrMen,1,2,'2022-09-13','172.17.0.1','/microfin/catalogoCuentaAhorro.htm',6,75572);

-- Registro de Conocimiento de Cta
call CONOCIMIENTOCTAALT(Var_CuentaAhoID,1000.0,1000.0,'SALARIO',null, null,null,null,null,null,'','P',null,1,1, 1,1,null,'S',@Var_NumErr,@Var_ErrMen,1,2,'2022-09-13','172.17.0.1', 'ConocimientoCtaDAO.alta',6,75580);

-- REgistro de Conocimiento Cliente
call CONOCIMIENTOCTEALT(Var_ClienteID,'','',0.0,'',  '','','N',0,'N',  '','','','','',  'L','',0.0,0.0,0.0,  0.0,'N',null,'','',  '','N',null,'','',  '','','','','',  '','','','','',  '','','','','',  '','Ing1','','','',  '',0,0,'','',  '','','','','',  '',0.0,'B','S','',  '','','','','',  '','','','','',  '','','','','',  '','1900-01-01','',0.0,0.0,'','','0','0','S',  Var_NumErr,Var_ErrMen,1,2,'2022-09-13',  '172.17.0.1','ConocimientoCteDAO.altaConocimiento',6,75577);

-- Registro de Perfil tRansaccional
call PLDPERFILTRANSACCIONALALT(Var_ClienteID,0,1000.0,10000.0,1,  1,6,4,'','',  'S',@Var_NumErr,@Var_ErrMen,1,2,  '2022-09-13','172.17.0.1','/microfin/aperturaCuentaAhorro.htm',6,75583);
-- Autorizaciòn de CUenta de Ahorro
CALL CUENTASAHOACT(Var_CuentaAhoID,2,'2022-09-13','',1,  'S',Var_NumErr,Var_ErrMen,1,2,  '2022-09-13','172.17.0.1','/microfin/aperturaCuentaAhorro.htm',6,75585);
-- Registro de Linea de Credito
CALL LINEASCREDITOALT(Var_ClienteID,Var_CuentaAhoID,1,Par_SucursalAlta,'99999','2022-09-13','2024-09-13',1008,25000.0,'N',0,null,null,0.0,null,null,0.0,VALOR_NO,@Var_NumErr,@Var_ErrMen, 1,2,'2022-09-13','172.17.0.1','/microfin/catalogoCalendarioProducto.htm',6,75588);
-- Autorizcion de Lina de Credito
SET Var_LineaCreditoID=SUBSTRING(@Var_ErrMen, POSITION(':' IN @Var_ErrMen)+1,LENGTH(@Var_ErrMen));

SELECT Var_ClienteID,Var_NumErr,Var_ErrMen,Var_CuentaAhoID,Var_LineaCreditoID;


END$$
















