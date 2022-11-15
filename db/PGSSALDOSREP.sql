delimiter ;

drop procedure if exists PGSSALDOSREP;
delimiter $$
CREATE PROCEDURE `PGSSALDOSREP`(
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

	DECLARE Var_TransaccionInicio int;
	DECLARE Var_TransaccionFin int;
	

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
            ELSE    -- Por Numero de Transacción
				BEGIN
					IF (Par_OrigenID = Entero_Cero)THEN
						SET Var_TransaccionInicio=(select coalesce(Valor,Entero_Cero) from microfin.PGSSERVICIOKEY where ServicioID=1  and KeyID=1);
						SET Var_TransaccionFin=(select Transaccion from CREDITOSMOVS order by CreditosMovsID desc limit 1 );

					END IF;
					
					INSERT INTO lista_creditos
						SELECT distinct CreditoID from CREDITOSMOVS where FechaOperacion=Var_FechaSistema and Transaccion>Var_TransaccionInicio and Transaccion>Var_TransaccionFin;
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
		CreditoID 		bigint,
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

		IFIN			decimal(12,2),
		IMOR			decimal(12,2),
        FCOMPRA			date,
        PLAZO			varchar(300),
        TASA			decimal(12,2),
        ESTATUS			int,
        NEGOCIOPGSSA    int
			
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
		CreditoID 		bigint, 
		AmortizacionID 	int, 
		FechaExigible 	date,
		Estatus 		char(1),
		SaldoCapital 	decimal,
		DiasAtraso 		int
	);
	DROP TABLE IF EXISTS saldos_credito;
	CREATE TEMPORARY TABLE  saldos_credito
	( 
		CreditoID 		bigint, 
		banda_id 		int, 
		cuotas  		int,
		SaldoCapital 	decimal,
		etiqueta 		varchar(50)
	);

DROP TABLE IF EXISTS saldo_vencido_banda;
CREATE  TEMPORARY  TABLE  saldo_vencido_banda
(
	CreditoID 		bigint,
	SaldoCapital 	decimal(11,2),
	banda_id 		int,
	etiqueta 		varchar(50)
);


DROP TABLE IF EXISTS credito_incumplimiento;
CREATE TEMPORARY  TABLE credito_incumplimiento
(
	CreditoID 			bigint, 
	FechaIncumplimiento date,
    FechaVencidoActual 	date,
	DIASVDO				int,
    PAGOSVENCIDOS		int,
    NPARCIALIDAD		int
);
DROP TABLE IF EXISTS  credito_cuotas_activas;
CREATE TEMPORARY TABLE credito_cuotas_activas
(
	CreditoID bigint, 
    CuotaActual int,
	CuotasAtraso int
);



-- Se definen las N bandas de capital vencido.
INSERT  into bandas_vencido VALUES (1,1,30,'VDO30'),(2,31,60,'VDO60'),(3,61,90,'VDO90'),(4,91,99999999,'VDOM90');


INSERT INTO generales_credito
	(CreditoID, 	ClienteID, 	IDPDTO, 	
	PLAZOMAX, 		IDPROGSSA,	TDASUCPGSA, 	
	LIMITE, 		MONTODIS, 	SDOCTA, 	
	VDO,			IFIN, 		IMOR, 		
	FCOMPRA, 		PLAZO, 		TASA,
    ESTATUS)

	SELECT  
	c.CreditoID,										c.ClienteID, 														c.ProductoCreditoID , 							
	datediff(c.FechaVencimien,c.FechaInicio ), 			coalesce(ec.ClienteIDCte,c.ClienteID),								c.SucursalID,		
	coalesce( l.Autorizado ,c.MontoCredito ), 			coalesce( l.SaldoDisponible  ,0  ), 								(c.SaldoCapVigent + c.SaldoCapAtrasad +c.SaldoCapVencido +c. SaldCapVenNoExi ),
	(c.SaldoCapVencido + c.SaldoCapAtrasad ) ,			(SaldoInterProvi+SaldoInterAtras+SaldoInterVenc+SaldoIntNoConta),	(SaldoMoratorios+SaldoMoraVencido+SaldoMoraCarVen), 
	c.FechaInicio,  									upper(DescInfinitivo),														TasaFija,
    (case when c.Estatus='P' then 2  when c.Estatus='C' then 8  else 1 end)
    
	FROM  EQU_CLIENTES  ec RIGHT JOIN  (PRODUCTOSCREDITO p  
	INNER JOIN ( CATFRECUENCIAS cf 
	INNER JOIN ((CREDITOS c 
	INNER JOIN lista_creditos lc on c.CreditoID=lc.CreditoID)
    LEFT JOIN LINEASCREDITO l  on c.LineaCreditoID=l.LineaCreditoID ) on cf.FrecuenciaID=c.FrecuenciaCap)
	on  c.ProductoCreditoID=p.ProducCreditoID) on ec.ClienteIDSAFI =c.ClienteID;


-- IDELEMENTO,IDELEMENTOPSSA,
INSERT INTO generales_cliente( ClienteID,	RFC,	CURP)
	SELECT  distinct  c.ClienteID, 			c.CURP, c.RFC 
	from CLIENTES c  inner join generales_credito gc
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

INSERT INTO credito_cuotas_activas(CreditoID,CuotaActual,CuotasAtraso)
	select a.CreditoID,max(AmortizacionID),sum(case when Estatus in ('A','B') then 1 else 0 end) 
	from AMORTICREDITO a inner join lista_creditos lc  on a.CreditoID=lc.CreditoID
	where a.FechaInicio<=Var_FechaSistema
	-- where a.FechaInicio<='2022-09-13'
	and Estatus <>'P'
	group by a.CreditoID;
    



    
drop table if exists tmp_fecha_atraso_actual;
create temporary table tmp_fecha_atraso_actual
(
CreditoID bigint,
FechaAtraso date
);

insert into tmp_fecha_atraso_actual
select a.CreditoID,min(FechaVencim) from AMORTICREDITO a inner join lista_creditos lc on a.CreditoID=lc.CreditoID
where Estatus in ('A','B')
group by CreditoID;

update tmp_fecha_atraso_actual fa inner join credito_incumplimiento fi on fa.CreditoID=fi.CreditoID
SET fi.FechaVencidoActual=FechaAtraso;

update credito_cuotas_activas ca 
inner join credito_incumplimiento ci ON ca.CreditoID=ci.CreditoID
SET ci.PAGOSVENCIDOS=CuotasAtraso,
	ci.NPARCIALIDAD=CuotaActual,
    ci.DIASVDO=datediff(Var_FechaSistema,coalesce(FechaVencidoActual,Var_FechaSistema));
		
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
CreditoID bigint,
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




IF(Par_Tipo=Reporte_Global)THEN
	BEGIN
		select '' as FOLIOUPD, 'SAFI' as SIORIREQ, 'SAFI' USRORIREQ , IDELEMENTO,'' IDELEPSSA,
        IDPDTO,ORIPDTO,PLAZOMAX,IDPROGSSA,CTAPROGSSA,SERIEPGSSA,TDASUCPGSA,
		TPOCTAPGSA,LIMITE,MONTODIS,SDOCTA,VDO,
        coalesce(VDO30,0)VDO30,coalesce(VDO60,0)VDO60,coalesce(VDO90,0)VDO90,coalesce(VDOM90,0)VDOM90,IFIN,
        IMOR,DIASVDO, PAGOMES00,PAGOMES01,PAGOMES02,
        PAGOMES03,PAGOMES04,PAGOMES05,PAGOMES06,PAGOMES07,
        PAGOMES08,PAGOMES09,PAGOMES10,PAGOMES11,PAGOMES12,
		PAGOMES13, PAGOMES14, PAGOMES15,PAGOMES16, PAGOMES17, 
        PAGOMES18,
		'' FULTPACAP,'' FULTPAINT,'' FPRIMINCUM,gc.CreditoID PRESTAMOID, now()FEHODATOS, 
        c.RFC,c.CURP ,0 as LINEACREDITO, CTAPROGSSA,8 as NEGOCIOPGSSA,
        FCOMPRA,PAGOSVENCIDOS,NPARCIALIDAD,PLAZO,TASA,
        ESTATUS

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
		left join credito_incumplimiento ci on gc.CreditoID=ci.CreditoID
        limit 60;
		
        UPDATE microfin.PGSSERVICIOKEY SET Valor=Var_TransaccionFin  where ServicioID=1  and KeyID=1;

	END;
END IF;




END TerminaStore$$