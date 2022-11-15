delimiter ;
drop procedure if exists PGSVENCIMIENTOSREP;
delimiter $$

CREATE PROCEDURE `PGSVENCIMIENTOSREP`(
	
	
	Par_FechaInicio			DATE,			
	Par_FechaFin			DATE,			
	Par_Sucursal			INT(11),		
	Par_Moneda				INT(11),		
	Par_ProductoCre			INT(11),		

	Par_Promotor			INT(11),		
	Par_Genero				CHAR(1),		
	Par_Estado				INT(11),		
	Par_Municipio			INT(11),		
	Par_AtrasoInicial		INT(11),		
	Par_AtrasoFinal			INT(11),		
	Par_InstNominaID     	INT(11),                
	Par_ConvenioID          BIGINT UNSIGNED,        

	Par_EmpresaID			INT(11),		
	Aud_Usuario				INT(11),		
	Aud_FechaActual			DATETIME,		
	Aud_DireccionIP			VARCHAR(15),	
	Aud_ProgramaID			VARCHAR(50),	
	Aud_Sucursal			INT(11),		
	Aud_NumTransaccion		BIGINT(20)		
)
TerminaStore: BEGIN


DECLARE	pagoExigible	DECIMAL(12,2);
DECLARE	TotalCartera	DECIMAL(12,2);
DECLARE	TotalCapVigent	DECIMAL(12,2);
DECLARE	TotalCapVencido	DECIMAL(12,2);
DECLARE	nombreUsuario	VARCHAR(50);
DECLARE Var_Sentencia 			VARCHAR(6000);	
DECLARE Var_RestringeReporte	CHAR(1);		
DECLARE Var_UsuDependencia		VARCHAR(1000);	


DECLARE	Cadena_Vacia	CHAR(1);		
DECLARE	Fecha_Vacia		DATE;			
DECLARE	Entero_Cero		INT(11);		
DECLARE	Lis_SaldosRep	INT;
DECLARE	Con_Foranea		INT;
DECLARE	Con_PagareTfija	INT;
DECLARE	Con_Saldos		INT;
DECLARE Con_PagareImp 	INT;
DECLARE	Con_PagoCred	INT;
DECLARE	EstatusVigente	CHAR(1);		
DECLARE	EstatusAtras	CHAR(1);
DECLARE	EstatusPagado	CHAR(1);		
DECLARE	EstatusVencido	CHAR(1);		
DECLARE EstatusSuspendido CHAR(1);		

DECLARE	CienPorciento	DECIMAL(10,2);
DECLARE	FechaSist		DATE;			
DECLARE Var_PerFisica 	CHAR(1);		
DECLARE SiCobraIVA		CHAR(1);		
DECLARE Var_CliEsp		INT(11);		
DECLARE Var_CliTR		INT(11);		
DECLARE Var_CliAyE		INT(11);		
DECLARE EsProductoNomina	CHAR(1);
DECLARE Decimal_Cero	DECIMAL(12,2);	
DECLARE Hora_Vacia		TIME;			


SET	Cadena_Vacia	:= '';
SET	Fecha_Vacia		:= '1900-01-01';
SET	Entero_Cero		:= 0;
SET	Lis_SaldosRep	:= 4;
SET	EstatusVigente	:= 'V';
SET	EstatusAtras	:= 'A';
SET	EstatusPagado	:= 'P';
SET	CienPorciento	:= 100.00;
SET	EstatusVencido	:= 'B';
SET Var_PerFisica := 'F';
SET	SiCobraIVA 		:= 'S';
SET Var_CliEsp		:= (SELECT ValorParametro FROM PARAMGENERALES WHERE LlaveParametro='CliProcEspecifico');
SET Var_CliTR 		:= 26;
SET Var_CliAyE		:= 9; 
SET Hora_Vacia		:= '00:00:00';
SET EstatusSuspendido := 'S';		

SET EsProductoNomina	:= IFNULL(EsProductoNomina,'N');
SET Par_InstNominaID	:= IFNULL(Par_InstNominaID,0);
SET Par_ConvenioID		:= IFNULL(Par_ConvenioID,0);

CALL TRANSACCIONESPRO (Aud_NumTransaccion);

SELECT	FechaSistema, RestringeReporte
	 INTO FechaSist, Var_RestringeReporte
FROM PARAMETROSSIS LIMIT 1;

SET Var_RestringeReporte:= IFNULL(Var_RestringeReporte,'N');

SET Var_Sentencia :=  '
		INSERT INTO TMPVENCIMCREREP (
			Transaccion,
			GrupoID,
			NombreGrupo,
			CreditoID,
			CicloGrupo,
			ClienteID,
			NombreCompleto,
			MontoCredito,
			FechaInicio,
			FechaVencimien,
			FechaVencim,
			EstatusCredito,
			Capital,
			Interes,
			Moratorios,
			Comisiones,
			Cargos,
			AmortizacionID,
			IVATotal,
			CobraIVAMora,
			CobraIVAInteres,
			SucursalID,
			NombreSucurs,
			ProductoCreditoID,
			Descripcion,
			PromotorActual,
			NombrePromotor,
			TotalCuota,
			Pago,
			FechaPago,
			DiasAtraso,
			SaldoTotal,
			InstitNominaID,
			ConvenioNominaID,
			FechaEmision,
			HoraEmision)
	';
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' SELECT  "',Aud_NumTransaccion,'",IFNULL(Gpo.GrupoID,0), IFNULL(Gpo.NombreGrupo,""),Cre.CreditoID,IFNULL(Cre.CicloGrupo, 0),Cre.ClienteID,Cli.NombreCompleto,Cre.MontoCredito,Cre.FechaInicio,');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' Cre.FechaVencimien, Amc.FechaVencim,');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' CASE 	WHEN Cre.Estatus="I" THEN "INACTIVO" ');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, '			WHEN Cre.Estatus="A" THEN "AUTORIZADO" ');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' 		WHEN Cre.Estatus="V" THEN "VIGENTE"  ');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' 		WHEN Cre.Estatus="P" THEN "PAGADO" ');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' 		WHEN Cre.Estatus="C" THEN "CANCELADO" ');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' 		WHEN Cre.Estatus="B" THEN "VENCIDO" ');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' 		WHEN Cre.Estatus="K" THEN "CASTIGADO" ');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' 		WHEN Cre.Estatus="S" THEN "SUSPENDIDO" ');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' 		END AS EstatusCredito,');

		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' (Amc.SaldoCapVigente + Amc.SaldoCapAtrasa + Amc.SaldoCapVencido + Amc.SaldoCapVenNExi) AS Capital,');
        SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' (ROUND(Amc.SaldoInteresOrd,2) + ROUND(Amc.SaldoInteresAtr,2)  + ROUND(Amc.SaldoInteresVen,2) ');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' + ROUND(Amc.SaldoInteresPro,2)  + ROUND(Amc.SaldoIntNoConta,2) ) AS Interes,');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' (Amc.SaldoMoratorios + Amc.SaldoMoraVencido + Amc.SaldoMoraCarVen)  AS Moratorios,');
        SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' (Amc.SaldoComFaltaPa + Amc.SaldoComServGar + Amc.SaldoOtrasComis) AS Comisiones,');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' 0.00 AS  Cargos,Amc.AmortizacionID,');

		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' ROUND( (');


		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' CASE WHEN  Cli.PagaIVA="',SiCobraIVA,'"   OR Cli.PagaIVA IS NULL THEN');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' ROUND( (Amc.SaldoComFaltaPa + Amc.SaldoComServGar + Amc.SaldoOtrasComis)');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' * (SELECT IVA FROM SUCURSALES  WHERE  SucursalID = Cre.SucursalID),2)');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' ELSE 0.00');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' END'); 

		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' +');

		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' 0.00'); 

		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' +');

		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' CASE WHEN   Pro.CobraIVAInteres="',SiCobraIVA,'"   OR Pro.CobraIVAInteres IS NULL  THEN');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' (ROUND(Amc.SaldoInteresOrd,2) + ROUND(Amc.SaldoInteresAtr,2)  + ROUND(Amc.SaldoInteresVen,2)');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' + ROUND(Amc.SaldoInteresPro,2)  + ROUND(Amc.SaldoIntNoConta,2) ) ');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' * (SELECT IVA FROM SUCURSALES  WHERE  SucursalID = Cre.SucursalID)');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' ELSE 0.00');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' END'); 

		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' +');

		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' CASE WHEN   Pro.CobraIVAMora="',SiCobraIVA,'"  OR Pro.CobraIVAMora IS NULL THEN');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' ROUND((Amc.SaldoMoratorios + Amc.SaldoMoraVencido + Amc.SaldoMoraCarVen) * (SELECT IVA FROM SUCURSALES  WHERE  SucursalID = Cre.SucursalID),2)');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' ELSE 0.00');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' END'); 

		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' ) , 2 ) AS IVATotal,Pro.CobraIVAMora,Pro.CobraIVAInteres,');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' Cre.SucursalID, Suc.NombreSucurs,Cre.ProductoCreditoID, Pro.Descripcion, Cli.PromotorActual,PROM.NombrePromotor,');



		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' (Amc.SaldoCapVigente + Amc.SaldoCapAtrasa + Amc.SaldoCapVencido + Amc.SaldoCapVenNExi +');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' ROUND(Amc.SaldoInteresOrd,2) + ROUND(Amc.SaldoInteresAtr,2)  + ROUND(Amc.SaldoInteresVen,2)  ');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' + ROUND(Amc.SaldoInteresPro,2)  + ROUND(Amc.SaldoIntNoConta,2) +');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' (Amc.SaldoMoratorios + Amc.SaldoMoraVencido + Amc.SaldoMoraCarVen)+ Amc.SaldoComFaltaPa +  Amc.SaldoComServGar + Amc.SaldoOtrasComis + 0.00 +  ');

		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' ROUND( (');


		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' CASE WHEN  Cli.PagaIVA="',SiCobraIVA,'"   OR Cli.PagaIVA IS NULL THEN');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' ROUND( (Amc.SaldoComFaltaPa +  Amc.SaldoComServGar + Amc.SaldoOtrasComis)');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' * (SELECT IVA FROM SUCURSALES  WHERE  SucursalID = Cre.SucursalID),2)');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' ELSE 0.00');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' END'); 

		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' +');

		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' 0.00'); 

		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' +');

		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' CASE WHEN   Pro.CobraIVAInteres="',SiCobraIVA,'"   OR Pro.CobraIVAInteres IS NULL  THEN');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' (ROUND(Amc.SaldoInteresOrd,2) + ROUND(Amc.SaldoInteresAtr,2)  + ROUND(Amc.SaldoInteresVen,2)');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' + ROUND(Amc.SaldoInteresPro,2)  + ROUND(Amc.SaldoIntNoConta,2) ) ');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' * (SELECT IVA FROM SUCURSALES  WHERE  SucursalID = Cre.SucursalID)');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' ELSE 0.00');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' END'); 

		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' +');

		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' CASE WHEN   Pro.CobraIVAMora="',SiCobraIVA,'"  OR Pro.CobraIVAMora IS NULL THEN');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' ROUND((Amc.SaldoMoratorios + Amc.SaldoMoraVencido + Amc.SaldoMoraCarVen)  * (SELECT IVA FROM SUCURSALES  WHERE  SucursalID = Cre.SucursalID),2)');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' ELSE 0.00');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' END'); 

		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' ) , 2 )  ) AS TotalCuota,');


		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' (SELECT SUM(DET.MontoTotPago) FROM DETALLEPAGCRE DET WHERE');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' DET.AmortizacionID=Amc.AmortizacionID AND Amc.CreditoID=DET.CreditoID');
        SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' GROUP BY DET.AmortizacionID,DET.CreditoID) AS Pago, ');



		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' (SELECT MAX(FechaPago) FROM DETALLEPAGCRE DET WHERE');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' DET.AmortizacionID=Amc.AmortizacionID AND Amc.CreditoID=DET.CreditoID');
        SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' GROUP BY DET.AmortizacionID,DET.CreditoID) AS FechaPago ,');


		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' (SELECT  DATEDIFF( Par.FechaSistema, IFNULL(MIN(Amo.FechaExigible), Par.FechaSistema)) FROM AMORTICREDITO Amo WHERE Amo.CreditoID = Amc.CreditoID  ');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, '   AND Amo.Estatus IN ("V", "A", "B") ) AS DiasAtraso, ');

		SET Var_Sentencia :=  CONCAT(Var_Sentencia, ' (Cre.SaldoCapVigent + Cre.SaldCapVenNoExi + ');
		SET Var_Sentencia :=  CONCAT(Var_Sentencia, '  ROUND(Cre.SaldoInterProvi,2) + ROUND(Cre.SaldoInterOrdin,2)+ ROUND(Cre.SaldoIntNoConta,2) + ');
		SET Var_Sentencia :=  CONCAT(Var_Sentencia, ' Cre.SaldoCapAtrasad + Cre.SaldoCapVencido  + Cre.SaldCapVenNoExi +');
		SET Var_Sentencia :=  CONCAT(Var_Sentencia, ' ROUND(Cre.SaldoInterAtras,2)+ Cre.SaldoCapVencido + (Cre.SaldoMoratorios + Cre.SaldoMoraVencido + Cre.SaldoMoraCarVen) +');
		SET Var_Sentencia :=  CONCAT(Var_Sentencia, ' Cre.SaldComFaltPago + 0.0)');
		SET Var_Sentencia :=  CONCAT(Var_Sentencia, '  AS SaldoTotal,');
		SET Var_Sentencia :=	CONCAT(Var_Sentencia,' IF(INST.InstitNominaID IS NULL,0,INST.InstitNominaID) AS InstitNominaID, IFNULL(Nomc.ConvenioNominaID,0) AS ConvenioNominaID,');
		SET Var_Sentencia :=	CONCAT(Var_Sentencia, ' Par.FechaSistema AS FechaEmision, TIME(NOW()) AS HoraEmision');

		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' FROM CREDITOS Cre  ');

		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' INNER JOIN  PARAMETROSSIS Par ON Par.EmpresaID=Par.EmpresaID ');
		SET Var_Sentencia :=	CONCAT(Var_Sentencia,' LEFT OUTER JOIN NOMCONDICIONCRED Nomc ON Cre.ProductoCreditoID= Nomc.ProducCreditoID AND Cre.ConvenioNominaID=Nomc.ConvenioNominaID
														 LEFT JOIN INSTITNOMINA AS INST ON Nomc.InstitNominaID = INST.InstitNominaID');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' INNER JOIN AMORTICREDITO Amc ');
		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' ON Amc.CreditoID = Cre.CreditoID');



		SET Var_Sentencia := 	CONCAT(Var_Sentencia,' INNER JOIN PRODUCTOSCREDITO Pro ON Cre.ProductoCreditoID = Pro.ProducCreditoID ');
				SET Par_ProductoCre := IFNULL(Par_ProductoCre,Entero_Cero);
                IF(Par_ProductoCre!=0)THEN
                    SET Var_Sentencia :=  CONCAT(Var_sentencia,' AND Pro.ProducCreditoID =',CONVERT(Par_ProductoCre,CHAR));
                END IF;

		SET Var_Sentencia := 	CONCAT(Var_Sentencia,'  INNER JOIN CLIENTES Cli ON Cre.ClienteID = Cli.ClienteID');

		SET Par_Genero := IFNULL(Par_Genero,Cadena_Vacia);
                IF(Par_Genero!=Cadena_Vacia)THEN
                    SET Var_Sentencia := CONCAT(Var_sentencia,' AND Cli.Sexo="',Par_Genero,'"');
                    SET Var_Sentencia := CONCAT(Var_sentencia,' AND Cli.TipoPersona="',Var_PerFisica,'"');
		END IF;


		SET Par_Estado := IFNULL(Par_Estado,Entero_Cero);
                IF(Par_Estado!=0)THEN
                    SET Var_Sentencia := CONCAT(Var_sentencia,' AND (SELECT Dir.EstadoID FROM DIRECCLIENTE Dir WHERE Dir.Oficial= "S" AND Cli.ClienteID=Dir.ClienteID)=',CONVERT(Par_Estado,CHAR));
                END IF;

		SET Par_Municipio := IFNULL(Par_Municipio,Entero_Cero);
                IF(Par_Municipio!=0)THEN
                    SET Var_Sentencia := CONCAT(Var_sentencia,' AND (SELECT Dir.MunicipioID FROM DIRECCLIENTE Dir WHERE Dir.Oficial="S" AND Cli.ClienteID=Dir.ClienteID)=',CONVERT(Par_Municipio,CHAR));
                END IF;

		SET Var_Sentencia := 	CONCAT(Var_Sentencia,' INNER JOIN PROMOTORES PROM ON PROM.PromotorID=Cli.PromotorActual ');

		SET Par_Promotor := IFNULL(Par_Promotor,Entero_Cero);
                IF(Par_Promotor!=0)THEN
                    SET Var_Sentencia := CONCAT(Var_sentencia,'   AND PROM.PromotorID=',CONVERT(Par_Promotor,CHAR));
                END IF;

		SET Par_Moneda := IFNULL(Par_Moneda,Entero_Cero);
                IF(Par_Moneda!=0)THEN
                    SET Var_Sentencia = CONCAT(Var_sentencia,' AND Cre.MonedaID=',CONVERT(Par_Moneda,CHAR));
                END IF;

		SET Var_Sentencia := 	CONCAT(Var_Sentencia, ' INNER JOIN SUCURSALES Suc ON Suc.SucursalID = Cre.SucursalID ');

		SET Par_Sucursal := IFNULL(Par_Sucursal,Entero_Cero);
                IF(Par_Sucursal!=0)THEN
                    SET Var_Sentencia = CONCAT(Var_sentencia,' AND Cre.SucursalID=',CONVERT(Par_Sucursal,CHAR));
                END IF;
		SET Var_Sentencia = CONCAT(Var_sentencia,' LEFT JOIN GRUPOSCREDITO Gpo ON Gpo.GrupoID = Cre.GrupoID ');
		
		SET Var_Sentencia :=  CONCAT(Var_Sentencia,' WHERE if("',Var_CliEsp,'" IN("',Var_CliTR,'","',Var_CliAyE,'"),(Cre.Estatus	= "',EstatusVigente,'" OR Cre.Estatus = "',EstatusVencido,'"),(Cre.Estatus	= "',EstatusVigente,'" OR Cre.Estatus = "',EstatusVencido,'" OR Cre.Estatus = "',EstatusPagado,'" OR Cre.Estatus = "',EstatusSuspendido,'")) ');
        SET Var_Sentencia :=  CONCAT(Var_Sentencia,' AND Amc.FechaExigible	>= ? AND Amc.FechaExigible <= ? ');

		IF (Var_CliEsp = Var_CliTR) THEN
			SET Var_Sentencia := CONCAT(Var_Sentencia, ' AND Amc.Estatus<> "P" ');
		END IF;

		IF(Par_ProductoCre!=0)THEN
			SELECT ProductoNomina INTO EsProductoNomina FROM PRODUCTOSCREDITO WHERE ProducCreditoID=Par_ProductoCre LIMIT 1;
			IF(EsProductoNomina='S')THEN
				SET Par_InstNominaID	:= IFNULL(Par_InstNominaID,Entero_Cero);
				SET	Par_ConvenioID		:= IFNULL(Par_ConvenioID,Entero_Cero);

				IF(Par_InstNominaID=Entero_Cero AND Par_ConvenioID!=Entero_Cero) THEN
					SET Var_Sentencia	:=	CONCAT(Var_Sentencia,' AND Nomc.ConvenioNominaID=',CONVERT(Par_ConvenioID,CHAR));
				END IF;
				IF(Par_InstNominaID!=Entero_Cero AND Par_ConvenioID=Entero_Cero) THEN
					SET Var_Sentencia	:=	CONCAT(Var_Sentencia, ' AND Nomc.InstitNominaID=', CONVERT(Par_InstNominaID,CHAR));
				END IF;
				IF(Par_InstNominaID!=Entero_Cero AND Par_ConvenioID!=Entero_Cero) THEN
					SET Var_Sentencia	:=	CONCAT(Var_Sentencia, ' AND Nomc.InstitNominaID=', CONVERT(Par_InstNominaID,CHAR),
											' AND Nomc.ConvenioNominaID=',CONVERT(Par_ConvenioID,CHAR));
				END IF;
			END IF;
		END IF;

		SET Var_Sentencia :=  CONCAT(Var_Sentencia,' ORDER BY Cre.SucursalID, Cre.ProductoCreditoID, Cli.PromotorActual,Cre.CreditoID,Amc.FechaVencim;');




	SET @Sentencia	= (Var_Sentencia);
	SET @FechaInicio	= Par_FechaInicio;
	SET @FechaFin		= Par_FechaFin;

   PREPARE STSALDOSCAPITALREP FROM @Sentencia;
      EXECUTE STSALDOSCAPITALREP USING @FechaInicio, @FechaFin;
      DEALLOCATE PREPARE STSALDOSCAPITALREP;


UPDATE TMPVENCIMCREREP
	SET DiasAtraso=Entero_Cero
		WHERE  DiasAtraso < Entero_Cero;
        
      UPDATE
        TMPVENCIMCREREP AS TM
        INNER JOIN
        CLIENTES AS CL
        ON
        TM.ClienteID=CL.ClienteID
		SET TM.TotalCuota=ROUND((TM.TotalCuota-TM.IVATotal),2),
        TM.IVATotal=0
        WHERE
        CL.PagaIVA="N";


	
	IF(Var_RestringeReporte = 'N')THEN
		SELECT
			IFNULL(TMP.Transaccion, Entero_Cero) AS Transaccion,
			IFNULL(TMP.GrupoID, Entero_Cero) AS GrupoID,
			IFNULL(TMP.NombreGrupo, Cadena_Vacia) AS NombreGrupo,
			IFNULL(TMP.CreditoID,Entero_Cero) AS CreditoID,
            IFNULL(CRE.CuentaID,Entero_Cero) AS CuentaID,
			IFNULL(TMP.CicloGrupo, Entero_Cero) AS CicloGrupo ,
			IFNULL(TMP.ClienteID, Entero_Cero) AS ClienteID,
			IFNULL(TMP.NombreCompleto, Cadena_Vacia) AS NombreCompleto,
			IFNULL(TMP.MontoCredito, Decimal_Cero) AS MontoCredito,
			IFNULL(TMP.FechaInicio, Fecha_Vacia) AS FechaInicio,
			IFNULL(TMP.FechaVencimien, Fecha_Vacia) AS FechaVencimien,
			IFNULL(TMP.FechaVencim, Fecha_Vacia) AS FechaVencim,
			IFNULL(TMP.EstatusCredito, Cadena_Vacia) AS EstatusCredito,
			IFNULL(TMP.Capital, Decimal_Cero) AS Capital,
			IFNULL(TMP.Interes, Decimal_Cero) AS Interes,
			IFNULL(TMP.Moratorios, Decimal_Cero) AS Moratorios,
			IFNULL(TMP.Comisiones, Decimal_Cero) AS Comisiones,
			IFNULL(TMP.Cargos, Decimal_Cero) AS Cargos,
			IFNULL(TMP.AmortizacionID, Entero_Cero) AS AmortizacionID,
			IFNULL(TMP.IVATotal, Decimal_Cero)	AS IVATotal,
			IFNULL(TMP.CobraIVAMora, Cadena_Vacia) AS CobraIVAMora,
			IFNULL(TMP.CobraIVAInteres, Cadena_Vacia) AS CobraIVAInteres,
			IFNULL(TMP.SucursalID, Entero_Cero) AS SucursalID,
			IFNULL(TMP.NombreSucurs, Cadena_Vacia) AS NombreSucurs,
			IFNULL(TMP.ProductoCreditoID, Entero_Cero) AS ProductoCreditoID,
			IFNULL(TMP.Descripcion, Cadena_Vacia) AS Descripcion,
			IFNULL(TMP.PromotorActual, Entero_Cero) AS PromotorActual,
			IFNULL(TMP.NombrePromotor, Cadena_Vacia) AS NombrePromotor,
			IFNULL(TMP.TotalCuota, Decimal_Cero) AS TotalCuota,
			IFNULL(TMP.Pago, Decimal_Cero) AS Pago,
			IFNULL(TMP.FechaPago, Cadena_Vacia) AS FechaPago,
			IFNULL(TMP.DiasAtraso, Entero_Cero) AS DiasAtraso,
			IFNULL(TMP.SaldoTotal, Entero_Cero) AS SaldoTotal,
			TMP.InstitNominaID,
			TMP.ConvenioNominaID,
			IFNULL(TMP.FechaEmision, Fecha_Vacia) AS FechaEmision,
			IFNULL(TMP.HoraEmision, Hora_Vacia) AS HoraEmision
		FROM TMPVENCIMCREREP TMP inner join CREDITOS CRE on TMP.CreditoID=CRE.CreditoID 
		WHERE Transaccion = Aud_NumTransaccion
		  AND DiasAtraso >= Par_AtrasoInicial
		  AND DiasAtraso <= Par_AtrasoFinal
		ORDER BY SucursalID, ProductoCreditoID, PromotorActual, CreditoID, FechaVencim;
	END IF;

	
	IF(Var_RestringeReporte = 'S')THEN

		
		SET Var_UsuDependencia := (SELECT FNUSUARIOSDEPENDECIA(Aud_Usuario));

		SET Var_Sentencia := CONCAT('
		SELECT
			IFNULL(TMP.Transaccion, 0) AS Transaccion,
			IFNULL(TMP.GrupoID, 0) AS GrupoID,
			IFNULL(TMP.NombreGrupo, "") AS NombreGrupo,
			IFNULL(TMP.CreditoID, 0) AS CreditoID,
            IFNULL(CRE.CuentaID,0) AS CuentaID,
			IFNULL(TMP.CicloGrupo, 0) AS CicloGrupo,
			IFNULL(TMP.ClienteID, 0) AS ClienteID,
			IFNULL(TMP.NombreCompleto, "") AS NombreCompleto,
			IFNULL(TMP.MontoCredito, 0.00) AS MontoCredito,
			IFNULL(TMP.FechaInicio, "1900-01-00") AS FechaInicio,
			IFNULL(TMP.FechaVencimien, "1900-01-00") AS FechaVencimien,
			IFNULL(TMP.FechaVencim, "1900-01-00") AS FechaVencim,
			IFNULL(TMP.EstatusCredito, "") AS EstatusCredito,
			IFNULL(TMP.Capital, 0.00) AS Capital,
			IFNULL(TMP.Interes, 0.00) AS Interes,
			IFNULL(TMP.Moratorios, 0.00) AS Moratorios,
			IFNULL(TMP.Comisiones, 0.00) AS Comisiones,
			IFNULL(TMP.Cargos, 0.00) AS Cargos,
			IFNULL(TMP.AmortizacionID, 0) AS AmortizacionID,
			IFNULL(TMP.IVATotal, 0.00) AS IVATotal,
			IFNULL(TMP.CobraIVAMora, "") AS CobraIVAMora,
			IFNULL(TMP.CobraIVAInteres, "") AS CobraIVAInteres,
			IFNULL(TMP.SucursalID, 0) AS SucursalID,
			IFNULL(TMP.NombreSucurs, "") AS NombreSucurs,
			IFNULL(TMP.ProductoCreditoID, 0) AS ProductoCreditoID,
			IFNULL(TMP.Descripcion, "") AS Descripcion,
			IFNULL(TMP.PromotorActual, 0) AS PromotorActual,
			IFNULL(TMP.NombrePromotor, "") AS NombrePromotor,
			IFNULL(TMP.TotalCuota, 0.00) AS TotalCuota,
			IFNULL(TMP.Pago, 0.00) AS Pago,
			IFNULL(TMP.FechaPago, "") AS FechaPago,
			IFNULL(TMP.DiasAtraso, 0) AS DiasAtraso,
			IFNULL(TMP.SaldoTotal, 0.00) AS SaldoTotal,
			TMP.InstitNominaID,
			TMP.ConvenioNominaID,
			IFNULL(TMP.FechaEmision, "1900-01-01") AS FechaEmision,
			IFNULL(TMP.HoraEmision, "00:00:00") AS HoraEmision
		FROM (TMPVENCIMCREREP TMP inner join CREDITOS CRE on TMP.CreditoID=CRE.CreditoID)
		INNER JOIN SOLICITUDCREDITO SOL ON TMP.CreditoID = SOL.CreditoID
		WHERE Transaccion = 	',Aud_NumTransaccion,'
		  AND TMP.DiasAtraso >=	',Par_AtrasoInicial,'
		  AND TMP.DiasAtraso <=	',Par_AtrasoFinal,'
		  AND SOL.UsuarioAltaSol IN(',Var_UsuDependencia,')
		ORDER BY TMP.SucursalID, TMP.ProductoCreditoID, TMP.PromotorActual, TMP.CreditoID, TMP.FechaVencim;
        ');

		SET @Sentencia2	= (Var_Sentencia);

		PREPARE STSALDOSCAPITALREP2 FROM @Sentencia2;
		EXECUTE STSALDOSCAPITALREP2;
		DEALLOCATE PREPARE STSALDOSCAPITALREP2;

    END IF;

	DELETE FROM TMPVENCIMCREREP WHERE Transaccion = Aud_NumTransaccion;


END TerminaStore$$