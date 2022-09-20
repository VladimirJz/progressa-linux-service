delimiter ;
drop procedure if exists PGS_MAESTROSALDOS;
DELIMITER $$
CREATE DEFINER=`root`@`%` PROCEDURE `PGS_MAESTROSALDOS`(
Par_Tipo CHAR,
Par_Instrumento CHAR,
Par_OrigenID BIGINT,
Par_Consolidado CHAR

    
)
TerminaStore: BEGIN
	DECLARE Var_Row int;
    DECLARE Reporte_Global char;
    DECLARE Reporte_Parcial char;
    DECLARE Entero_Cero int;
    DECLARE Valor_No char;

    DECLARE Instrumento_Cliente char;
    DECLARE Instrumento_Credito char;
    DECLARE Instrumento_Transaccion char;
	

	--  SQL
	DECLARE SQL_QUERY varchar(16000);
	DECLARE CREATE_TABLE varchar(500);
	DECLARE SELECT_FIELDS  varchar(500);
	DECLARE CASE_FIELDS varchar(16000);
	DECLARE FROM_TABLES varchar(100);
	DECLARE Var_FechaSistema date;
    
	SET Instrumento_Cliente='C';
    SET Instrumento_Credito ='R';
    SET Instrumento_Transaccion='T';
    
    SET Entero_Cero=0;
    SET Valor_No='N';
    SET Reporte_Global='G';
    
	-- BEGIN

	SET Par_Consolidado=coalesce(Par_Consolidado,Valor_No);
	SET Var_FechaSistema=(SELECT FechaSistema from PARAMETROSSIS);
	
	-- Table
    DROP TABLE IF EXISTS lista_creditos;
    CREATE TEMPORARY TABLE lista_creditos
    (
		CreditoID bigint
    );
    
    IF(Par_Tipo=Reporte_Global)THEN
		BEGIN
			INSERT INTO lista_creditos
			SELECT CreditoID FROM CREDITOS where Estatus NOT IN ('P','K','C');
			
		END;
	ELSE 
		BEGIN
			CASE Par_Instrumento
            WHEN Instrumento_Cliente THEN 
				BEGIN 
					INSERT INTO lista_creditos
						SELECT CreditoID FROM CREDITOS where Estatus NOT IN ('P','K','C') and ClienteID=Par_OrigenID;
                END;
            WHEN Instrumento_Credito THEN 
				BEGIN 
					INSERT INTO lista_creditos
						SELECT CreditoID FROM CREDITOS where Estatus NOT IN ('P','K','C') and CreditoID=Par_OrigenID;
                END;
            ELSE   
				BEGIN
					INSERT INTO lista_creditos
						SELECT distinct CreditoID from CREDITOSMOVS where /*FechaOperacion=Var_FechaSistema and */ NumTransaccion>=Par_OrigenID;
                END;
            END CASE;
        END;
    END IF;
    
	-- Temporaly objects 
    DROP TABLE IF EXISTS generales_cliente;
    CREATE TEMPORARY TABLE generales_cliente
    (
		ClienteID 		int,
		IDELEMENTO 		varchar(30),
		IDELEMENTOPSSA 	varchar(30),
		RFC 			varchar(20),
		CURP 			varchar(20)
    );

	DROP TABLE IF EXISTS generales_credito;
	CREATE  TEMPORARY TABLE generales_credito
	(	
		CreditoID 		int,
		ClienteID 		int,
		IDPDTO	 		int,
		ORIPDTO 		varchar(50),
		PLAZOMAX 		int,
		IDPROGSSA 		int,
		CTAPROGSSA 		int(50),
		SERIEPGSSA 		varchar(50),
		TDASUCPGSA 		int,
		TPOCTAPGSA 		int,
		LIMITE 			decimal(12,2),
		MONTODIS 		decimal(12,2),
		SDOCTA			decimal(12,2),
		VDO				decimal(12,2),
		DIASVDO			int,
		IFIN			decimal(12,2),
		IMOR			decimal(12,2)
			
	);

	DROP TABLE IF EXISTS  bandas_vencido;
	CREATE  TEMPORARY  TABLE  bandas_vencido
	(
		banda_id 		int,
		limite_inferior int,
		limite_superior int,
		cabecera 		varchar(50)
	);
	DROP TABLE IF EXISTS saldos_amortizacion;
	CREATE TEMPORARY TABLE  saldos_amortizacion
	( 
		CreditoID 		int, 
		AmortizacionID 	int, 
		FechaExigible 	date,
		Estatus 		char(1),
		SaldoCapital 	decimal,
		DiasAtraso 		int
	);
	DROP TABLE IF EXISTS saldos_credito;
	CREATE TEMPORARY TABLE  saldos_credito
	( 
		CreditoID 		int, 
		banda_id 		int, 
		cuotas  		int,
		SaldoCapital 	decimal,
		etiqueta 		varchar(50)
	);

DROP TABLE IF EXISTS saldo_vencido_banda;
CREATE  TEMPORARY  TABLE  saldo_vencido_banda
(
	CreditoID 		int,
	SaldoCapital 	decimal(11,2),
	banda_id 		int,
	etiqueta 		varchar(50)
);


DROP TABLE IF EXISTS credito_incumplimiento;
CREATE TEMPORARY  TABLE credito_incumplimiento
(
	CreditoID 			int, 
	FechaIncumplimiento date,
    FechaVencidoActual 	date
);


-- Se definen las N bandas de capital vencido.
INSERT  into bandas_vencido VALUES (1,1,30,'VDO30'),(2,31,60,'VDO60'),(3,61,90,'VDO90'),(4,91,99999999,'VDOM90');

-- agregar STATUS!='P'
INSERT INTO generales_credito
	SELECT  
	c.CreditoID ,c.ClienteID,
	c.ProductoCreditoID as IDPDTO,' ' as ORIPDTO, (c.FechaVencimien  - c.FechaInicio ) as PLAZOMAX, 
	coalesce(ec.ClienteIDCte,c.ClienteID)as IDPROGSSA , 0 as CTAPROGSSA,	'' as SERIEPGSSA,
	c.SucursalID as TDASUCPGSA,0 as TPOCTAPGSA,coalesce( l.Autorizado ,c.MontoCredito  )as LIMITE ,
	coalesce( l.SaldoDisponible  ,0  )as MONTODIS,
	 (c.SaldoCapVigent + c.SaldoCapAtrasad +c.SaldoCapVencido +c. SaldCapVenNoExi ) as SDOCTA ,
	(c.SaldoCapVencido + c.SaldoCapAtrasad ) VDO,
    null as DIASVDO,
    (SaldoInterProvi+SaldoInterAtras+SaldoInterVenc+SaldoIntNoConta) as IFIN,
    (SaldoMoratorios+SaldoMoraVencido+SaldoMoraCarVen) as IMOR
	FROM  EQU_CLIENTES  ec RIGHT JOIN  (PRODUCTOSCREDITO p  INNER JOIN 
	(
    (CREDITOS c INNER JOIN lista_creditos lc on c.CreditoID=lc.CreditoID)
    LEFT JOIN LINEASCREDITO l  on c.LineaCreditoID=l.LineaCreditoID )
	on  c.ProductoCreditoID=p.ProducCreditoID) on ec.ClienteIDSAFI =c.ClienteID;



INSERT INTO generales_cliente( ClienteID,IDELEMENTO,IDELEMENTOPSSA,RFC,CURP)
	SELECT  distinct  c.ClienteID,'','', c.CURP, c.RFC from CLIENTES c  inner join generales_credito gc
	on gc.ClienteID=c.ClienteID
    ;
    


INSERT INTO credito_incumplimiento(CreditoID,FechaIncumplimiento)
	select CreditoIDSAFI,FechaIncumplimiento  
	from EQU_CREDITOS ec inner join lista_creditos lc on ec.CreditoIDSAFI=lc.CreditoID
	WHERE  COALESCE (FechaIncumplimiento,'1900-00-00')>'1900-00-00';




    
    
INSERT INTO credito_incumplimiento(CreditoID,FechaIncumplimiento)
select   s.CreditoID,min(FechaCorte)FechaInumplimiento
	from (SALDOSCREDITOS s inner join lista_creditos lc on s.CreditoID=lc.CreditoID)  left outer join EQU_CREDITOS eq  on s.CreditoID =eq.CreditoIDSAFI 
	where  coalesce(CreditoIDSAFI,0)=0 and salCapAtrasado>0
	group by CreditoID ;


drop table if exists tmp_fecha_atraso_actual;
create temporary table tmp_fecha_atraso_actual
(
CreditoID int,
FechaAtraso date
);

insert into tmp_fecha_atraso_actual
select a.CreditoID,min(FechaVencim) from AMORTICREDITO a inner join lista_creditos lc on a.CreditoID=lc.CreditoID
where Estatus in ('A','B')
group by CreditoID;

update tmp_fecha_atraso_actual fa inner join credito_incumplimiento fi on fa.CreditoID=fi.CreditoID
SET fi.FechaVencidoActual=FechaAtraso;

		
INSERT INTO saldos_amortizacion 	
	SELECT   a.CreditoID,AmortizacionID ,FechaExigible ,Estatus, (SaldoCapVigente +SaldoCapAtrasa +SaldoCapVencido  + SaldoCapVenNExi ) as SaldoCapital,			
	DATEDIFF( Var_FechaSistema,FechaExigible )DiasAtraso  
	FROM  AMORTICREDITO a  inner join lista_creditos lc on a.CreditoID=lc.CreditoID WHERE  
    DATEDIFF( Var_FechaSistema,FechaExigible  )>0;


INSERT INTO saldos_credito 
	select CreditoID,banda_id,count(*)Cuotas,sum(SaldoCapital)SaldoCapital,max(cabecera)Etiqueta 
	from saldos_amortizacion  sa , bandas_vencido  bv 
	where  DiasAtraso BETWEEN  limite_inferior and limite_superior
	group  by CreditoID,banda_id
	order by CreditoID;

	
drop table if exists saldos_credito2;
create temporary table saldos_credito2 select * from saldos_credito;


insert into saldo_vencido_banda 
	select  coalesce( sc.CreditoID,bv.CreditoID)CreditoID ,coalesce(SaldoCapital,0)SaldoCapital,bv.banda_id,bv.cabecera as etiqueta  
				from saldos_credito sc right  join 
					(
					select  distinct CreditoID,b.banda_id  ,b.cabecera 
					from saldos_credito2  s
					inner join bandas_vencido b  ) bv 
				on sc.banda_id=bv.banda_id  and sc.CreditoID=bv.CreditoID
				order by sc.CreditoID,bv.banda_id;





DROP TABLE IF EXISTS saldo_dias_vencido;

-- SET CREATE_TABLE ="CREATE  TEMPORARY TABLE  saldo_dias_vencido"	;				
-- SET SELECT_FIELDS=" SELECT CreditoID, ";
-- SET  FROM_TABLES =" FROM saldo_vencido_banda;";
-- SET CASE_FIELDS=( SELECT  
-- 							GROUP_CONCAT( 
-- 							concat(" (CASE WHEN banda_id=",banda_id," THEN SaldoCapital ELSE 0 END) AS  " ,cabecera) )
-- 							from bandas_vencido);

						
SET CREATE_TABLE ="CREATE  TEMPORARY TABLE  saldo_dias_vencido"	;				
SET SELECT_FIELDS=" SELECT CreditoID, ";
SET  FROM_TABLES =" FROM saldo_vencido_banda group by CreditoID;";
SET CASE_FIELDS=( SELECT  
							GROUP_CONCAT( 
							concat(" SUM(CASE WHEN banda_id=",banda_id," THEN SaldoCapital ELSE 0 END) AS  " ,cabecera) )
							from bandas_vencido);
				
SET @SQL_QUERY = CONCAT(CREATE_TABLE, SELECT_FIELDS	,CASE_FIELDS, FROM_TABLES);
PREPARE QUERY FROM @SQL_QUERY;
EXECUTE QUERY;
DEALLOCATE PREPARE QUERY;




				
-- select CreditoID,  from generales_credito gc inner join saldo_dias_vencido sv on gc.CreditoID=sv.CreditoID 					left join credito_incumplimiento ci on gc.CreditoID=ci.CreditoID;








drop table if exists banda_pago_mensual;
create TABLE  banda_pago_mensual
(
banda_id INT,
fecha_inicio DATE,
fecha_termina DATE,
cabecera varchar(50)

);


	INSERT INTO  banda_pago_mensual (banda_id)
		SELECT  @row := @row + 1 AS id
		FROM    CLIENTES  p   -- token
		JOIN    (SELECT @row := -1) r
		WHERE   @row<18;
        
	
update banda_pago_mensual set cabecera = CONCAT('PAGOMES', LPAD(cast(banda_id as char ),2,'00'));
	
UPDATE banda_pago_mensual 
set fecha_termina=LAST_DAY(date_add(Var_FechaSistema, INTERVAL banda_id MONTH) );

UPDATE banda_pago_mensual 
set fecha_inicio=DATE_SUB(fecha_termina, INTERVAL  DAYOFMONTH(fecha_termina) -1 DAY );



DROP TABLE IF EXISTS  pago_mes_banda;
CREATE TABLE pago_mes_banda
(
banda_id int,
CreditoID int,
cabecera varchar(50),
Capital decimal(12,2),
Interes decimal(12,2),
Accesorios decimal(12,2)
);

INSERT INTO pago_mes_banda
	
	select max(banda_id)mes_id ,a.CreditoID, max(cabecera)cabecera, sum(CASE WHEN  FechaInicio < @FechaSistema THEN  SaldoCapVigente+SaldoCapAtrasa+SaldoCapVencido+SaldoCapVenNExi ELSE  Capital END  ) as Capital,
	sum(CASE WHEN  FechaInicio < @FechaSistema THEN  SaldoInteresPro + SaldoInteresAtr + SaldoInteresVen ELSE  Interes END)as Interes,0 as Accesorios
	from banda_pago_mensual 
	inner join ( AMORTICREDITO a  inner join lista_creditos lc on a.CreditoID=lc.CreditoID)   where  a.FechaVencim between fecha_inicio and fecha_termina
	and Estatus!='P' 
	GROUP  by a.CreditoID,banda_id
	order by a.CreditoID, banda_id;

DROP TABLE IF EXISTS saldo_pago_mes;


SET CREATE_TABLE ="CREATE  TEMPORARY TABLE  saldo_pago_mes"	;				
SET SELECT_FIELDS=" SELECT CreditoID, ";
SET  FROM_TABLES =" FROM pago_mes_banda  group by CreditoID;";
                            
SET CASE_FIELDS=( SELECT  
							GROUP_CONCAT( 
							concat(" SUM(CASE WHEN banda_id=",banda_id," THEN Capital ELSE 0 END) AS  " ,cabecera) )
							from banda_pago_mensual);
-- select 		CASE_FIELDS;		
SET @SQL_QUERY= CONCAT(CREATE_TABLE, SELECT_FIELDS	,CASE_FIELDS, FROM_TABLES);


PREPARE QUERY  FROM  @SQL_QUERY;
EXECUTE QUERY;
DEALLOCATE PREPARE QUERY;



-- select * from   saldo_pago_mes spm  right join  generales_credito gc  on spm.CreditoID=gc.CreditoID  inner join saldo_dias_vencido sv on gc.CreditoID=sv.CreditoID 	 left join credito_incumplimiento ci on gc.CreditoID=ci.CreditoID;
/*
select '' as FOLIOUPD, 'SAFI' as SIORIREQ, 'SAFI' USRORIREQ , now() as FEHODATOS,'' IDELEMENTO,'' IDELEPSSA, '' NIVELACU,''SEGMENTO,
ORIPDTO,IDPDTO,'' NEGOCIO,'' CUENTA,'' SERIE,'' TDACTBDS,''TIPOCTABDS , ''GPOTASA,PLAZOMAX,IDPROGSSA,CTAPROGSSA,SERIEPGSSA,TDASUCPGSA,
TPOCTAPGSA,'' STCUENTA,LIMITE,'' PORLIMDISP,0 CAPPAGO,0 CAPPADIS,0 CAPPAPF,0 CAPPAPFUS,MONTODIS,SDOCTA,
VDO,VDO30,VDO60,VDO90,VDOM90,0 IFIN,0 IMOR,0 as DIASVDO, PAGOMES00,PAGOMES01,PAGOMES02,PAGOMES03,PAGOMES04,PAGOMES05,PAGOMES06,
PAGOMES07,PAGOMES08,PAGOMES09,PAGOMES10,PAGOMES11,PAGOMES12,0 NRTX,'' IDPERIODO,0 VALFIN1,0 VALFIN2,0 VALFIN3,0 VALFIN4,0 VALFIN5,
0 VALREF1, 0 VALREF2,0 VALREF3, 0 VALREF4, 0 VALREF5,''MATCHIDELE, c.RFC,c.CURP 
from 
saldo_pago_mes spm  right join  (generales_credito gc inner join generales_cliente c on gc.ClienteID=c.ClienteID)  on spm.CreditoID=gc.CreditoID  inner join saldo_dias_vencido sv on gc.CreditoID=sv.CreditoID 	 
left join credito_incumplimiento ci on gc.CreditoID=ci.CreditoID;

*/

IF(Par_Tipo=Reporte_Global)THEN
	BEGIN
		select '' as FOLIOUPD, 'SAFI' as SIORIREQ, 'SAFI' USRORIREQ , IDELEMENTO,'' IDELEPSSA,IDPDTO,
		ORIPDTO,PLAZOMAX,IDPROGSSA,CTAPROGSSA,SERIEPGSSA,TDASUCPGSA,
		TPOCTAPGSA,LIMITE,0 MONTOPDIS,SDOCTA,
		coalesce(VDO,0)VDO,coalesce(VDO30,0)VDO30,coalesce(VDO60,0)VDO60,coalesce(VDO90,0)VDO90,coalesce(VDOM90,0)VDOM90,IFIN,IMOR,datediff(Var_FechaSistema,coalesce(FechaVencidoActual,Var_FechaSistema)) as DIASVDO, PAGOMES00,PAGOMES01,PAGOMES02,PAGOMES03,PAGOMES04,PAGOMES05,PAGOMES06,
		PAGOMES07,PAGOMES08,PAGOMES09,PAGOMES10,PAGOMES11,PAGOMES12,
		PAGOMES13, PAGOMES14, PAGOMES15,PAGOMES16, PAGOMES17, PAGOMES18,
		'' FULTPACAP,'' FULTPAINT,'' FPRIMINCUM,gc.CreditoID PRESTAMOID, now()FEHODATOS, c.RFC,c.CURP ,
		0 as LINEACREDITO

		from 
		saldo_pago_mes spm  right join  (generales_credito gc inner join generales_cliente c on gc.ClienteID=c.ClienteID )  on spm.CreditoID=gc.CreditoID  
		left join saldo_dias_vencido sv on gc.CreditoID=sv.CreditoID 	 
		left join credito_incumplimiento ci on gc.CreditoID=ci.CreditoID;
		
	END;
ELSE
	BEGIN
		select '' as FolioActualizacion, 'SAFI' as SistemaOriginaActividad, 'SAFI' UsuarioOriginaActividad , ''  FechaHoraCreaRegistro,  0 NumeroPersonaElemento,
		0  NumeroPersonaElementoProgressa,'' NivenAcumulado , ''Segmento , ORIPDTO OrigenProducto, '' IdProducto,
		0 Negocio, CTAPROGSSA Cuenta, SERIEPGSSA Serie, TDASUCPGSA NumeroTienda, '' TipoCuenta,
		'' GrupoTasa , PLAZOMAX PlazoMaximo, IDPROGSSA IdentificadorProgressa, '' CuentraProgressa,'' SerieCuentaProgressa,
		0 NumeroSucursalProgressa, TPOCTAPGSA TipoCuentaProgressa, '' EstatusCuenta, LIMITE LimiteCredito, '0.00' PorcentajeLimiteDisponible,
		'' CapacidadPago, '' CapacidadDisponible, '' CapacidadPagoProductoFinanciero,'' CapacidadPagoPFUsado, '' MotoParaDisponer,
		SDOCTA SaldoCuenta, coalesce(VDO,0) VencidoCapital, coalesce(VDO30,0) VencidoCapital30Dias,  coalesce(VDO60,0) VencidoCapital60Dias, coalesce(VDO90,0) VencidoCapital90Dias,  
		coalesce(VDOM90,0) VencidoCapitalMas90Dias, IFIN SaldoInteresFinanciero, IMOR InteresMoratorio, datediff(Var_FechaSistema,coalesce(FechaVencidoActual,Var_FechaSistema))DiasVencido, PAGOMES00 PagoMes00,
		PAGOMES01 PagoMes01 ,PAGOMES02 PagoMes02,PAGOMES03 PagoMes03,PAGOMES04 PagoMes04,PAGOMES05 PagoMes05,
		PAGOMES06 PagoMes06,PAGOMES07 PagoMes07,PAGOMES08 PagoMes08,PAGOMES09 PagoMes09,PAGOMES10 PagoMes10,
		PAGOMES11 PagoMes11,PAGOMES12 PagoMes12, PAGOMES13 PagoMes13, PAGOMES14 PagoMes14, PAGOMES15 PagoMes15,
		PAGOMES16 PagoMes16, PAGOMES17 PagoMes17, PAGOMES18 PagoMes18, '' NumeroTransaccion, '' IdParcialidad,
		'' FechaUltimoPagoCapital,'' FechaUltimoPagoInteres,'' FechaPrimerIncumplimiento, gc.CreditoID PrestamoId, '' FolioArchivoMaestro,
		now()FechaHoraGeneraDatos, c.RFC Rfc,c.CURP  Curp

		from 
		saldo_pago_mes spm  right join  (generales_credito gc inner join generales_cliente c on gc.ClienteID=c.ClienteID )  on spm.CreditoID=gc.CreditoID  
		left join saldo_dias_vencido sv on gc.CreditoID=sv.CreditoID 	 
		left join credito_incumplimiento ci on gc.CreditoID=ci.CreditoID;
		
	END;
END IF;




END TerminaStore$$
DELIMITER ;
