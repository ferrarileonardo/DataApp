USE `master`;
 
/* SQLINES DEMO *** atabase [SALTOANGEL]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE DATABASE [SALTOANGEL]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'SALTOANGEL', FILENAME = N'C:Program FilesMicrosoft SQL ServerMSSQL13.SALTOANGELMSSQLDATASALTOANGEL.mdf' , SIZE = 466944KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = 'SALTOANGEL_log', FILENAME = 'C:Program FilesMicrosoft SQL ServerMSSQL13.SALTOANGELMSSQLDATASALTOANGEL_log.ldf' , SIZE = 1646592KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
/* ALTER DATABASE `SALTOANGEL` SET COMPATIBILITY_LEVEL = 130 */
 
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
then
CALL `SALTOANGEL`.`sp_fulltext_database`(p_action = 'enable');
end if;
 
/* ALTER DATABASE `SALTOANGEL` SET ANSI_NULL_DEFAULT OFF */ 
 
/* ALTER DATABASE `SALTOANGEL` SET ANSI_NULLS OFF */ 
 
/* ALTER DATABASE `SALTOANGEL` SET ANSI_PADDING OFF */ 
 
/* ALTER DATABASE `SALTOANGEL` SET ANSI_WARNINGS OFF */ 
 
/* ALTER DATABASE `SALTOANGEL` SET ARITHABORT OFF */ 
 
/* ALTER DATABASE `SALTOANGEL` SET AUTO_CLOSE OFF */ 
 
/* ALTER DATABASE `SALTOANGEL` SET AUTO_SHRINK OFF */ 
 
/* ALTER DATABASE `SALTOANGEL` SET AUTO_UPDATE_STATISTICS ON */ 
 
/* ALTER DATABASE `SALTOANGEL` SET CURSOR_CLOSE_ON_COMMIT OFF */ 
 
/* ALTER DATABASE `SALTOANGEL` SET CURSOR_DEFAULT  GLOBAL */ 
 
/* ALTER DATABASE `SALTOANGEL` SET CONCAT_NULL_YIELDS_NULL OFF */ 
 
/* ALTER DATABASE `SALTOANGEL` SET NUMERIC_ROUNDABORT OFF */ 
 
/* ALTER DATABASE `SALTOANGEL` SET QUOTED_IDENTIFIER OFF */ 
 
/* ALTER DATABASE `SALTOANGEL` SET RECURSIVE_TRIGGERS OFF */ 
 
/* ALTER DATABASE `SALTOANGEL` SET  DISABLE_BROKER */ 
 
/* ALTER DATABASE `SALTOANGEL` SET AUTO_UPDATE_STATISTICS_ASYNC OFF */ 
 
/* ALTER DATABASE `SALTOANGEL` SET DATE_CORRELATION_OPTIMIZATION OFF */ 
 
/* ALTER DATABASE `SALTOANGEL` SET TRUSTWORTHY OFF */ 
 
/* ALTER DATABASE `SALTOANGEL` SET ALLOW_SNAPSHOT_ISOLATION OFF */ 
 
/* ALTER DATABASE `SALTOANGEL` SET PARAMETERIZATION SIMPLE */ 
 
/* ALTER DATABASE `SALTOANGEL` SET READ_COMMITTED_SNAPSHOT OFF */ 
 
/* ALTER DATABASE `SALTOANGEL` SET HONOR_BROKER_PRIORITY OFF */ 
 
/* ALTER DATABASE `SALTOANGEL` SET RECOVERY FULL */ 
 
/* ALTER DATABASE `SALTOANGEL` SET  MULTI_USER */ 
 
/* ALTER DATABASE `SALTOANGEL` SET PAGE_VERIFY CHECKSUM */  
 
/* ALTER DATABASE `SALTOANGEL` SET DB_CHAINING OFF */ 
 
ALTER DATABASE `SALTOANGEL` SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
 
ALTER DATABASE `SALTOANGEL` SET TARGET_RECOVERY_TIME = 60 SECONDS 
 
ALTER DATABASE `SALTOANGEL` SET DELAYED_DURABILITY = DISABLED 
 
EXECUTE sys.sp_db_vardecimal_storage_format 'SALTOANGEL', 'ON'
GO
ALTER DATABASE `SALTOANGEL` SET QUERY_STORE = OFF
 
USE `SALTOANGEL`;
 
/* ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF; */
 
/* ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0; */
 
/* ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON; */
 
/* ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF; */
 
USE `SALTOANGEL`;
 
/* SQLINES DEMO *** ser [saltoangel]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE USER `saltoangel` FOR LOGIN `saltoangel` -- SQLINES FOR EVALUATION USE ONLY (14 DAYS)
 WITH DEFAULT_SCHEMA=`dbo`
GO
/* SQLINES DEMO *** serDefinedFunction [dbo].[CostoAcumuladoProducto]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 

DELIMITER //

CREATE FUNCTION `CostoAcumuladoProducto`(p_PrimerDiaMes DATETIME(3))
RETURNS @InventarioInicial TABLE
  (
	Codigo nvarchar(20),
	Descripcion nvarchar(80),
	Saldo decimal(19,4)
  )
DETERMINISTIC
BEGIN
DECLARE JSONDATA LONGTEXT;
	INSERT @InventarioInicial
		SELECT I.Codigo, I.Descripcion,SUM(Balance)
		FROM ItemsInventario I, BalancesMensuales D
		WHERE D.IndicePeriodo < Year(p_PrimerDiaMes) * 100 + Month(p_PrimerDiaMes)
			AND D.CodigoEntidad = I.Codigo
			AND D.TipoEntidad = 'VIV'
		GROUP BY I.Codigo, I.Descripcion
		ORDER BY I.Codigo;
	RETURN;
END;
//

DELIMITER ;


/* SQLINES DEMO *** serDefinedFunction [dbo].[costoFecha]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 

DELIMITER //

CREATE FUNCTION `costoFecha`(p_fo DATETIME(3))
  RETURNS @retTable TABLE
    (	codigoItem nvarchar(20), 
      fechaOperacion DATETIME(3),
      costo DECIMAL(19,4)
    )
DETERMINISTIC
BEGIN
DECLARE JSONDATA LONGTEXT;
  INSERT @retTable
    SELECT codigoItem, FechaOperacion, Costo
    FROM DetallesMINV D1
    WHERE NumeroDocumento * 10000 + Renglon = (
      SELECT MAX(NumeroDocumento * 10000 + Renglon)
      FROM (SELECT * FROM DetallesMINV D2
        WHERE CodigoItem = D1.CodigoItem 
        AND FechaOperacion = (
          SELECT MAX(FechaOperacion) FROM DetallesMINV D2
          WHERE FechaOperacion < p_fo
          AND Costo <> 0
          AND CodigoItem = D1.CodigoItem
        )
      ) D3
    );
  RETURN;
END;
//

DELIMITER ;


/* SQLINES DEMO *** serDefinedFunction [dbo].[DateSerial]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 

DELIMITER //

CREATE FUNCTION `DateSerial`(p_year Int, p_month Int, p_day Int)
RETURNS DATETIME(3)
DETERMINISTIC
BEGIN
	RETURN CONCAT(CONVERT(p_year, CHAR(4)) , RIGHT(Concat('00' , CONVERT(p_month, CHAR(2))), 2) , RIGHT(Concat('00' , CONVERT(p_day, CHAR(2))), 2));
END;
//

DELIMITER ;


/* SQLINES DEMO *** serDefinedFunction [dbo].[ExistenciaAcumuladaProducto]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 

DELIMITER //

CREATE FUNCTION `ExistenciaAcumuladaProducto`(p_PrimerDiaMes DATETIME(3))
RETURNS @InventarioInicial TABLE
  (
	Codigo nvarchar(20),
	Descripcion nvarchar(80),
	Saldo decimal(19,4)
  )
DETERMINISTIC
BEGIN
DECLARE JSONDATA LONGTEXT;
	INSERT @InventarioInicial
		SELECT I.Codigo, I.Descripcion,SUM(Balance)
		FROM ItemsInventario I, BalancesMensuales D
		WHERE D.IndicePeriodo < Year(p_PrimerDiaMes) * 100 + Month(p_PrimerDiaMes)
			AND D.CodigoEntidad = I.Codigo
			AND D.TipoEntidad = 'INV'
		GROUP BY I.Codigo, I.Descripcion
		ORDER BY I.Codigo;
	RETURN;
END;
//

DELIMITER ;


/* SQLINES DEMO *** serDefinedFunction [dbo].[ExistenciaFecha]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 

DELIMITER //

CREATE FUNCTION `ExistenciaFecha`
(
	p_Fecha DATETIME(3)
)
RETURNS @valores TABLE
  ( 
	codigo nvarchar(20),
	existencia double
   )
DETERMINISTIC
BEGIN
DECLARE JSONDATA LONGTEXT;
	DECLARE v_indicePeriodo INT;
	DECLARE v_PrimerDiaMes DATETIME(3);
	SET v_PrimerDiaMes = TIMESTAMPADD(d, -(DAY(p_Fecha) - 1), p_Fecha);
	SET v_indicePeriodo = YEAR(p_Fecha) * 100 + MONTH(p_Fecha);
	INSERT @valores
		SELECT codigoEntidad, SUM(valor) FROM 
		(
			SELECT CodigoEntidad, SUM(Balance) As Valor
				FROM BalancesMensuales
				WHERE TipoEntidad = 'INV'
				AND IndicePeriodo < v_indicePeriodo
				GROUP BY CodigoEntidad
			UNION SELECT CodigoItem, SUM((Entradas - Salidas))
				FROM DetallesMinv
				WHERE FechaOperacion BETWEEN v_PrimerDiaMes AND TIMESTAMPADD(d, -1, p_Fecha)
				GROUP BY CodigoItem
		) T
		GROUP BY CodigoEntidad;
	RETURN;
END;
//

DELIMITER ;


/* SQLINES DEMO *** serDefinedFunction [dbo].[ExistenciaItemFecha]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 

DELIMITER //

CREATE FUNCTION `ExistenciaItemFecha`
(
	p_CodigoItem nVarChar(20),
	p_Fecha DATETIME(3)
)
RETURNS DOUBLE
DETERMINISTIC
BEGIN
	DECLARE v_Result DOUBLE;
	DECLARE v_ResultM DOUBLE; DECLARE v_ResultD DOUBLE;
	DECLARE v_indicePeriodo INT;
	DECLARE v_inicioMes DATETIME(3);

	SET v_indicePeriodo = YEAR(p_Fecha) * 100 + MONTH(p_Fecha);
	SELECT COALESCE(SUM(Balance), 0) INTO v_ResultM
		FROM BalancesMensuales 
		WHERE TipoEntidad = 'INV' 
		AND CodigoEntidad = p_CodigoItem 
		AND IndicePeriodo < v_indicePeriodo;
	SET v_inicioMes = TIMESTAMPADD(d, -(DAY(p_Fecha) - 1), p_Fecha);
	SELECT COALESCE(SUM(Entradas - Salidas), 0) INTO v_ResultD
			FROM DetallesMinv 
			WHERE CodigoItem = p_CodigoItem 
			AND FechaOperacion BETWEEN v_inicioMes AND p_Fecha;
	SET v_Result = v_ResultM + v_ResultD;
	RETURN v_Result;
END;
//

DELIMITER ;


/* SQLINES DEMO *** serDefinedFunction [dbo].[ExtraerLinea]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 

DELIMITER //

CREATE FUNCTION `ExtraerLinea`(p_d NVARCHAR(255), p_w SMALLINT, p_lineIndex TINYINT UNSIGNED)
  RETURNS NVARCHAR(255)
DETERMINISTIC 
  BEGIN
	DECLARE v_nextCh nvarchar(1); DECLARE v_isDone TINYINT UNSIGNED;
	DECLARE v_ndx SMALLINT;
	DECLARE v_n SMALLINT; DECLARE v_p1 SMALLINT; DECLARE v_p2 SMALLINT;
	DECLARE v_resto nvarchar(255); DECLARE v_temp NVARCHAR(255); DECLARE v_retVal NVARCHAR(255);

	IF p_lineIndex < 1 THEN RETURN ''; END IF;

	SET v_ndx = 1;
	SET v_resto = p_d;

	WHILE CHAR_LENGTH(RTRIM(v_resto)) > p_w
	DO
		SET v_resto = LTRIM(RTRIM(v_resto));
		SET v_n = 1;
		WHILE UNICODE(SUBSTRING(v_resto, v_n, 1)) < 32 SET v_n = v_n + 1;
		IF v_n > 1 THEN SET v_resto = SUBSTRING(v_resto, v_n, CHAR_LENGTH(RTRIM(v_resto))); END IF;

		-- SQLINES DEMO *** de carro (CR) ...
		SET v_p1 = LOCATE(NCHAR(13), v_resto);
		IF v_p1 != 0 And v_p1 <= p_w
		THEN
			SET v_p2 = LOCATE(NCHAR(10), v_resto);
			IF v_p2 < v_p1 THEN SET v_p1 = v_p2; END IF;
			SET v_temp = SUBSTRING(v_resto, 1, v_p1 - 1);
			SET v_resto = SUBSTRING(v_resto, v_p1 + 1, 160);
		ELSE
			SET v_temp = LEFT(v_resto, p_w);
			SET v_isDone = 0;
			SET v_n = p_w;

			WHILE v_isDone = 0 AND v_n > 0
			DO
				SET v_nextCh = SUBSTRING(v_temp, v_n, 1);
				If v_nextCh = ' '
				THEN
					SET v_n = v_n - 1;
					SET v_isDone = 1;
			 ELSE
					IF LOCATE(v_nextCh, ',.:;') > 0 THEN SET v_isDone = 1; END IF;
				END IF;
				IF v_isDone = 0 THEN SET v_n = v_n - 1; END IF;
			END WHILE;
			IF v_isDone = 0 THEN SET v_n = p_w; END IF;
			SET v_temp = LEFT(v_temp, v_n);
		END IF;
		SET v_resto = SUBSTRING(v_resto, CHAR_LENGTH(RTRIM(v_temp)) + 1, CHAR_LENGTH(RTRIM(v_resto)));
		IF v_ndx = p_lineIndex THEN RETURN v_temp; END IF;
		SET v_ndx = v_ndx + 1;
	END WHILE;
	SET v_resto = LTRIM(RTRIM(v_resto));
	SET v_resto = LEFT(v_resto, p_w);
	IF v_ndx = p_lineIndex THEN RETURN v_resto; END IF;
	RETURN '';
  END WHILE;
//

DELIMITER ;


/* SQLINES DEMO *** serDefinedFunction [dbo].[FechaEntera]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 

DELIMITER //

CREATE FUNCTION `FechaEntera`(p_arg DATETIME(3))
RETURNS DATETIME(3)
DETERMINISTIC
BEGIN
	RETURN CONVERT(FLOOR(CONVERT(p_arg, DOUBLE)), DATETIME);
END;
//

DELIMITER ;


/* SQLINES DEMO *** serDefinedFunction [dbo].[GetDocumentosMedioPago]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 

DELIMITER //

CREATE FUNCTION `GetDocumentosMedioPago` (
	p_codigoMedio NVARCHAR(12),
  p_Emisor NVARCHAR(20),
  p_NumeroCheque NVARCHAR(20)
) RETURNS @DocumentosAfectados TABLE (
	Tipo nVarChar(3),
  CodigoCliente nVarchar(20),
  Referencia nVarchar(40),
  FechaTransaccion DateTime(3), 
	MontoCheque Decimal(19,4)
)
DETERMINISTIC
BEGIN
DECLARE JSONDATA LONGTEXT;
  INSERT @DocumentosAfectados
  Select * From
  (Select 'FCT' As Tipo, CodigoCliente, Concat(Serie , '-' , RIGHT(Concat('00000000' , CONVERT(Correlativo, CHAR(8))), 8)) As Referencia, FechaTransaccion, DET.Monto
   FROM Facturas, DetallesIngresoCaja DET
   WHERE DET.Medio = p_codigoMedio AND DET.Emisor = p_Emisor AND Det.NumeroDocumento = p_NumeroCheque
   AND Facturas.Numero IN (
     SELECT NumDoc
	 FROM SubDocsMC
     WHERE TipoDoc = 'FCT' 
	 AND TransID = DET.TransID)
   UNION SELECT 'NDC' As Tipo, CodigoEntidad, CONCAT('NDC-' , RIGHT(Concat('00000000' , CONVERT(Correlativo, CHAR(8))), 8)), FechaDoc, DET2.Monto
   FROM NotasDCCP, DetallesINgresoCaja Det2
   WHERE TipoEntidad = 'CLT' 
   AND DET2.Medio = p_codigoMedio AND DET2.Emisor = p_Emisor AND Det2.NumeroDocumento = p_NumeroCheque
   AND Numero IN (
     SELECT NumDoc FROM SubDocsMC
     WHERE TipoDoc = 'NDC' 
	   AND TransID = DET2.TransID)
   UNION SELECT 'CHD' As Tipo, CodigoCliente, CONCAT('CHD' , RIGHT(Concat('00000000' , CONVERT(CH.ID, CHAR(8))), 8)), FechaDevolucion, DET3.Monto
   FROM ChequesDevueltos CH, DetallesIngresoCaja Det3
   WHERE Det3.Medio = p_codigoMedio AND Det3.Emisor = p_Emisor AND Det3.NumeroDocumento = p_NumeroCheque
   AND CH.ID IN (
	  SELECT NumDoc FROM SubDOcsMC
	  WHERE TipoDoc = 'CHD'
      AND TransID = DET3.TransID)
  ) T;
  RETURN;
END;
//

DELIMITER ;


/* SQLINES DEMO *** serDefinedFunction [dbo].[IVAFecha]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 

DELIMITER //

CREATE FUNCTION `IVAFecha`(p_tipo tinyInt UNSIGNED, p_Fecha DATETIME(3)) 
RETURNS DOUBLE
DETERMINISTIC 
BEGIN
	DECLARE v_retVal DOUBLE;
	SELECT alicuota INTO v_retVal
	  FROM historiaIVA WHERE tipo = p_tipo AND FechaInicioVigencia = (
	      SELECT MAX(FechaInicioVigencia)
	      FROM historiaIVA
	      WHERE tipo = p_tipo 
	      AND fechaInicioVigencia <= p_Fecha
	);
	RETURN COALESCE(v_retVal, 0);
END;
//

DELIMITER ;


/* SQLINES DEMO *** serDefinedFunction [dbo].[MergeFechaHora]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
DELIMITER //

CREATE FUNCTION `MergeFechaHora`(p_fecha DATETIME(3), p_hora DATETIME(3)) 
  RETURNS DATETIME(3)
DETERMINISTIC
  BEGIN
    RETURN CONVERT(
           FLOOR(CONVERT(p_fecha, DOUBLE)) + 
           CONVERT(p_hora, DOUBLE) - FLOOR(Convert(p_hora, DOUBLE)), DATETIME);
  END;
//

DELIMITER ;


/* SQLINES DEMO *** serDefinedFunction [dbo].[pesoFactura]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 

DELIMITER //

CREATE FUNCTION `pesoFactura`(p_numFac INTEGER)
RETURNS DOUBLE
DETERMINISTIC 
BEGIN
DECLARE v_retVal DOUBLE;
	select COALESCE(sum(i.peso * c.cantidad * d.cantidad), 0) into v_retVal
	  from (select * from detallesFactura where numeroDocumento = p_numFac) d
	  inner join itemsVenta v on v.codigo = d.codigoitem
	  inner join composicionitemsventa c on c.codigoitemventa = v.codigo
	  inner join itemsInventario i on i.codigo = c.codigoItemInventario;
	return v_retVal;
END;
//

DELIMITER ;


/* SQLINES DEMO *** serDefinedFunction [dbo].[RedondearMonetario]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 

DELIMITER //

CREATE FUNCTION `RedondearMonetario` 
(
	p_valor DECIMAL(19,4), p_redondeo DECIMAL(19,4)
)
RETURNS DECIMAL(19,4)
DETERMINISTIC
BEGIN
DECLARE v_signo DECIMAL(19,4); DECLARE v_retVal DECIMAL(19,4); DECLARE v_entero DECIMAL(19,4); DECLARE v_frac DECIMAL(19,4);
  SET v_signo = Sign(p_valor);
  SET p_valor = Abs(p_valor);
  If p_redondeo = 0 Then RETURN p_valor; End if;
  IF p_valor = 0 THEN RETURN p_valor; END IF;
  IF p_redondeo = 0.5
  THEN
    SET v_entero = FLOOR(p_valor);
    SET v_frac = p_valor - v_entero;
    IF v_frac >= 0.75 THEN SET v_frac = 1; END IF;
    IF v_frac BETWEEN 0.25 AND 0.74 THEN SET v_frac = 0.5; END IF;
    If v_frac < 0.25 Then SET v_frac = 0; End if;
	SET v_retVal = v_entero + v_frac;
  ELSE
	SET v_retVal = FLOOR(p_valor / p_redondeo + 0.5) * p_redondeo;
  END IF;
  IF v_retVal = 0 THEN SET v_retVal = p_redondeo; END IF;
  SET v_retVal = v_retVal * v_signo;
  RETURN v_retVal;
END;
//

DELIMITER ;


/* SQLINES DEMO *** serDefinedFunction [dbo].[SafeDivide]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
-- SQLINES DEMO *** ===========================================================
-- AT... SQLINES DEMO ***
-- SQLINES DEMO *** ===========================================================
-- SQLINES DEMO *** ARADA EN ESTE ARCHIVO DEBE ESTAR SEPARADA DE LA SIGUIENTE
-- SQLINES DEMO ***  FORMADO POR DOS GUIONES Y EL TEXTO "ENDFN", EN MAYUSCULAS
-- SQLINES DEMO *** R EL SEPARADOR DESPUES DE LA ULTIMA FUNCION DEFINIDA


DELIMITER //

CREATE FUNCTION `SafeDivide`(p_dividendo DOUBLE, p_divisor DOUBLE) 
RETURNS DOUBLE
DETERMINISTIC
BEGIN
	IF p_divisor = 0
	THEN
		RETURN 0;
	END IF;
	RETURN p_dividendo / p_divisor;
END;
//

DELIMITER ;


/* SQLINES DEMO *** serDefinedFunction [dbo].[SaldoAcumulado]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 

DELIMITER //

CREATE FUNCTION `SaldoAcumulado`(p_TipoEntidad NVARCHAR(3), p_Fecha DATETIME(3))
RETURNS @SaldosAcumulados TABLE
  (
	Codigo nvarchar(20),
	Saldo decimal(19,4)
  )
DETERMINISTIC
BEGIN
DECLARE JSONDATA LONGTEXT;
	INSERT @SaldosAcumulados
		SELECT Codigo, SUM(S) As Saldo FROM (
			SELECT CodigoEntidad As Codigo, SUM(Balance) As S
				FROM BalancesMensuales
				WHERE TipoEntidad = p_TipoEntidad
				AND IndicePeriodo < YEAR(p_Fecha) * 100 + MONTH(p_Fecha)
				GROUP BY CodigoEntidad
			UNION SELECT
				CodigoEntidad, SUM(Debe - Haber)
				FROM DetallesCuentaEntidad
				WHERE Fecha BETWEEN TIMESTAMPADD(d, -(DAY(p_Fecha) - 1), p_Fecha) AND p_Fecha
				AND TipoEntidad = p_TipoEntidad
				GROUP BY CodigoEntidad) T
			GROUP BY Codigo
		ORDER BY Codigo;
	RETURN;
END;
//

DELIMITER ;


/* SQLINES DEMO *** serDefinedFunction [dbo].[SaldoAcumuladoMEX]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 

DELIMITER //

CREATE FUNCTION `SaldoAcumuladoMEX`(p_TipoEntidad NVARCHAR(3), p_Fecha DATETIME(3))
RETURNS @SaldosAcumulados TABLE
  (
	Codigo nvarchar(20),
	Saldo decimal(19,4)
  )
DETERMINISTIC
BEGIN
DECLARE JSONDATA LONGTEXT;
	INSERT @SaldosAcumulados
		SELECT Codigo, SUM(S) As Saldo FROM (
			SELECT CodigoEntidad As Codigo, SUM(Balance) As S
				FROM BalancesMensualesMEX
				WHERE TipoEntidad = p_TipoEntidad
				AND IndicePeriodo < YEAR(p_Fecha) * 100 + MONTH(p_Fecha)
				GROUP BY CodigoEntidad
			UNION SELECT
				CodigoEntidad, SUM((Debe - Haber) / TipoCambio)
				FROM DetallesCuentaEntidad
				WHERE Fecha BETWEEN TIMESTAMPADD(d, -(DAY(p_Fecha) - 1), p_Fecha) AND p_Fecha
				AND TipoEntidad = p_TipoEntidad
				AND Descripcion NOT LIKE 'Variacion del TC de%'
				AND TipoCambio > 0
				GROUP BY CodigoEntidad) T
			GROUP BY Codigo
		ORDER BY Codigo;
	RETURN;
END;
//

DELIMITER ;


/* SQLINES DEMO *** serDefinedFunction [dbo].[SaldoEntidadFecha]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 

DELIMITER //

CREATE FUNCTION `SaldoEntidadFecha`(p_TipoEntidad NVARCHAR(3), p_CodigoEntidad NVARCHAR(40), p_Fecha DATETIME(3))
RETURNS DECIMAL(19,4)
DETERMINISTIC
BEGIN
	DECLARE v_Result DECIMAL(19,4);
	DECLARE v_ResultM DECIMAL(19,4); DECLARE v_ResultD DECIMAL(19,4);
	DECLARE v_indicePeriodo INT;
	DECLARE v_inicioMes DATETIME(3);

	SET v_indicePeriodo = YEAR(p_Fecha) * 100 + MONTH(p_Fecha);
	SELECT COALESCE(SUM(Balance), 0) INTO v_ResultM
		FROM BalancesMensuales 
		WHERE TipoEntidad = p_TipoEntidad 
		AND CodigoEntidad = p_CodigoEntidad 
		AND IndicePeriodo < v_indicePeriodo;
	SET v_inicioMes = TIMESTAMPADD(d, -(DAY(p_Fecha) - 1), p_Fecha);
	SELECT COALESCE(SUM(Debe - Haber), 0) INTO v_ResultD
			FROM DetallesCuentaEntidad
			WHERE CodigoEntidad = p_CodigoEntidad 
			AND TipoEntidad = p_TipoEntidad
			AND Fecha BETWEEN v_inicioMes AND p_Fecha;
	SET v_Result = v_ResultM + v_ResultD;
	RETURN v_Result;
END;
//

DELIMITER ;


/* SQLINES DEMO *** serDefinedFunction [dbo].[TipoCambioFecha]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
DELIMITER //

CREATE FUNCTION `TipoCambioFecha`
	(p_fecha DateTime(3))
	RETURNS DOUBLE
DETERMINISTIC
	BEGIN
	DECLARE v_ret DOUBLE;
		SET v_ret = (select newtc1
			from htc 
			where hora = (select MAX(hora) FROM htc WHERE hora < TIMESTAMPADD(d, 1, p_fecha))
limit 1);
		RETURN COALESCE(v_ret, 1);
	END;
//

DELIMITER ;


/* SQLINES DEMO *** serDefinedFunction [dbo].[ValoracionFecha]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 

DELIMITER //

CREATE FUNCTION `ValoracionFecha`
(
	p_Fecha DATETIME(3)
)
RETURNS @valores TABLE
  ( 
	codigo nvarchar(20),
	existencia double
   )
DETERMINISTIC
BEGIN
DECLARE JSONDATA LONGTEXT;
	DECLARE v_indicePeriodo INT;
	DECLARE v_PrimerDiaMes DATETIME(3);
	SET v_PrimerDiaMes = TIMESTAMPADD(d, -(DAY(p_Fecha) - 1), p_Fecha);
	SET v_indicePeriodo = YEAR(p_Fecha) * 100 + MONTH(p_Fecha);
	INSERT @valores
		SELECT codigoEntidad, SUM(valor) FROM 
		(
			SELECT CodigoEntidad, SUM(Balance) As Valor
				FROM BalancesMensuales
				WHERE TipoEntidad = 'VIV'
				AND IndicePeriodo < v_indicePeriodo
				GROUP BY CodigoEntidad
			UNION SELECT CodigoItem, SUM((Entradas - Salidas) * Costo)
				FROM DetallesMinv
				WHERE FechaOperacion BETWEEN v_PrimerDiaMes AND TIMESTAMPADD(d, -1, p_Fecha)
				GROUP BY CodigoItem
		) T
		GROUP BY CodigoEntidad;
	RETURN;
END;
//

DELIMITER ;


/* SQLINES DEMO *** serDefinedFunction [dbo].[ValorItemFecha]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 

DELIMITER //

CREATE FUNCTION `ValorItemFecha`
(
	p_CodigoItem nVarChar(20),
	p_Fecha DATETIME(3)
)
RETURNS DECIMAL(19,4)
DETERMINISTIC
BEGIN
	DECLARE v_Result DECIMAL(19,4);
	DECLARE v_ResultM DECIMAL(19,4); DECLARE v_ResultD DECIMAL(19,4);
	DECLARE v_indicePeriodo INT;
	DECLARE v_inicioMes DATETIME(3);

	SET v_indicePeriodo = YEAR(p_Fecha) * 100 + MONTH(p_Fecha);
	SELECT COALESCE(SUM(Balance), 0) INTO v_ResultM
		FROM BalancesMensuales 
		WHERE TipoEntidad = 'VIV' 
		AND CodigoEntidad = p_CodigoItem 
		AND IndicePeriodo < v_indicePeriodo;
	SET v_inicioMes = TIMESTAMPADD(d, -(DAY(p_Fecha) - 1), p_Fecha);
	SELECT COALESCE(SUM((Entradas - Salidas) * Costo), 0) INTO v_ResultD
			FROM DetallesMinv 
			WHERE CodigoItem = p_CodigoItem 
			AND FechaOperacion BETWEEN v_inicioMes AND p_Fecha;
	SET v_Result = v_ResultM + v_ResultD;
	RETURN v_Result;
END;
//

DELIMITER ;


/* SQLINES DEMO *** able [dbo].[PiezasMINV]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `PiezasMINV`(
	`id` int AUTO_INCREMENT NOT NULL,
	`numComprobante` int NOT NULL,
	`renglon` smallint NOT NULL,
	`codigoItem` nvarchar(20) NOT NULL,
	`cantidad` Double NOT NULL,
PRIMARY KEY 
(
	`id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[DetallesMINV]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `DetallesMINV`(
	`NumeroDocumento` int NOT NULL DEFAULT 0,
	`Renglon` smallint NOT NULL DEFAULT 0,
	`FechaOperacion` datetime(3) NOT NULL DEFAULT now(3),
	`TipoMovimiento` nvarchar(3) NOT NULL DEFAULT '',
	`CodigoItem` nvarchar(20) NOT NULL DEFAULT '',
	`Entradas` Double NOT NULL DEFAULT 0,
	`Salidas` Double NOT NULL DEFAULT 0,
	`Costo` Decimal(19,4) NOT NULL DEFAULT 0
);
/* SQLINES DEMO *** iew [dbo].[detallesMinvX]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE VIEW `detallesMinvX` As SELECT  D.*, COALESCE(P.Cantidad, 0) As piezas FROM DetallesMINV D LEFT JOIN piezasMINV P ON D.NumeroDocumento = P.numComprobante AND D.Renglon = P.renglon;
 
/* SQLINES DEMO *** able [dbo].[FacturasPOS]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `FacturasPOS`(
	`Numero` int AUTO_INCREMENT NOT NULL,
	`idMaquina` int NOT NULL,
	`NumeroTicket` int NOT NULL,
	`idSesion` int NOT NULL,
	`idUsuario` nvarchar(8) NOT NULL,
	`Hora` datetime(3) NOT NULL DEFAULT now(3),
	`MontoVenta` Decimal(19,4) NOT NULL,
	`Impuesto` Decimal(19,4) NOT NULL,
	`Servicio` Decimal(19,4) NOT NULL,
	`Vendedor` nvarchar(20) NULL,
	`Personas` smallint NOT NULL,
	`Cuenta` int NOT NULL,
	`Cliente` nvarchar(20) NULL,
	`Propina` Decimal(19,4) NOT NULL,
	`tipoConsumo` tinyint Unsigned NOT NULL DEFAULT 0,
	`TipoCambio` Double NOT NULL DEFAULT 1,
PRIMARY KEY 
(
	`Numero` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[IGTFFacturasPOS]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `IGTFFacturasPOS`(
	`numeroFactura` int NOT NULL,
	`montoImpuesto` Decimal(19,4) NULL
);
/* SQLINES DEMO *** iew [dbo].[facturasPOSX]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE VIEW `facturasPOSX` As SELECT  F.*, COALESCE(I.MontoImpuesto, 0) As IGTF FROM FacturasPOS F LEFT JOIN IGTFFacturasPOS I ON F.numero = I.numeroFactura;
 
/* SQLINES DEMO *** able [dbo].[nomProcesos]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `nomProcesos`(
	`Numero` int NOT NULL,
	`Operador` nvarchar(8) NOT NULL DEFAULT 0,
	`CodigoScript` nvarchar(12) NOT NULL,
	`FechaInicioPeriodo` datetime(3) NOT NULL,
	`FechaFinPeriodo` datetime(3) NOT NULL,
	`FechaCierre` datetime(3) NOT NULL,
PRIMARY KEY 
(
	`Numero` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[nomPrestamos]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `nomPrestamos`(
	`numero` int AUTO_INCREMENT NOT NULL,
	`fecha` datetime(3) NOT NULL,
	`trabajador` nvarchar(20) NOT NULL,
	`descripcion` nvarchar(50) NOT NULL,
	`fechaRegistro` datetime(3) NOT NULL DEFAULT now(3),
	`operador` nvarchar(8) NOT NULL,
	`monto` Decimal(19,4) NOT NULL,
	`saldo` Decimal(19,4) NOT NULL,
PRIMARY KEY 
(
	`numero` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[nomPagosPrestamo]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `nomPagosPrestamo`(
	`id` bigint AUTO_INCREMENT NOT NULL,
	`idPrestamo` int NOT NULL,
	`numProceso` int NOT NULL,
	`fecha` datetime(3) NOT NULL,
	`montoPagado` Decimal(19,4) NOT NULL,
PRIMARY KEY 
(
	`id` ASC
) 
);
/* SQLINES DEMO *** iew [dbo].[nomDetallesPrestamo]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 

CREATE VIEW `nomDetallesPrestamo`
AS
	select 
	  r.numero, r.saldo, r.trabajador, 0 as seq, r.fecha, r.descripcion, r.operador, r.monto as DB, 0 as cr
	  from nomPrestamos r
	union select
	  idprestamo, 0, pres.trabajador, id, p.fecha, CONCAT('Proceso ' , codigoscript), nomProcesos.operador, 0, montopagado
	  from nomPagosPrestamo p inner join nomProcesos 
	  on nomProcesos.numero = numProceso
		inner join nomPrestamos pres
		on pres.numero = idPrestamo;
 
/* SQLINES DEMO *** able [dbo].[SesionesCerradas]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `SesionesCerradas`(
	`SessionID` int NOT NULL,
	`MachineID` int NOT NULL DEFAULT 0,
	`Cerrada` smallint NOT NULL DEFAULT 0,
	`usrID` nvarchar(8) NOT NULL DEFAULT '',
	`Fecha` datetime(3) NOT NULL DEFAULT now(3),
	`StartTime` datetime(3) NOT NULL DEFAULT now(3),
	`ComprobanteAlmacen` int NOT NULL DEFAULT 0,
	`CurrentAccount` int NOT NULL DEFAULT 0,
	`CurrentAmount` Decimal(19,4) NOT NULL DEFAULT 0,
	`FacturasRealizadas` int NOT NULL DEFAULT 0,
	`MontoFacturado` Decimal(19,4) NOT NULL DEFAULT 0,
	`ImpuestoCobrado` Decimal(19,4) NOT NULL DEFAULT 0,
	`EfectivoEnCaja` Decimal(19,4) NOT NULL DEFAULT 0,
	`TTCVisa` Decimal(19,4) NOT NULL DEFAULT 0,
	`TTCMaster` Decimal(19,4) NOT NULL DEFAULT 0,
	`TTCOtras` Decimal(19,4) NOT NULL DEFAULT 0,
	`TDebito` Decimal(19,4) NOT NULL DEFAULT 0,
	`ChequesEnCaja` Decimal(19,4) NOT NULL DEFAULT 0,
	`Anulaciones` int NOT NULL DEFAULT 0,
	`MontoAnulaciones` Decimal(19,4) NOT NULL DEFAULT 0,
	`ImpuestoAnulado` Decimal(19,4) NOT NULL DEFAULT 0,
	`Retiros` int NOT NULL DEFAULT 0,
	`MontoRetirado` Decimal(19,4) NOT NULL DEFAULT 0,
	`CobrosRealizados` int NOT NULL DEFAULT 0,
	`MontoCobrado` Decimal(19,4) NOT NULL DEFAULT 0,
	`ServicioCobrado` Decimal(19,4) NOT NULL DEFAULT 0,
	`ServicioAnulado` Decimal(19,4) NOT NULL DEFAULT 0,
	`VentasACredito` Decimal(19,4) NOT NULL DEFAULT 0,
	`MontoEnCaja` Decimal(19,4) NOT NULL DEFAULT 0,
	`TTCAmex` Decimal(19,4) NOT NULL DEFAULT 0,
	`OtrosMedios` Decimal(19,4) NOT NULL DEFAULT 0,
	`Propinas` Decimal(19,4) NOT NULL DEFAULT 0,
	`PrimeraFactura` int NOT NULL DEFAULT 0,
	`UltimaFactura` int NOT NULL DEFAULT 0,
	`primeraNC` int NOT NULL DEFAULT 0,
	`ultimaNC` int NOT NULL DEFAULT 0,
	`montoNC` Decimal(19,4) NOT NULL DEFAULT 0,
	`impuestoNC` Decimal(19,4) NOT NULL DEFAULT 0,
	`adelantosEfectivo` int NOT NULL DEFAULT 0,
	`ingresoAdelantos` Decimal(19,4) NOT NULL DEFAULT 0,
	`efectivoAdelantado` Decimal(19,4) NOT NULL DEFAULT 0,
	`EfectivoMonedaExtranjera` Decimal(19,4) NOT NULL DEFAULT 0,
	`MontoNominalMonedaExtranjera` Decimal(19,4) NOT NULL DEFAULT 0,
	`NotasAcreditadas` Decimal(19,4) NOT NULL DEFAULT 0,
	`NCEmitidas` Decimal(19,4) NOT NULL DEFAULT 0,
	`IGTFRetenido` Decimal(19,4) NOT NULL DEFAULT 0,
PRIMARY KEY 
(
	`SessionID` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[SesionesPOS]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `SesionesPOS`(
	`SessionID` int AUTO_INCREMENT NOT NULL,
	`MachineID` int NOT NULL DEFAULT 0,
	`Cerrada` smallint NOT NULL DEFAULT 0,
	`usrID` nvarchar(8) NOT NULL DEFAULT '',
	`Fecha` datetime(3) NOT NULL DEFAULT now(3),
	`StartTime` datetime(3) NOT NULL DEFAULT now(3),
	`ComprobanteAlmacen` int NOT NULL DEFAULT 0,
	`CurrentAccount` int NOT NULL DEFAULT 0,
	`CurrentAmount` Decimal(19,4) NOT NULL DEFAULT 0,
	`FacturasRealizadas` int NOT NULL DEFAULT 0,
	`MontoFacturado` Decimal(19,4) NOT NULL DEFAULT 0,
	`ImpuestoCobrado` Decimal(19,4) NOT NULL DEFAULT 0,
	`EfectivoEnCaja` Decimal(19,4) NOT NULL DEFAULT 0,
	`TTCVisa` Decimal(19,4) NOT NULL DEFAULT 0,
	`TTCMaster` Decimal(19,4) NOT NULL DEFAULT 0,
	`TTCOtras` Decimal(19,4) NOT NULL DEFAULT 0,
	`TDebito` Decimal(19,4) NOT NULL DEFAULT 0,
	`ChequesEnCaja` Decimal(19,4) NOT NULL DEFAULT 0,
	`Anulaciones` int NOT NULL DEFAULT 0,
	`MontoAnulaciones` Decimal(19,4) NOT NULL DEFAULT 0,
	`ImpuestoAnulado` Decimal(19,4) NOT NULL DEFAULT 0,
	`Retiros` int NOT NULL DEFAULT 0,
	`MontoRetirado` Decimal(19,4) NOT NULL DEFAULT 0,
	`CobrosRealizados` int NOT NULL DEFAULT 0,
	`MontoCobrado` Decimal(19,4) NOT NULL DEFAULT 0,
	`ServicioCobrado` Decimal(19,4) NOT NULL DEFAULT 0,
	`ServicioAnulado` Decimal(19,4) NOT NULL DEFAULT 0,
	`VentasACredito` Decimal(19,4) NOT NULL DEFAULT 0,
	`MontoEnCaja` Decimal(19,4) NOT NULL DEFAULT 0,
	`TTCAmex` Decimal(19,4) NOT NULL DEFAULT 0,
	`OtrosMedios` Decimal(19,4) NOT NULL DEFAULT 0,
	`Propinas` Decimal(19,4) NOT NULL DEFAULT 0,
	`PrimeraFactura` int NOT NULL DEFAULT 0,
	`UltimaFactura` int NOT NULL DEFAULT 0,
	`primeraNC` int NOT NULL DEFAULT 0,
	`ultimaNC` int NOT NULL DEFAULT 0,
	`montoNC` Decimal(19,4) NOT NULL DEFAULT 0,
	`impuestoNC` Decimal(19,4) NOT NULL DEFAULT 0,
	`adelantosEfectivo` int NOT NULL DEFAULT 0,
	`ingresoAdelantos` Decimal(19,4) NOT NULL DEFAULT 0,
	`efectivoAdelantado` Decimal(19,4) NOT NULL DEFAULT 0,
	`EfectivoMonedaExtranjera` Decimal(19,4) NOT NULL DEFAULT 0,
	`MontoNominalMonedaExtranjera` Decimal(19,4) NOT NULL DEFAULT 0,
	`NotasAcreditadas` Decimal(19,4) NOT NULL DEFAULT 0,
	`NCEmitidas` Decimal(19,4) NOT NULL DEFAULT 0,
	`IGTFRetenido` Decimal(19,4) NOT NULL DEFAULT 0,
PRIMARY KEY 
(
	`SessionID` ASC
) 
);
/* SQLINES DEMO *** iew [dbo].[SesionesGeneral]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE VIEW `SesionesGeneral` As 
		SELECT * FROM SesionesPOS
		UNION
		SELECT * FROM SesionesCerradas;
 
/* SQLINES DEMO *** able [dbo].[acumuladoresTipoIVASesion]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `acumuladoresTipoIVASesion`(
	`numeroSesion` int NOT NULL DEFAULT 0,
	`tipoImpuesto` nvarchar(3) NOT NULL DEFAULT '',
	`valorAcumulado` Decimal(19,4) NOT NULL DEFAULT 0,
	`porcentajeIVA` Double NOT NULL DEFAULT 0,
 /* Name ignored: CONSTRAINT `PK_acumuladoresTipoIVASesion` */ PRIMARY KEY 
(
	`numeroSesion` ASC,
	`tipoImpuesto` ASC,
	`porcentajeIVA` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[AcumuladoresTipoIVAZ]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `AcumuladoresTipoIVAZ`(
	`numero` bigint AUTO_INCREMENT NOT NULL,
	`numeroZ` bigint NOT NULL,
	`TipoImpuesto` nvarchar(3) NOT NULL,
	`BaseImponible` Decimal(19,4) NOT NULL,
	`Porcentaje` Double NOT NULL,
	`valor` Decimal(19,4) NOT NULL,
PRIMARY KEY 
(
	`numero` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[adelantosEfectivo]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `adelantosEfectivo`(
	`id` int NOT NULL,
	`idSesion` int NOT NULL,
	`hora` datetime(3) NOT NULL DEFAULT now(3),
	`codigoCliente` nvarchar(20) NOT NULL DEFAULT '',
	`montoCobrado` Decimal(19,4) NOT NULL DEFAULT 0,
	`montoEntregado` Decimal(19,4) NOT NULL DEFAULT 0,
	`operador` nvarchar(8) NOT NULL DEFAULT '',
PRIMARY KEY 
(
	`id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[Ajustes]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `Ajustes`(
	`Numero` int NOT NULL DEFAULT 0,
	`refAjuste` nvarchar(20) NULL DEFAULT '',
	`Tipo` smallint NOT NULL DEFAULT 0,
	`Descripcion` nvarchar(50) NULL DEFAULT '',
	`Notas` nvarchar(255) NULL DEFAULT '',
	`FechaRegistro` datetime(3) NOT NULL DEFAULT now(3),
	`FechaTransaccion` datetime(3) NOT NULL DEFAULT now(3),
	`Operador` nvarchar(8) NOT NULL DEFAULT '',
	`Contrapartida` nvarchar(20) NULL DEFAULT '',
	`Almacen` nvarchar(8) NOT NULL DEFAULT '',
	`Status` smallint NOT NULL DEFAULT 0,
	`Valor` Decimal(19,4) NOT NULL DEFAULT 0,
PRIMARY KEY 
(
	`Numero` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[Almacenes]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `Almacenes`(
	`Codigo` nvarchar(8) NOT NULL,
	`Nombre` nvarchar(50) NOT NULL DEFAULT '',
	`CuentaActivo` nvarchar(20) NOT NULL DEFAULT '',
PRIMARY KEY 
(
	`Codigo` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[AlternosItemVenta]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `AlternosItemVenta`(
	`CodigoAlterno` nvarchar(20) NOT NULL,
	`CodigoItemVenta` nvarchar(20) NOT NULL DEFAULT '',
	`ID` int AUTO_INCREMENT NOT NULL,
PRIMARY KEY 
(
	`CodigoAlterno` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[AnulacionesPOS]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `AnulacionesPOS`(
	`ID` int AUTO_INCREMENT NOT NULL,
	`SessionID` int NOT NULL DEFAULT 0,
	`IDMaquina` int NOT NULL DEFAULT 0,
	`Hora` datetime(3) NOT NULL DEFAULT now(3),
	`NumeroTicket` int NOT NULL DEFAULT 0,
	`MontoVenta` Decimal(19,4) NOT NULL DEFAULT 0,
	`Impuesto` Decimal(19,4) NOT NULL DEFAULT 0,
	`Servicio` Decimal(19,4) NOT NULL DEFAULT 0,
	`numFactura` int NOT NULL DEFAULT 0,
PRIMARY KEY 
(
	`ID` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[appLog]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `appLog`(
	`id` bigint AUTO_INCREMENT NOT NULL,
	`Hora` datetime(3) NOT NULL DEFAULT now(3),
	`Usuario` nvarchar(8) NOT NULL DEFAULT '',
	`machineID` smallint NOT NULL DEFAULT 0,
	`descripcion` nvarchar(512) NOT NULL DEFAULT '',
PRIMARY KEY 
(
	`id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[Atributos]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `Atributos`(
	`TipoEntidad` nvarchar(3) NOT NULL,
	`CodigoEntidad` nvarchar(20) NOT NULL,
	`CodigoAtributo` nvarchar(20) NOT NULL,
	`ValorAtributo` nvarchar(255) NOT NULL DEFAULT '',
	`ID` int AUTO_INCREMENT NOT NULL,
 /* Name ignored: CONSTRAINT `PK_Atributos` */ PRIMARY KEY 
(
	`TipoEntidad` ASC,
	`CodigoEntidad` ASC,
	`CodigoAtributo` ASC,
	`ValorAtributo` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[atributosDescriptor]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `atributosDescriptor`(
	`id` int AUTO_INCREMENT NOT NULL,
	`tipoEntidad` nvarchar(3) NOT NULL DEFAULT '',
	`codigoAtributo` nvarchar(20) NOT NULL DEFAULT '',
	`descripcion` nvarchar(60) NOT NULL DEFAULT '',
	`tipoDato` nvarchar(255) NOT NULL DEFAULT '',
PRIMARY KEY 
(
	`id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[autorizadores]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `autorizadores`(
	`usrID` nvarchar(8) NOT NULL DEFAULT '',
PRIMARY KEY 
(
	`usrID` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[BalancesMensuales]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `BalancesMensuales`(
	`TipoEntidad` nvarchar(3) NOT NULL,
	`CodigoEntidad` nvarchar(20) NOT NULL,
	`IndicePeriodo` int NOT NULL,
	`Balance` Decimal(19,4) NOT NULL,
 /* Name ignored: CONSTRAINT `PK_BalancesMensuales` */ PRIMARY KEY 
(
	`TipoEntidad` ASC,
	`CodigoEntidad` ASC,
	`IndicePeriodo` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[BalancesMensualesMEX]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `BalancesMensualesMEX`(
	`id` int AUTO_INCREMENT NOT NULL,
	`TipoEntidad` nvarchar(3) NOT NULL,
	`CodigoEntidad` nvarchar(20) NOT NULL,
	`IndicePeriodo` int NOT NULL,
	`Balance` Decimal(19,4) NOT NULL,
PRIMARY KEY 
(
	`id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[Bancos]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `Bancos`(
	`Codigo` nvarchar(20) NOT NULL,
	`Cuenta` nvarchar(20) NOT NULL DEFAULT '',
	`Nombre` nvarchar(40) NOT NULL DEFAULT '',
	`Banco` nvarchar(40) NOT NULL DEFAULT '',
	`TipoCuenta` tinyint Unsigned NOT NULL DEFAULT 0,
	`CGCuenta` nvarchar(20) NOT NULL DEFAULT '',
	`SaldoActual` Decimal(19,4) NOT NULL DEFAULT 0,
	`DepositosDiferidos` Decimal(19,4) NOT NULL DEFAULT 0,
	`ChequesPostdatados` Decimal(19,4) NOT NULL DEFAULT 0,
	`UltimaActualizacion` datetime(3) NOT NULL DEFAULT now(3),
	`ProximoCheque` int NOT NULL DEFAULT 0,
	`FechaCreacion` datetime(3) NOT NULL DEFAULT now(3),
	`monedaExtranjera` tinyint Unsigned NOT NULL DEFAULT 0,
	`factorTipoCambio` Double NOT NULL DEFAULT 1,
	`tipoCambioReferencial` Double NOT NULL DEFAULT 1,
	`simboloMoneda` nvarchar(3) NOT NULL DEFAULT 'VES',
	`metodos` tinyint Unsigned NOT NULL DEFAULT 0,
	`emailZelle` nvarchar(64) NOT NULL DEFAULT '',
	`beneficiarioPago` nvarchar(64) NOT NULL DEFAULT '',
	`telefonoPagoMovil` nvarchar(30) NOT NULL DEFAULT '',
	`idPagoMovil` nvarchar(14) NOT NULL DEFAULT '',
	`tipoIGTF` tinyint Unsigned NOT NULL DEFAULT 0,
	`autoRetIGTF` tinyint Unsigned NOT NULL DEFAULT 1,
	`id` int AUTO_INCREMENT NOT NULL,
PRIMARY KEY 
(
	`Codigo` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[BarraItemsPagina]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `BarraItemsPagina`(
	`Pagina` smallint NOT NULL,
	`Posicion` smallint NOT NULL,
	`Codigo` nvarchar(20) NOT NULL,
 /* Name ignored: CONSTRAINT `PK_BarraItemsPagina` */ PRIMARY KEY 
(
	`Pagina` ASC,
	`Posicion` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[BarraPaginas]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `BarraPaginas`(
	`Numero` smallint NOT NULL,
	`Descripcion` nvarchar(32) NOT NULL,
PRIMARY KEY 
(
	`Numero` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[Beneficiarios]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `Beneficiarios`(
	`Nombre` nvarchar(50) NOT NULL,
PRIMARY KEY 
(
	`Nombre` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[chequeDevueltoComis]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `chequeDevueltoComis`(
	`id` int AUTO_INCREMENT NOT NULL,
	`idCheque` int NOT NULL DEFAULT 0,
	`tipoDocRel` nvarchar(3) NOT NULL DEFAULT '',
	`refDocRel` nvarchar(20) NOT NULL DEFAULT '',
	`codigoVendedor` nvarchar(15) NOT NULL DEFAULT '',
	`montoComision` Decimal(19,4) NOT NULL DEFAULT 0,
PRIMARY KEY 
(
	`id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[ChequesDevueltos]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `ChequesDevueltos`(
	`id` int AUTO_INCREMENT NOT NULL,
	`CodigoCliente` nvarchar(20) NOT NULL,
	`Descripcion` nvarchar(50) NOT NULL,
	`FechaDevolucion` datetime(3) NOT NULL,
	`CodigoEmisor` nvarchar(20) NOT NULL,
	`NumeroDocumento` nvarchar(20) NOT NULL,
	`Monto` Decimal(19,4) NOT NULL,
	`MontoPenalizacion` Decimal(19,4) NOT NULL,
	`Saldo` Decimal(19,4) NOT NULL,
PRIMARY KEY 
(
	`id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[CierresZ]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `CierresZ`(
	`NumeroUnico` bigint AUTO_INCREMENT NOT NULL,
	`idTerminal` int NOT NULL DEFAULT 0,
	`Numero` int NOT NULL DEFAULT 0,
	`Apertura` datetime(3) NOT NULL DEFAULT now(3),
	`HoraUltimaOperacion` datetime(3) NOT NULL DEFAULT now(3),
	`qFacturas` int NOT NULL DEFAULT 0,
	`PrimeraFactura` int NOT NULL DEFAULT 0,
	`UltimaFactura` int NOT NULL DEFAULT 0,
	`Turnos` smallint NOT NULL DEFAULT 0,
	`Exento` Decimal(19,4) NOT NULL DEFAULT 0,
	`Servicio` Decimal(19,4) NOT NULL DEFAULT 0,
	`Gravable1` Decimal(19,4) NOT NULL DEFAULT 0,
	`Gravable2` Decimal(19,4) NOT NULL DEFAULT 0,
	`Impuesto1` Decimal(19,4) NOT NULL DEFAULT 0,
	`Impuesto2` Decimal(19,4) NOT NULL DEFAULT 0,
	`IGTFRetenido` Decimal(19,4) NOT NULL DEFAULT 0,
PRIMARY KEY 
(
	`NumeroUnico` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[clasif3]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `clasif3`(
	`codigo` nvarchar(8) NOT NULL,
	`descripcion` nvarchar(30) NOT NULL DEFAULT '',
PRIMARY KEY 
(
	`codigo` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[Clasificaciones]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `Clasificaciones`(
	`Codigo` nvarchar(12) NOT NULL DEFAULT '',
	`Descripcion` nvarchar(40) NOT NULL DEFAULT '',
PRIMARY KEY 
(
	`Codigo` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[Clientes]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `Clientes`(
	`Codigo` nvarchar(20) NOT NULL,
	`Nombre` nvarchar(50) NOT NULL DEFAULT '',
	`Tipo` nvarchar(8) NOT NULL DEFAULT '',
	`RIF` nvarchar(20) NOT NULL DEFAULT '',
	`NIT` nvarchar(12) NULL DEFAULT '',
	`CGCuenta` nvarchar(20) NOT NULL DEFAULT '',
	`CuentaIngresos` nvarchar(20) NOT NULL DEFAULT '',
	`Direccion` nvarchar(160) NOT NULL DEFAULT '',
	`Telefono` nvarchar(30) NOT NULL DEFAULT '',
	`Zona` nvarchar(8) NOT NULL DEFAULT '',
	`Ruta` nvarchar(8) NOT NULL DEFAULT '',
	`Estado` nvarchar(8) NOT NULL DEFAULT '',
	`Municipio` nvarchar(8) NOT NULL DEFAULT '',
	`VendedorAsignado` nvarchar(20) NOT NULL DEFAULT '',
	`CondicionStandard` nvarchar(8) NOT NULL DEFAULT 'CONTADO',
	`PrecioStandard` nvarchar(50) NOT NULL DEFAULT '',
	`SaldoActual` Decimal(19,4) NOT NULL DEFAULT 0,
	`LimiteCredito` Decimal(19,4) NOT NULL DEFAULT 0,
	`Status` tinyint Unsigned NOT NULL DEFAULT 0,
	`FechaUltimaVenta` datetime(3) NOT NULL DEFAULT '20000101',
	`Notas` nvarchar(255) NOT NULL DEFAULT '',
	`FechaCreacion` datetime(3) NOT NULL DEFAULT now(3),
	`Contribuyente` smallint NOT NULL DEFAULT 0,
	`ContribuyenteEspecial` smallint NOT NULL DEFAULT 0,
	`IndicePrecio` smallint NOT NULL DEFAULT 1,
	`PerfilPrecios` nvarchar(12) NOT NULL DEFAULT 'PRECIO1',
	`CuentaME` smallint NOT NULL DEFAULT 0,
	`Latitud` Double NOT NULL DEFAULT 0,
	`Longitud` Double NOT NULL DEFAULT 0,
	`email` nvarchar(120) NOT NULL DEFAULT '',
	`ID` int AUTO_INCREMENT NOT NULL,
PRIMARY KEY 
(
	`Codigo` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[Cobranzas]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `Cobranzas`(
	`id` bigint AUTO_INCREMENT NOT NULL,
	`sesion` int NOT NULL,
	`idOperador` nvarchar(8) NOT NULL,
	`codVend` nvarchar(20) NOT NULL,
	`codCli` nvarchar(20) NOT NULL,
	`Fecha` datetime(3) NOT NULL,
	`tipoDoc` nvarchar(3) NOT NULL,
	`numDoc` int NOT NULL,
	`MontoCobrado` Decimal(19,4) NOT NULL DEFAULT 0,
	`MontoNeto` Decimal(19,4) NOT NULL DEFAULT 0,
	`RetencionIVA` Decimal(19,4) NOT NULL DEFAULT 0,
	`RetencionISLR` Decimal(19,4) NOT NULL DEFAULT 0,
	`NetoFacturas` Decimal(19,4) NOT NULL DEFAULT 0,
	`IVACobrado` Decimal(19,4) NOT NULL DEFAULT 0,
	`Descuentos` Decimal(19,4) NOT NULL DEFAULT 0,
	`Descripcion` nvarchar(50) NOT NULL,
PRIMARY KEY 
(
	`id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[CobrosPOS]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `CobrosPOS`(
	`ID` int AUTO_INCREMENT NOT NULL,
	`SessionID` int NOT NULL DEFAULT 0,
	`Hora` datetime(3) NOT NULL DEFAULT now(3),
	`CodigoCliente` nvarchar(20) NOT NULL DEFAULT '',
	`Descripcion` nvarchar(50) NOT NULL DEFAULT '',
	`Monto` Decimal(19,4) NOT NULL DEFAULT 0,
PRIMARY KEY 
(
	`ID` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[CobrosPostdatados]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `CobrosPostdatados`(
	`Numero` int AUTO_INCREMENT NOT NULL,
	`CodigoCliente` nvarchar(20) NOT NULL,
	`CodigoVendedor` nvarchar(15) NOT NULL,
	`FechaPresentacion` datetime(3) NOT NULL,
	`Descripcion` nvarchar(50) NOT NULL,
	`FechaRegistro` datetime(3) NOT NULL DEFAULT now(3),
PRIMARY KEY 
(
	`Numero` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[CobrosPostdatadosDetalles]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `CobrosPostdatadosDetalles`(
	`Numero` int AUTO_INCREMENT NOT NULL,
	`idCobro` int NOT NULL,
	`TotalAbono` Decimal(19,4) NOT NULL,
	`ValorRecibido` Decimal(19,4) NOT NULL,
	`RetencionIVA` Decimal(19,4) NOT NULL,
	`ComprobanteRetencion` Decimal(19,4) NOT NULL,
	`FechaRetencion` datetime(3) NOT NULL,
	`RetencionISLR` Decimal(19,4) NOT NULL,
	`NumeroComprobanteISLR` int NOT NULL,
	`MontoDescuento` Decimal(19,4) NOT NULL,
	`NumeroControlNC` nvarchar(16) NOT NULL,
	`NumDoc` int NOT NULL,
	`TipoDoc` nvarchar(3) NULL,
PRIMARY KEY 
(
	`Numero` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[CobrosPostdatadosMedios]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `CobrosPostdatadosMedios`(
	`Numero` bigint AUTO_INCREMENT NOT NULL,
	`idCobro` int NOT NULL,
	`Detalle` nvarchar(1024) NOT NULL,
PRIMARY KEY 
(
	`Numero` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[ColaVendedores]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `ColaVendedores`(
	`Id` bigint AUTO_INCREMENT NOT NULL,
	`CodigoVendedor` nvarchar(3) NULL,
	`UltimoServicio` datetime(3) NULL DEFAULT now(3),
PRIMARY KEY 
(
	`Id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[Competencia]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `Competencia`(
	`CodigoItem` nvarchar(20) NOT NULL DEFAULT '',
	`Establecimiento` nvarchar(50) NOT NULL DEFAULT '',
	`Precio` Decimal(19,4) NOT NULL DEFAULT 0,
 /* Name ignored: CONSTRAINT `PK_Competencia` */ PRIMARY KEY 
(
	`CodigoItem` ASC,
	`Establecimiento` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[ComposicionItemsInventario]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `ComposicionItemsInventario`(
	`CodigoItemVenta` nvarchar(20) NOT NULL,
	`CodigoItemInventario` nvarchar(20) NOT NULL,
	`Cantidad` Double NOT NULL,
 /* Name ignored: CONSTRAINT `PK_ComposicionItemsInventario` */ PRIMARY KEY 
(
	`CodigoItemInventario` ASC,
	`CodigoItemVenta` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[ComposicionItemsVenta]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `ComposicionItemsVenta`(
	`CodigoItemVenta` nvarchar(20) NOT NULL,
	`CodigoItemInventario` nvarchar(20) NOT NULL,
	`Cantidad` Double NOT NULL,
 /* Name ignored: CONSTRAINT `PK_ComposicionItemsVenta` */ PRIMARY KEY 
(
	`CodigoItemInventario` ASC,
	`CodigoItemVenta` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[Compras]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `Compras`(
	`Numero` int NOT NULL DEFAULT 0,
	`FechaRegistro` datetime(3) NOT NULL DEFAULT now(3),
	`FechaTransaccion` datetime(3) NOT NULL DEFAULT now(3),
	`FechaEmision` datetime(3) NOT NULL DEFAULT now(3),
	`Operador` nvarchar(8) NOT NULL DEFAULT '',
	`CodigoProveedor` nvarchar(20) NOT NULL DEFAULT '',
	`RefProveedor` nvarchar(20) NOT NULL DEFAULT '',
	`NombreProveedor` nvarchar(50) NOT NULL DEFAULT '',
	`CostoMercancia` Decimal(19,4) NOT NULL DEFAULT 0,
	`Descuento1` Double NOT NULL DEFAULT 0,
	`Descuento2` Double NOT NULL DEFAULT 0,
	`Impuesto1` Decimal(19,4) NOT NULL DEFAULT 0,
	`Impuesto2` Decimal(19,4) NOT NULL DEFAULT 0,
	`Almacen` nvarchar(8) NOT NULL DEFAULT '',
	`EstadoRecepcion` smallint NOT NULL DEFAULT 0,
	`EstadoAdministrativo` smallint NOT NULL DEFAULT 0,
	`Condicion` nvarchar(12) NOT NULL DEFAULT 'C00',
	`Notas` nvarchar(255) NOT NULL DEFAULT '',
	`Saldo` Decimal(19,4) NOT NULL DEFAULT 0,
	`NumeroControl` int NOT NULL DEFAULT 0,
	`Diferencia` Decimal(19,4) NOT NULL DEFAULT 0,
	`TipoCambio` Decimal(19,4) NOT NULL DEFAULT 0,
	`TiempoRespuesta` smallint NOT NULL DEFAULT 0,
PRIMARY KEY 
(
	`Numero` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[Comprobantes]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `Comprobantes`(
	`NumeroComprobante` int NOT NULL,
	`Periodo` bigint NOT NULL,
	`CorrelativoPeriodo` bigint NOT NULL,
	`Referencia` nvarchar(30) NOT NULL DEFAULT '',
	`Descripcion` nvarchar(50) NOT NULL DEFAULT '',
	`Autor` nvarchar(8) NULL DEFAULT '',
	`Fecha` datetime(3) NOT NULL DEFAULT now(3),
	`Debitos` Double NOT NULL DEFAULT 0,
	`Creditos` Double NOT NULL DEFAULT 0,
	`Modificado` datetime(3) NOT NULL DEFAULT now(3),
	`documentoOrigen` nvarchar(3) NOT NULL DEFAULT '',
	`numeroDocumentoOrigen` int NOT NULL DEFAULT 0,
PRIMARY KEY 
(
	`NumeroComprobante` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[ComprobantesAlmacen]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `ComprobantesAlmacen`(
	`Numero` int NOT NULL,
	`Almacen` nvarchar(8) NOT NULL DEFAULT '',
	`Operador` nvarchar(8) NOT NULL DEFAULT '',
	`FechaRegistro` datetime(3) NOT NULL DEFAULT now(3),
	`FechaTransaccion` datetime(3) NOT NULL DEFAULT now(3),
	`TipoEntidadOrigen` nvarchar(3) NOT NULL DEFAULT '',
	`NumeroDocumentoOrigen` int NOT NULL DEFAULT 0,
	`OrdenDespacho` int NOT NULL DEFAULT 0,
	`Descripcion` nvarchar(50) NOT NULL DEFAULT '',
	`ValorMN` Decimal(19,4) NOT NULL DEFAULT 0,
	`ValorUSD` Decimal(19,4) NOT NULL DEFAULT 0,
	`TipoCambio` Double NOT NULL DEFAULT 1,
PRIMARY KEY 
(
	`Numero` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[Conciliaciones]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `Conciliaciones`(
	`Id` int AUTO_INCREMENT NOT NULL,
	`CodigoBanco` nvarchar(20) NOT NULL DEFAULT '',
	`FechaEC` datetime(3) NOT NULL,
	`SaldoBanco` Decimal(19,4) NOT NULL DEFAULT 0,
	`NuestroSaldo` Decimal(19,4) NOT NULL DEFAULT 0,
	`ChequesEnTransito` Decimal(19,4) NOT NULL DEFAULT 0,
	`OtrosMovimientos` Decimal(19,4) NOT NULL DEFAULT 0,
	`Diferencias` Decimal(19,4) NOT NULL DEFAULT 0,
PRIMARY KEY 
(
	`Id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[Condiciones]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `Condiciones`(
	`Codigo` nvarchar(12) NOT NULL,
	`Descripcion` nvarchar(40) NOT NULL DEFAULT '',
	`Modo` tinyint Unsigned NOT NULL DEFAULT 0,
	`CuentaIngresos` nvarchar(20) NOT NULL DEFAULT '',
	`nCuotas` smallint NOT NULL DEFAULT 1,
	`intervalo` nvarchar(4) NOT NULL DEFAULT 'd',
PRIMARY KEY 
(
	`Codigo` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[CondicVen]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `CondicVen`(
	`CodigoCondicion` nvarchar(12) NOT NULL DEFAULT '',
	`Correlativo` smallint NOT NULL DEFAULT 0,
	`Plazo` smallint NOT NULL DEFAULT 0,
	`Porcentaje` Double NOT NULL DEFAULT 0,
 /* Name ignored: CONSTRAINT `PK_CondicVen` */ PRIMARY KEY 
(
	`CodigoCondicion` ASC,
	`Correlativo` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[ConsignacionesCompra]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `ConsignacionesCompra`(
	`Numero` bigint AUTO_INCREMENT NOT NULL,
	`FechaRegistro` datetime(3) NOT NULL DEFAULT now(3),
	`FechaTransaccion` datetime(3) NOT NULL,
	`Operador` nvarchar(8) NOT NULL DEFAULT '',
	`CodigoProveedor` nvarchar(20) NOT NULL DEFAULT '',
	`RefProveedor` nvarchar(20) NOT NULL DEFAULT '',
	`CostoMercancia` Decimal(19,4) NOT NULL DEFAULT 0,
	`Descuento1` Double NOT NULL DEFAULT 0,
	`Descuento2` Double NOT NULL DEFAULT 0,
	`Impuesto1` Decimal(19,4) NOT NULL DEFAULT 0,
	`Impuesto2` Decimal(19,4) NOT NULL DEFAULT 0,
	`Almacen` nvarchar(8) NOT NULL DEFAULT '',
	`Liquidada` smallint NOT NULL DEFAULT 0,
	`Procesada` smallint NOT NULL DEFAULT 0,
	`Notas` nvarchar(255) NOT NULL DEFAULT '',
	`TipoCambio` Double NOT NULL DEFAULT 1,
PRIMARY KEY 
(
	`Numero` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[ConsignacionesDetalles]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `ConsignacionesDetalles`(
	`NumeroConsignacion` bigint NOT NULL,
	`Renglon` smallint NOT NULL,
	`CodigoItem` nvarchar(20) NULL,
	`Presentacion` nvarchar(12) NULL,
	`FactorEmpaque` Double NOT NULL,
	`CantidadRecibida` Double NOT NULL,
	`PrecioEfectivo` Decimal(19,4) NOT NULL,
	`Pendientes` Double NOT NULL,
	`Piezas` Double NOT NULL DEFAULT 0,
 /* Name ignored: CONSTRAINT `PK_ConsignacionesDetalles` */ PRIMARY KEY 
(
	`NumeroConsignacion` ASC,
	`Renglon` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[Contactos]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `Contactos`(
	`CodigoEntidad` nvarchar(20) NOT NULL,
	`TipoEntidad` nvarchar(3) NOT NULL,
	`NombreContacto` nvarchar(50) NOT NULL,
	`Departamento` nvarchar(30) NOT NULL DEFAULT '',
	`Cargo` nvarchar(30) NOT NULL DEFAULT '',
	`Direccion` nvarchar(160) NOT NULL DEFAULT '',
	`Telefono` nvarchar(30) NOT NULL DEFAULT '',
	`TelefonoCelular` nvarchar(20) NOT NULL DEFAULT '',
	`FAX` nvarchar(20) NOT NULL DEFAULT '',
	`eMail` nvarchar(30) NOT NULL DEFAULT '',
	`Notas` nvarchar(255) NOT NULL DEFAULT ''
);
/* SQLINES DEMO *** able [dbo].[Contadores]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `Contadores`(
	`Factura` int NOT NULL DEFAULT 1,
	`NotaEntrega` int NOT NULL DEFAULT 1,
	`Cotizacion` int NOT NULL DEFAULT 1,
	`DevolucionVenta` int NOT NULL DEFAULT 1,
	`Compra` int NOT NULL DEFAULT 1,
	`OrdenCompra` int NOT NULL DEFAULT 1,
	`DevolucionCompra` int NOT NULL DEFAULT 1,
	`Ajuste` int NOT NULL DEFAULT 1,
	`Transferencia` int NOT NULL DEFAULT 1,
	`NotaDBCR` int NOT NULL DEFAULT 1,
	`Apertura` datetime(3) NOT NULL DEFAULT now(3),
	`Clave` int NOT NULL DEFAULT 0,
	`Status` Decimal(19,4) NOT NULL DEFAULT 0,
	`Operacion` int NOT NULL DEFAULT 0,
	`NotaFiscal` int NOT NULL DEFAULT 0,
	`RetencionISLR` int NOT NULL DEFAULT 0,
	`ProximaRelacionIR` bigint NOT NULL DEFAULT 1,
	`ProximoDocumentoISPC` int NOT NULL DEFAULT 1,
	`FechaUltimoUso` datetime(3) NOT NULL DEFAULT now(3),
	`adelantoEfectivo` int NOT NULL DEFAULT 1,
	`ProximoComprobanteAlmacen` int NOT NULL DEFAULT 0,
	`lastUpdate` bigint NOT NULL DEFAULT 0
);
/* SQLINES DEMO *** able [dbo].[controlMesasSesion]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `controlMesasSesion`(
	`idSesion` int NOT NULL DEFAULT 0,
	`nCuentasInicial` smallint NOT NULL DEFAULT 0,
	`montoCuentasInicial` Decimal(19,4) NOT NULL DEFAULT 0,
	`nCuentasAbiertas` smallint NOT NULL DEFAULT 0,
	`montoCargado` Decimal(19,4) NOT NULL DEFAULT 0,
	`nCuentasEliminadas` smallint NOT NULL DEFAULT 0,
	`montoEliminado` Decimal(19,4) NOT NULL DEFAULT 0,
	`nTransferencias` smallint NOT NULL DEFAULT 0,
	`montoTransferencias` Decimal(19,4) NOT NULL DEFAULT 0,
	`nCuentasPendientes` smallint NOT NULL DEFAULT 0,
	`montoCuentasPendientes` Decimal(19,4) NOT NULL DEFAULT 0,
	`nCerradas` smallint NOT NULL DEFAULT 0,
	`montoCerrado` Decimal(19,4) NOT NULL DEFAULT 0,
PRIMARY KEY 
(
	`idSesion` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[CorrelativosMaquina]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `CorrelativosMaquina`(
	`Maquina` int NOT NULL,
	`ProximaFactura` int NOT NULL DEFAULT 1,
	`ProximaNC` int NOT NULL DEFAULT 1,
	`serialPF` nvarchar(14) NOT NULL DEFAULT '',
	`Descripcion` nvarchar(20) NOT NULL DEFAULT '',
PRIMARY KEY 
(
	`Maquina` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[Cotizaciones]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `Cotizaciones`(
	`Numero` int NOT NULL,
	`FechaRegistro` datetime(3) NOT NULL DEFAULT now(3),
	`FechaTransaccion` datetime(3) NOT NULL DEFAULT now(3),
	`Operador` nvarchar(8) NOT NULL DEFAULT '',
	`CodigoCliente` nvarchar(20) NOT NULL DEFAULT '',
	`NombreCliente` nvarchar(50) NOT NULL DEFAULT '',
	`CodigoVendedor` nvarchar(15) NOT NULL DEFAULT '',
	`PrecioLista` Decimal(19,4) NOT NULL DEFAULT 0,
	`PrecioVenta` Decimal(19,4) NOT NULL DEFAULT 0,
	`PrecioEfectivo` Decimal(19,4) NOT NULL DEFAULT 0,
	`Impuesto1` Decimal(19,4) NOT NULL DEFAULT 0,
	`Impuesto2` Decimal(19,4) NOT NULL DEFAULT 0,
	`IndiceReferencia` smallint NOT NULL DEFAULT 0,
	`IndiceVenta` smallint NOT NULL DEFAULT 0,
	`Descuento1` Double NOT NULL DEFAULT 0,
	`Descuento2` Double NOT NULL DEFAULT 0,
	`Condicion` nvarchar(8) NULL DEFAULT '',
	`Notas` nvarchar(255) NULL DEFAULT '',
	`Estado` smallint NOT NULL DEFAULT 0,
	`Almacen` nvarchar(8) NOT NULL DEFAULT '',
	`TipoCambio` Double NOT NULL DEFAULT 1,
PRIMARY KEY 
(
	`Numero` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[CotizacionesDetalles]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `CotizacionesDetalles`(
	`NumeroDocumento` int NOT NULL,
	`Renglon` smallint NOT NULL,
	`CodigoItem` nvarchar(20) NOT NULL DEFAULT '',
	`Descripcion` nvarchar(50) NOT NULL DEFAULT '',
	`Presentacion` nvarchar(12) NOT NULL DEFAULT '',
	`FactorEmpaque` Double NOT NULL DEFAULT 0,
	`Cantidad` Double NOT NULL DEFAULT 0,
	`PrecioLista` Decimal(19,4) NOT NULL DEFAULT 0,
	`PrecioVenta` Decimal(19,4) NOT NULL DEFAULT 0,
	`PrecioEfectivo` Decimal(19,4) NOT NULL DEFAULT 0,
	`Impuesto1` Double NOT NULL DEFAULT 0,
	`Impuesto2` Double NOT NULL DEFAULT 0,
	`CostoUnitario` Decimal(19,4) NOT NULL DEFAULT 0,
	`CantidadFacturada` Double NOT NULL DEFAULT 0,
	`Ancho` Double NOT NULL DEFAULT 0,
	`Alto` Double NOT NULL DEFAULT 0,
	`Largo` Double NOT NULL DEFAULT 0,
	`Descuentos` nvarchar(10) NOT NULL DEFAULT '',
 /* Name ignored: CONSTRAINT `PK_CotizacionesDetalles` */ PRIMARY KEY 
(
	`NumeroDocumento` ASC,
	`Renglon` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[CotizacionesEntregas]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `CotizacionesEntregas`(
	`NumeroCotizacion` int NOT NULL DEFAULT 0,
	`NumeroRenglon` smallint NOT NULL DEFAULT 0,
	`Fecha` datetime(3) NOT NULL DEFAULT now(3),
	`CodigoItem` nvarchar(20) NOT NULL DEFAULT '',
	`Cantidad` Double NOT NULL DEFAULT 0,
	`PrecioUnitario` Decimal(19,4) NOT NULL DEFAULT 0,
	`Unidad` nvarchar(12) NOT NULL DEFAULT 0,
	`Factor` Double NOT NULL DEFAULT 0,
	`TipoDocumento` nvarchar(5) NOT NULL DEFAULT '',
	`NumeroDocumento` int NOT NULL DEFAULT 0
);
/* SQLINES DEMO *** able [dbo].[Cuentas]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `Cuentas`(
	`Codigo` nvarchar(20) NOT NULL,
	`Titulo` nvarchar(50) NOT NULL DEFAULT '',
	`Status` tinyint Unsigned NOT NULL DEFAULT 0,
	`Lado` smallint NOT NULL DEFAULT 0,
	`Saldo` Double NOT NULL DEFAULT 0,
	`Alterno` nvarchar(20) NOT NULL DEFAULT '',
PRIMARY KEY 
(
	`Codigo` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[CuentasPOS]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `CuentasPOS`(
	`IdCuenta` int AUTO_INCREMENT NOT NULL,
	`tipo` tinyint Unsigned NOT NULL DEFAULT 0,
	`ownerID` int NOT NULL DEFAULT 0,
	`CodigoCuenta` nvarchar(20) NOT NULL DEFAULT '',
	`HoraApertura` datetime(3) NOT NULL DEFAULT now(3),
	`HoraUltimaTransaccion` datetime(3) NOT NULL DEFAULT now(3),
	`Vendedor` nvarchar(20) NOT NULL DEFAULT '',
	`Estado` smallint NOT NULL DEFAULT 0,
	`Personas` int NOT NULL DEFAULT 1,
	`Cliente` nvarchar(20) NOT NULL DEFAULT '',
	`Ambiente` nvarchar(16) NOT NULL DEFAULT '',
	`idMesa` int NOT NULL DEFAULT 0,
	`Condiciones` nvarchar(12) NULL DEFAULT '',
	`Extra` nvarchar(12) NOT NULL DEFAULT '',
	`Bloqueada` tinyint Unsigned NOT NULL DEFAULT 0,
	`horaBloqueo` datetime(3) NOT NULL DEFAULT now(3),
	`Correlativo` int NOT NULL DEFAULT 0,
	`codigoDescuento` nvarchar(12) NOT NULL DEFAULT '',
	`autorizadoDescuento` nvarchar(12) NOT NULL DEFAULT '',
	`explicacionDescuento` nvarchar(80) NOT NULL DEFAULT '',
	`porcentajeDescuento` Double NOT NULL DEFAULT 0,
	`TipoCambio` Double NOT NULL DEFAULT 1,
PRIMARY KEY 
(
	`IdCuenta` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[cvCaja]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `cvCaja`(
	`id` int AUTO_INCREMENT NOT NULL,
	`machineID` int NOT NULL,
	`efectivoMN` Decimal(19,4) NOT NULL,
PRIMARY KEY 
(
	`id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[CVcajaDetalles]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `CVcajaDetalles`(
	`id` bigint AUTO_INCREMENT NOT NULL,
	`idCEC` int NOT NULL DEFAULT 0,
	`codigoMedio` nvarchar(8) NOT NULL DEFAULT '',
	`valorMN` Decimal(19,4) NOT NULL DEFAULT 0,
	`valorNominal` Decimal(19,4) NOT NULL DEFAULT 0,
PRIMARY KEY 
(
	`id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[descripcionRCP]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `descripcionRCP`(
	`idRenglon` bigint NOT NULL,
	`descripcion` nvarchar(60) NOT NULL DEFAULT '',
PRIMARY KEY 
(
	`idRenglon` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[descripcionRFP]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `descripcionRFP`(
	`idMaquina` int NOT NULL,
	`numeroTicket` int NOT NULL,
	`numeroLinea` smallint NOT NULL,
	`descripcion` nvarchar(60) NOT NULL DEFAULT '',
 /* Name ignored: CONSTRAINT `PK_descripcionRFP` */ PRIMARY KEY 
(
	`idMaquina` ASC,
	`numeroTicket` ASC,
	`numeroLinea` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[descripcionRS]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `descripcionRS`(
	`SessionID` int NOT NULL,
	`NumeroRenglon` smallint NOT NULL,
	`Descripcion` nvarchar(60) NOT NULL DEFAULT '',
 /* Name ignored: CONSTRAINT `PK_descripcionRS` */ PRIMARY KEY 
(
	`SessionID` ASC,
	`NumeroRenglon` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[DescuentosSesion]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `DescuentosSesion`(
	`id` int AUTO_INCREMENT NOT NULL,
	`sesion` int NOT NULL,
	`codigoMotivo` nvarchar(12) NOT NULL DEFAULT 'ERROR',
	`autorizadoDescuento` nvarchar(12) NOT NULL DEFAULT 'ERROR',
	`explicacionDescuento` nvarchar(80) NOT NULL DEFAULT 'ERROR',
	`porcentajeDescuento` Double NOT NULL DEFAULT 0,
	`Hora` datetime(3) NOT NULL DEFAULT now(3),
	`numeroTicket` int NOT NULL DEFAULT 0,
	`caja` int NOT NULL DEFAULT 0,
	`valorOriginal` Decimal(19,4) NOT NULL DEFAULT 0,
	`valorFinal` Decimal(19,4) NOT NULL DEFAULT 0,
PRIMARY KEY 
(
	`id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[Detalles]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `Detalles`(
	`NumeroComprobante` int NOT NULL DEFAULT '',
	`NumeroLinea` smallint NOT NULL DEFAULT '',
	`RefPeriodo` int NOT NULL DEFAULT 0,
	`Cuenta` nvarchar(20) NOT NULL DEFAULT '',
	`RefDetalle` nvarchar(50) NULL DEFAULT '',
	`Descripcion` nvarchar(50) NULL DEFAULT '',
	`Debe` Double NOT NULL DEFAULT 0,
	`Haber` Double NOT NULL DEFAULT 0,
 /* Name ignored: CONSTRAINT `PK_Detalles` */ PRIMARY KEY 
(
	`NumeroComprobante` ASC,
	`NumeroLinea` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[DetallesAnulacionPOS]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `DetallesAnulacionPOS`(
	`idDetalle` bigint AUTO_INCREMENT NOT NULL,
	`numDevol` int NOT NULL DEFAULT 0,
	`Producto` nvarchar(20) NOT NULL DEFAULT '',
	`Cantidad` Double NOT NULL DEFAULT 0,
	`PrecioUnitario` Decimal(19,4) NOT NULL DEFAULT 0,
	`PorcentajeImpuesto` Double NOT NULL DEFAULT 0,
	`Usuario` nvarchar(20) NOT NULL DEFAULT '',
PRIMARY KEY 
(
	`idDetalle` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[DetallesCobranza]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `DetallesCobranza`(
	`id` bigint AUTO_INCREMENT NOT NULL,
	`NumeroCobranza` bigint NOT NULL,
	`NumeroDoc` int NOT NULL,
	`TipoDoc` nvarchar(3) NOT NULL,
	`MontoCobrado` Decimal(19,4) NOT NULL DEFAULT 0,
	`MontoNeto` Decimal(19,4) NOT NULL DEFAULT 0,
	`RetencionIVA` Decimal(19,4) NOT NULL DEFAULT 0,
	`RetencionISLR` Decimal(19,4) NOT NULL DEFAULT 0,
	`NetoFacturas` Decimal(19,4) NOT NULL DEFAULT 0,
	`IVACobrado` Decimal(19,4) NOT NULL DEFAULT 0,
	`Descuentos` Decimal(19,4) NOT NULL DEFAULT 0,
PRIMARY KEY 
(
	`id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[DetallesCompra]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `DetallesCompra`(
	`NumeroDocumento` int NOT NULL DEFAULT 0,
	`Renglon` smallint NOT NULL DEFAULT 0,
	`CodigoItem` nvarchar(20) NOT NULL DEFAULT '',
	`Descripcion` nvarchar(50) NULL DEFAULT '',
	`Presentacion` nvarchar(12) NOT NULL DEFAULT '',
	`FactorEmpaque` Double NOT NULL DEFAULT 0,
	`CantidadFacturada` Double NOT NULL DEFAULT 0,
	`CantidadPromocion` Double NOT NULL DEFAULT 0,
	`PrecioNominal` Decimal(19,4) NOT NULL DEFAULT 0,
	`PrecioEfectivo` Decimal(19,4) NOT NULL DEFAULT 0,
	`Impuesto1` Double NOT NULL DEFAULT 0,
	`Impuesto2` Double NOT NULL DEFAULT 0,
	`CostoUnitario` Decimal(19,4) NOT NULL DEFAULT 0,
	`Recibidas` Double NOT NULL DEFAULT 0,
	`Almacen` nvarchar(8) NULL DEFAULT '',
	`Devueltas` Double NOT NULL DEFAULT 0,
	`Recargos` Decimal(19,4) NOT NULL DEFAULT 0,
	`Piezas` Double NOT NULL DEFAULT 0,
 /* Name ignored: CONSTRAINT `PK_DetallesCompra` */ PRIMARY KEY 
(
	`NumeroDocumento` ASC,
	`Renglon` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[DetallesCuentaEntidad]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `DetallesCuentaEntidad`(
	`CodigoEntidad` nvarchar(20) NOT NULL DEFAULT '',
	`TipoEntidad` nvarchar(3) NOT NULL DEFAULT '',
	`Correlativo` int NOT NULL DEFAULT 0,
	`Documento` int NOT NULL DEFAULT 0,
	`Fecha` datetime(3) NOT NULL DEFAULT now(3),
	`RefPeriodo` int NOT NULL DEFAULT 0,
	`Descripcion` nvarchar(60) NULL DEFAULT '',
	`Debe` Decimal(19,4) NOT NULL DEFAULT 0,
	`Haber` Decimal(19,4) NOT NULL DEFAULT 0,
	`TipoDocOrigen` nvarchar(3) NOT NULL DEFAULT '',
	`NumeroDocOrigen` int NOT NULL DEFAULT 0,
	`TipoCambio` Double NOT NULL DEFAULT 1,
 /* Name ignored: CONSTRAINT `PK_DetallesCuentaEntidad` */ PRIMARY KEY 
(
	`CodigoEntidad` ASC,
	`TipoEntidad` ASC,
	`Correlativo` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[DetallesDenominacion]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `DetallesDenominacion`(
	`Id` int AUTO_INCREMENT NOT NULL,
	`IdDetalle` int NOT NULL DEFAULT 0,
	`Denominacion` Decimal(19,4) NOT NULL DEFAULT 0,
	`CantidadRecibida` smallint NOT NULL DEFAULT 0,
PRIMARY KEY 
(
	`Id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[DetallesDevolucionCompra]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `DetallesDevolucionCompra`(
	`numeroDevolucion` int NOT NULL DEFAULT 0,
	`numeroRenglon` smallint NOT NULL DEFAULT 0,
	`codigoItem` nvarchar(20) NOT NULL DEFAULT '',
	`cantidadDevuelta` Double NOT NULL DEFAULT 0,
	`presentacion` nvarchar(12) NOT NULL DEFAULT '',
	`factorEmpaque` Double NOT NULL DEFAULT 0,
	`descripcionItem` nvarchar(50) NOT NULL DEFAULT '',
	`costo` Decimal(19,4) NOT NULL DEFAULT 0,
	`danhada` smallint NOT NULL DEFAULT 0,
	`Piezas` Double NOT NULL DEFAULT 0,
 /* Name ignored: CONSTRAINT `PK_DetallesDevolucionCompra` */ PRIMARY KEY 
(
	`numeroDevolucion` ASC,
	`numeroRenglon` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[DetallesDevolucionVenta]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `DetallesDevolucionVenta`(
	`NumeroDevolucion` int NOT NULL DEFAULT 0,
	`NumeroRenglon` smallint NOT NULL DEFAULT 0,
	`CodigoItemVenta` nvarchar(20) NOT NULL DEFAULT '',
	`CantidadDevuelta` Double NOT NULL DEFAULT 0,
	`Presentacion` nvarchar(12) NOT NULL DEFAULT '',
	`FactorEmpaque` Double NOT NULL DEFAULT 0,
	`DescripcionItem` nvarchar(50) NOT NULL DEFAULT '',
	`Valor` Decimal(19,4) NOT NULL DEFAULT 0,
	`Costo` Decimal(19,4) NOT NULL DEFAULT 0,
	`Danhada` smallint NOT NULL DEFAULT 0,
	`Piezas` Double NOT NULL DEFAULT 0,
 /* Name ignored: CONSTRAINT `PK_DetallesDevolucionVenta` */ PRIMARY KEY 
(
	`NumeroDevolucion` ASC,
	`NumeroRenglon` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[detallesDocFis]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `detallesDocFis`(
	`Id` bigint AUTO_INCREMENT NOT NULL,
	`docId` bigint NOT NULL,
	`codigoTipo` nvarchar(3) NOT NULL,
	`base` Decimal(19,4) NOT NULL,
	`porcentaje` Double NOT NULL,
	`impuesto` Decimal(19,4) NOT NULL,
PRIMARY KEY 
(
	`Id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[DetallesFactura]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `DetallesFactura`(
	`NumeroDocumento` int NOT NULL DEFAULT 0,
	`Renglon` smallint NOT NULL DEFAULT 0,
	`CodigoItem` nvarchar(20) NOT NULL DEFAULT '',
	`Descripcion` nvarchar(50) NOT NULL DEFAULT '',
	`Presentacion` nvarchar(12) NOT NULL DEFAULT '',
	`FactorEmpaque` Double NOT NULL DEFAULT 0,
	`Cantidad` Double NOT NULL DEFAULT 0,
	`PrecioLista` Decimal(19,4) NOT NULL DEFAULT 0,
	`PrecioVenta` Decimal(19,4) NOT NULL DEFAULT 0,
	`PrecioEfectivo` Decimal(19,4) NOT NULL DEFAULT 0,
	`Impuesto1` Double NOT NULL DEFAULT 0,
	`Impuesto2` Double NOT NULL DEFAULT 0,
	`CostoUnitario` Decimal(19,4) NOT NULL DEFAULT 0,
	`Entregadas` Double NOT NULL DEFAULT 0,
	`Asignadas` Double NOT NULL DEFAULT 0,
	`Transito` Double NOT NULL DEFAULT 0,
	`Devueltas` Double NOT NULL DEFAULT 0,
	`Piezas` Double NOT NULL DEFAULT 0,
 /* Name ignored: CONSTRAINT `PK_DetallesFactura` */ PRIMARY KEY 
(
	`NumeroDocumento` ASC,
	`Renglon` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[DetallesIngresoCaja]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `DetallesIngresoCaja`(
	`id` int AUTO_INCREMENT NOT NULL,
	`TransID` int NOT NULL DEFAULT 0,
	`Medio` nvarchar(8) NOT NULL DEFAULT '',
	`Emisor` nvarchar(20) NOT NULL DEFAULT '',
	`NumeroDocumento` nvarchar(20) NULL DEFAULT '',
	`ClaveAutorizacion` nvarchar(6) NULL DEFAULT '',
	`Monto` Decimal(19,4) NOT NULL DEFAULT 0,
	`NumeroCuenta` nvarchar(20) NOT NULL DEFAULT '',
	`idTitular` nvarchar(20) NOT NULL DEFAULT '',
	`MontoNominal` Decimal(19,4) NOT NULL DEFAULT 0,
PRIMARY KEY 
(
	`id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[DetallesItemVenta]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `DetallesItemVenta`(
	`NumeroDocumento` int NOT NULL DEFAULT 0,
	`TipoDocumento` nvarchar(3) NOT NULL DEFAULT '???',
	`Serie` nvarchar(3) NULL DEFAULT '',
	`FechaOperacion` datetime(3) NOT NULL DEFAULT now(3),
	`CodigoItem` nvarchar(20) NOT NULL DEFAULT '',
	`CodigoCliente` nvarchar(20) NOT NULL DEFAULT '',
	`CodigoVendedor` nvarchar(20) NULL DEFAULT '',
	`PrecioReferencia` Decimal(19,4) NOT NULL DEFAULT 0,
	`PrecioVenta` Decimal(19,4) NOT NULL DEFAULT 0,
	`Cantidad` Double NOT NULL DEFAULT 0,
	`CostoStandard` Decimal(19,4) NOT NULL DEFAULT 0
);
/* SQLINES DEMO *** able [dbo].[detallesPerfilPrecio]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `detallesPerfilPrecio`(
	`idDetalle` int AUTO_INCREMENT NOT NULL,
	`codigoPerfil` nvarchar(12) NOT NULL,
	`valorInicial` nvarchar(20) NOT NULL,
	`valorFinal` nvarchar(20) NOT NULL,
	`pDesc` Double NOT NULL,
PRIMARY KEY 
(
	`idDetalle` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[detallesSES]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `detallesSES`(
	`id` int AUTO_INCREMENT NOT NULL,
	`owner` int NOT NULL,
	`codigoMedio` nvarchar(8) NOT NULL,
	`valorMN` Decimal(19,4) NOT NULL,
	`valorNominal` Decimal(19,4) NOT NULL,
PRIMARY KEY 
(
	`id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[DetallesTA]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `DetallesTA`(
	`NumeroAjuste` int NOT NULL,
	`NumeroRenglon` smallint NOT NULL,
	`CodigoItem` nvarchar(20) NOT NULL,
	`Cantidad` Double NOT NULL,
	`Unidad` nvarchar(12) NOT NULL,
	`Piezas` Double NOT NULL DEFAULT 0,
 /* Name ignored: CONSTRAINT `PK_DetallesTA` */ PRIMARY KEY 
(
	`NumeroAjuste` ASC,
	`NumeroRenglon` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[DevolucionesCompra]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `DevolucionesCompra`(
	`Numero` int NOT NULL DEFAULT 0,
	`FechaRegistro` datetime(3) NOT NULL DEFAULT now(3),
	`FechaTransaccion` datetime(3) NOT NULL DEFAULT now(3),
	`Operador` nvarchar(8) NOT NULL DEFAULT '',
	`CodigoProveedor` nvarchar(20) NOT NULL DEFAULT '',
	`Factura` int NOT NULL DEFAULT 0,
	`ValorMercancia` Decimal(19,4) NOT NULL DEFAULT 0,
	`Impuesto1` Decimal(19,4) NOT NULL DEFAULT 0,
	`Impuesto2` Decimal(19,4) NOT NULL DEFAULT 0,
	`Notas` nvarchar(255) NULL DEFAULT '',
	`RefProveedor` nvarchar(20) NOT NULL DEFAULT '',
	`TipoDocumento` nvarchar(3) NULL DEFAULT '',
PRIMARY KEY 
(
	`Numero` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[DevolucionesVenta]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `DevolucionesVenta`(
	`Numero` int NOT NULL,
	`Serie` nvarchar(3) NOT NULL DEFAULT '',
	`FechaRegistro` datetime(3) NOT NULL DEFAULT now(3),
	`FechaTransaccion` datetime(3) NOT NULL DEFAULT now(3),
	`Operador` nvarchar(8) NOT NULL DEFAULT '',
	`NumeroFactura` int NOT NULL DEFAULT 0,
	`CodigoCliente` nvarchar(20) NOT NULL DEFAULT '',
	`NombreCliente` nvarchar(50) NOT NULL DEFAULT '',
	`Valor` Decimal(19,4) NOT NULL DEFAULT 0,
	`Impuesto1` Decimal(19,4) NOT NULL DEFAULT 0,
	`Impuesto2` Decimal(19,4) NOT NULL DEFAULT 0,
	`Costo` Decimal(19,4) NOT NULL DEFAULT 0,
	`Notas` nvarchar(255) NULL DEFAULT '',
	`CodigoVendedor` nvarchar(20) NULL DEFAULT '',
	`ComisionAnulada` Decimal(19,4) NOT NULL DEFAULT 0,
PRIMARY KEY 
(
	`Numero` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[DiferidosBanco]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `DiferidosBanco`(
	`CodigoBanco` nvarchar(20) NOT NULL DEFAULT '',
	`FechaPresentacion` datetime(3) NOT NULL DEFAULT now(3),
	`MontoDiferido` Decimal(19,4) NOT NULL DEFAULT 0,
	`TipoMovimiento` smallint NOT NULL DEFAULT 0,
	`Descripcion` nvarchar(50) NOT NULL DEFAULT '',
	`RefBanco` nvarchar(12) NOT NULL DEFAULT ''
);
/* SQLINES DEMO *** able [dbo].[DocumentosFiscales]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `DocumentosFiscales`(
	`Id` bigint AUTO_INCREMENT NOT NULL,
	`Fecha` datetime(3) NOT NULL DEFAULT now(3),
	`TipoDoc` nvarchar(3) NOT NULL DEFAULT '',
	`NumeroDoc` bigint NOT NULL DEFAULT 0,
	`TipoEntidad` nvarchar(3) NOT NULL DEFAULT '',
	`CodigoEntidad` nvarchar(20) NOT NULL DEFAULT '',
	`Referencia` nvarchar(20) NOT NULL DEFAULT '',
	`NumeroControlInicial` nvarchar(16) NOT NULL DEFAULT '',
	`NumeroControlFinal` nvarchar(16) NOT NULL DEFAULT '',
	`FacturaRelacionada` nvarchar(20) NOT NULL DEFAULT '',
	`Exento` Decimal(19,4) NOT NULL DEFAULT 0,
	`Gravable1` Decimal(19,4) NOT NULL DEFAULT 0,
	`Tasa1` Double NOT NULL DEFAULT 0,
	`Gravable2` Decimal(19,4) NOT NULL DEFAULT 0,
	`Tasa2` Double NOT NULL DEFAULT 0,
	`Impuesto1` Decimal(19,4) NOT NULL DEFAULT 0,
	`Impuesto2` Decimal(19,4) NOT NULL DEFAULT 0,
	`Retencion` Decimal(19,4) NOT NULL DEFAULT 0,
	`TipoDocFiscal` nvarchar(3) NOT NULL DEFAULT '',
	`RifEntidad` nvarchar(14) NOT NULL DEFAULT '',
	`NombreEntidad` nvarchar(50) NOT NULL DEFAULT '',
	`Relacionado` bigint NOT NULL DEFAULT 0,
	`Importado` smallint NOT NULL DEFAULT 0,
	`Contribuyente` smallint NOT NULL DEFAULT 0,
	`FechaNacionalizacion` datetime(3) NOT NULL DEFAULT now(3),
	`DocumentoNacionalizacion` nvarchar(16) NOT NULL DEFAULT '',
	`Reporte` int NOT NULL DEFAULT 0,
PRIMARY KEY 
(
	`Id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[DocumentosISPC]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `DocumentosISPC`(
	`Numero` int NOT NULL,
	`TipoEntidad` nvarchar(3) NOT NULL DEFAULT '',
	`CodigoEntidad` nvarchar(20) NOT NULL DEFAULT '',
	`NumDoc` int NOT NULL DEFAULT 0,
	`TipoDoc` nvarchar(3) NOT NULL DEFAULT '',
	`FechaDoc` datetime(3) NOT NULL DEFAULT now(3),
	`Monto` Decimal(19,4) NOT NULL DEFAULT 0,
	`Saldo` Decimal(19,4) NOT NULL DEFAULT 0,
	`TipoCambio` Double NOT NULL DEFAULT 1,
	`TipoCambioOriginal` Double NOT NULL DEFAULT 1,
PRIMARY KEY 
(
	`Numero` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[EliminacionesPOS]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `EliminacionesPOS`(
	`id` int AUTO_INCREMENT NOT NULL,
	`Sesion` int NOT NULL,
	`Maquina` smallint NOT NULL,
	`Cuenta` nvarchar(14) NOT NULL DEFAULT '',
	`Producto` nvarchar(20) NOT NULL,
	`Precio` Decimal(19,4) NOT NULL,
	`Cantidad` Double NOT NULL,
	`Autorizado` nvarchar(12) NOT NULL DEFAULT '',
	`Hora` datetime(3) NOT NULL DEFAULT now(3),
	`numCta` int NOT NULL DEFAULT 0,
PRIMARY KEY 
(
	`id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[Empaques]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `Empaques`(
	`Codigo` nvarchar(12) NOT NULL,
	`Factor` Double NOT NULL DEFAULT 0,
PRIMARY KEY 
(
	`Codigo` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[ExistenciaUbicacion]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `ExistenciaUbicacion`(
	`CodigoItem` nvarchar(20) NOT NULL DEFAULT '',
	`TipoUbicacion` smallint NOT NULL DEFAULT 0,
	`Almacen` nvarchar(8) NOT NULL DEFAULT '',
	`Existencia` Double NOT NULL DEFAULT 0,
	`Asignadas` Double NULL DEFAULT 0,
	`Piezas` Double NOT NULL DEFAULT 0,
 /* Name ignored: CONSTRAINT `PK_ExistenciaUbicacion` */ PRIMARY KEY 
(
	`CodigoItem` ASC,
	`Almacen` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[extDesc]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `extDesc`(
	`codigoItem` nvarchar(20) NOT NULL DEFAULT '',
	`value` nvarchar(4000) NOT NULL DEFAULT '',
PRIMARY KEY 
(
	`codigoItem` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[Facturas]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `Facturas`(
	`Numero` int NOT NULL,
	`FechaRegistro` datetime(3) NOT NULL DEFAULT now(3),
	`FechaTransaccion` datetime(3) NOT NULL DEFAULT now(3),
	`Operador` nvarchar(8) NOT NULL DEFAULT '',
	`Serie` nvarchar(3) NOT NULL DEFAULT '',
	`Correlativo` int NOT NULL DEFAULT 0,
	`ExtRef` nvarchar(15) NULL DEFAULT '',
	`CodigoCliente` nvarchar(20) NOT NULL DEFAULT '',
	`NombreCliente` nvarchar(50) NOT NULL DEFAULT '',
	`CodigoVendedor` nvarchar(15) NOT NULL DEFAULT '',
	`EstadoDespacho` smallint NOT NULL DEFAULT 0,
	`PrecioLista` Decimal(19,4) NOT NULL DEFAULT 0,
	`PrecioVenta` Decimal(19,4) NOT NULL DEFAULT 0,
	`PrecioEfectivo` Decimal(19,4) NOT NULL DEFAULT 0,
	`Impuesto1` Decimal(19,4) NOT NULL DEFAULT 0,
	`Impuesto2` Decimal(19,4) NOT NULL DEFAULT 0,
	`IndiceReferencia` smallint NOT NULL DEFAULT 0,
	`IndiceVenta` smallint NOT NULL DEFAULT 0,
	`Descuento1` Double NOT NULL DEFAULT 0,
	`Descuento2` Double NOT NULL DEFAULT 0,
	`Costo` Decimal(19,4) NOT NULL DEFAULT 0,
	`SituacionAdministrativa` smallint NOT NULL DEFAULT 0,
	`Condicion` nvarchar(8) NOT NULL DEFAULT '',
	`DescuentosProntoPago` Double NOT NULL DEFAULT 0,
	`Comision` Double NOT NULL DEFAULT 0,
	`ComisionAcreditada` smallint NOT NULL DEFAULT 0,
	`DireccionEntrega` nvarchar(160) NULL DEFAULT '',
	`Notas` nvarchar(255) NULL DEFAULT '',
	`OrdenDespacho` int NOT NULL DEFAULT 0,
	`ComprobanteInventario` int NOT NULL DEFAULT 0,
	`PrecioDevuelto` Decimal(19,4) NOT NULL DEFAULT 0,
	`CostoDevuelto` Decimal(19,4) NOT NULL DEFAULT 0,
	`Saldo` Double NOT NULL DEFAULT 0,
	`Impuesto1Devuelto` Decimal(19,4) NOT NULL DEFAULT 0,
	`Impuesto2Devuelto` Decimal(19,4) NOT NULL DEFAULT 0,
	`Almacen` nvarchar(8) NOT NULL DEFAULT '',
	`TipoCambio` Double NOT NULL DEFAULT 1,
PRIMARY KEY 
(
	`Numero` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[GastosCompra]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `GastosCompra`(
	`id` int AUTO_INCREMENT NOT NULL,
	`Factura` int NOT NULL,
	`Monto` Decimal(19,4) NOT NULL,
	`Descripcion` nvarchar(50) NOT NULL,
	`Fecha` datetime(3) NOT NULL,
	`Clasificacion` nvarchar(12) NULL,
	`TipoDoc` nvarchar(3) NOT NULL,
	`NumeroDoc` int NOT NULL,
	`NumeroDF` int NOT NULL,
	`Beneficiario` nvarchar(59) NOT NULL,
PRIMARY KEY 
(
	`id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[generalEmisores]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `generalEmisores`(
	`TipoDocumento` nvarchar(3) NOT NULL DEFAULT '',
	`CodigoEmisor` nvarchar(20) NOT NULL DEFAULT ''
);
/* SQLINES DEMO *** able [dbo].[historiaIVA]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `historiaIVA`(
	`id` int AUTO_INCREMENT NOT NULL,
	`tipo` tinyint Unsigned NOT NULL,
	`fechaInicioVigencia` datetime(3) NOT NULL,
	`alicuota` Double NOT NULL,
PRIMARY KEY 
(
	`id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[HotKeys]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `HotKeys`(
	`Tecla` nvarchar(1) NOT NULL DEFAULT '',
	`Normal` nvarchar(20) NULL DEFAULT ''
);
/* SQLINES DEMO *** able [dbo].[htc]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `htc`(
	`nseq` bigint AUTO_INCREMENT NOT NULL,
	`hora` datetime(3) NOT NULL DEFAULT now(3),
	`orgtc1` Double NULL,
	`orgtc2` Double NULL,
	`newtc1` Double NULL,
	`newtc2` Double NULL,
PRIMARY KEY 
(
	`nseq` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[Indicadores]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `Indicadores`(
	`Codigo` nvarchar(16) NOT NULL DEFAULT '',
	`Formula` nvarchar(50) NOT NULL DEFAULT '',
	`Modificado` datetime(3) NOT NULL DEFAULT now(3),
	`Autor` nvarchar(8) NOT NULL DEFAULT '',
PRIMARY KEY 
(
	`Codigo` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[itemsInventario]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `itemsInventario`(
	`Codigo` nvarchar(20) NOT NULL,
	`Descripcion` nvarchar(50) NOT NULL DEFAULT '',
	`Linea` nvarchar(8) NOT NULL DEFAULT '',
	`CostoPromedio` Decimal(19,4) NOT NULL DEFAULT 0,
	`UltimoCosto` Decimal(19,4) NOT NULL DEFAULT 0,
	`ClaseImpuesto1` nvarchar(8) NOT NULL DEFAULT '',
	`ClaseImpuesto2` nvarchar(50) NOT NULL DEFAULT '',
	`Existencia` Double NOT NULL DEFAULT 0,
	`Asignadas` Double NOT NULL DEFAULT 0,
	`EnTransito` Double NOT NULL DEFAULT 0,
	`FechaUltimaCompra` datetime(3) NOT NULL DEFAULT '19000101',
	`UltimoProveedor` nvarchar(15) NOT NULL DEFAULT '',
	`PrecioUltimaCompra` Decimal(19,4) NOT NULL DEFAULT 0,
	`CuentaActivo` nvarchar(20) NOT NULL DEFAULT '',
	`CostoDeVentas` nvarchar(50) NOT NULL DEFAULT '',
	`NombreUnidad` nvarchar(12) NOT NULL DEFAULT '',
	`NombreEmpaque` nvarchar(12) NULL DEFAULT '',
	`CantidadEmpaque` Double NOT NULL DEFAULT 1,
	`ExistenciaMinima` Double NOT NULL DEFAULT 0,
	`ExistenciaMaxima` Double NOT NULL DEFAULT 0,
	`UsaSeriales` smallint NOT NULL DEFAULT 0,
	`FechaCreacion` datetime(3) NOT NULL DEFAULT now(3),
	`Grupo` nvarchar(8) NOT NULL DEFAULT '',
	`Consignadas` Double NOT NULL DEFAULT 0,
	`Importado` smallint NOT NULL DEFAULT 0,
	`CostoME` Decimal(19,4) NOT NULL DEFAULT 0,
	`Ubicacion` nvarchar(12) NULL DEFAULT '',
	`peso` Double NOT NULL DEFAULT 0,
	`clasif3` nvarchar(10) NOT NULL DEFAULT '',
	`proveedorPreferido` nvarchar(20) NOT NULL DEFAULT '',
	`ID` int AUTO_INCREMENT NOT NULL,
	`merma` Double NOT NULL DEFAULT 0,
	`diasStock` int NOT NULL DEFAULT 0,
	`ControlarPiezas` tinyint Unsigned NOT NULL DEFAULT 0,
	`Piezas` Double NOT NULL DEFAULT 0,
PRIMARY KEY 
(
	`Codigo` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[ItemsVenta]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `ItemsVenta`(
	`Codigo` nvarchar(20) NOT NULL,
	`Linea` nvarchar(15) NOT NULL DEFAULT '',
	`Descripcion` nvarchar(50) NOT NULL DEFAULT '',
	`CuentaIngreso` nvarchar(20) NOT NULL DEFAULT '',
	`CuentaDevolucion` nvarchar(20) NOT NULL DEFAULT '',
	`CuentaCosto` nvarchar(20) NOT NULL DEFAULT '',
	`Precio1` Decimal(19,4) NOT NULL DEFAULT 0,
	`Precio2` Decimal(19,4) NOT NULL DEFAULT 0,
	`Precio3` Decimal(19,4) NOT NULL DEFAULT 0,
	`Precio4` Decimal(19,4) NOT NULL DEFAULT 0,
	`TipoImpuesto1` nvarchar(8) NOT NULL DEFAULT '',
	`TipoImpuesto2` nvarchar(8) NOT NULL DEFAULT '',
	`CostoStandard` Decimal(19,4) NOT NULL DEFAULT 0,
	`PComis1` Double NOT NULL DEFAULT 0,
	`PComis2` Double NOT NULL DEFAULT 0,
	`PComis3` Double NOT NULL DEFAULT 0,
	`Presentacion` nvarchar(12) NOT NULL DEFAULT '',
	`Unidad` nvarchar(12) NOT NULL DEFAULT '',
	`CantidadPresentacion` Double NOT NULL DEFAULT 0,
	`NumeroPLU` int NULL DEFAULT 0,
	`PrecioIndexado` smallint NOT NULL DEFAULT 0,
	`FechaCreacion` datetime(3) NOT NULL DEFAULT now(3),
	`ImageFile` nvarchar(80) NOT NULL DEFAULT '',
	`Ubicacion` nvarchar(12) NOT NULL DEFAULT '',
	`Grupo` nvarchar(15) NOT NULL DEFAULT '',
	`porcentajeImputable` Double NOT NULL DEFAULT 0,
	`Regulado` tinyint Unsigned NOT NULL DEFAULT 0,
	`isCostoME` tinyint Unsigned NOT NULL DEFAULT 0,
	`clasif3` nvarchar(10) NOT NULL DEFAULT '',
	`ID` int AUTO_INCREMENT NOT NULL,
PRIMARY KEY 
(
	`Codigo` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[Lineas]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `Lineas`(
	`Codigo` nvarchar(8) NOT NULL DEFAULT '',
	`Descripcion` nvarchar(30) NOT NULL DEFAULT '',
PRIMARY KEY 
(
	`Codigo` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[MediosPago]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `MediosPago`(
	`Codigo` nvarchar(8) NOT NULL,
	`Descripcion` nvarchar(40) NOT NULL,
	`Atributos` int NOT NULL DEFAULT 0,
	`PorcentajeRetencionEmisor` Double NOT NULL DEFAULT 0,
	`PorcentajeISLR` Double NOT NULL DEFAULT 0,
	`CuentaActivo` nvarchar(20) NOT NULL DEFAULT '',
	`CuentaComisiones` nvarchar(20) NOT NULL DEFAULT '',
	`BancoRelacionado` nvarchar(20) NOT NULL DEFAULT '',
	`Clase` smallint NOT NULL DEFAULT 0,
	`titulo` nvarchar(15) NOT NULL DEFAULT '',
	`textoAyuda` nvarchar(60) NOT NULL DEFAULT '',
	`posicion` tinyint Unsigned NOT NULL DEFAULT 1,
	`isMedioElectronico` tinyint Unsigned NOT NULL DEFAULT 0,
PRIMARY KEY 
(
	`Codigo` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[mensajesInternos]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `mensajesInternos`(
	`id` int AUTO_INCREMENT NOT NULL,
	`emisor` nvarchar(8) NOT NULL,
	`fechaCreacion` datetime(3) NOT NULL DEFAULT now(3),
	`asunto` nvarchar(50) NOT NULL,
	`contenido` Longtext NOT NULL,
	`adjuntos` Longtext NOT NULL,
	`idOrigen` int NOT NULL DEFAULT 0,
PRIMARY KEY 
(
	`id` ASC
) 
) ;
/* SQLINES DEMO *** able [dbo].[mensajesLeidos]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `mensajesLeidos`(
	`id` int NOT NULL,
	`destinatario` nvarchar(8) NOT NULL,
	`fechaLectura` datetime(3) NOT NULL DEFAULT now(3)
);
/* SQLINES DEMO *** able [dbo].[mensajesPendientes]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `mensajesPendientes`(
	`id` int NOT NULL,
	`destinatario` nvarchar(8) NOT NULL
);
/* SQLINES DEMO *** able [dbo].[mesasAmbientes]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `mesasAmbientes`(
	`Codigo` nvarchar(16) NOT NULL DEFAULT '',
	`Prefijo` nvarchar(3) NOT NULL DEFAULT '',
	`Descripcion` nvarchar(32) NOT NULL DEFAULT '',
	`AccountOffset` int NOT NULL DEFAULT 0,
	`PorcentajeServicio` Double NOT NULL DEFAULT 0,
	`IndicePrecio` smallint NOT NULL DEFAULT 0,
	`Escala` Double NOT NULL DEFAULT 0,
	`BackColor` int NOT NULL DEFAULT 0,
	`ColorSillas` int NOT NULL DEFAULT 0,
	`ColorMesas` int NOT NULL DEFAULT 0,
	`FormaMesas` smallint NOT NULL DEFAULT 0,
	`FormaSillas` smallint NOT NULL DEFAULT 0,
	`SillasVisibles` smallint NOT NULL DEFAULT 0,
	`ID` int AUTO_INCREMENT PRIMARY KEY NOT NULL,
	`imagenFondo` nvarchar(128) NOT NULL DEFAULT ''
);
/* SQLINES DEMO *** able [dbo].[mesasItems]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `mesasItems`(
	`Codigo` nvarchar(20) NOT NULL DEFAULT '',
	`Precio` Decimal(19,4) NOT NULL DEFAULT 0
);
/* SQLINES DEMO *** able [dbo].[mesasMesas]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `mesasMesas`(
	`id` int AUTO_INCREMENT NOT NULL,
	`Ambiente` nvarchar(16) NOT NULL DEFAULT '',
	`IDMesa` int NOT NULL DEFAULT 0,
	`x` int NOT NULL DEFAULT 0,
	`y` int NOT NULL DEFAULT 0,
	`enmStat` smallint NOT NULL DEFAULT 0,
	`nPersonas` smallint NOT NULL DEFAULT 0,
	`cMesonero` nvarchar(20) NULL DEFAULT '',
	`MontoDespachado` Decimal(19,4) NOT NULL DEFAULT 0,
	`Apertura` datetime(3) NOT NULL DEFAULT now(3),
	`Cuenta` int NOT NULL DEFAULT 0,
	`idTipo` int NOT NULL DEFAULT 0,
PRIMARY KEY 
(
	`id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[mesasTiposMesa]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `mesasTiposMesa`(
	`id` int AUTO_INCREMENT NOT NULL,
	`nombre` nvarchar(24) NOT NULL,
	`width` smallint NOT NULL,
	`height` smallint NOT NULL,
	`xid` smallint NOT NULL,
	`yId` smallint NOT NULL,
	`backColorId` int NOT NULL,
	`foreColorId` int NOT NULL,
	`xTime` smallint NOT NULL,
	`yTime` smallint NOT NULL,
	`backColorTime` int NOT NULL,
	`foreColorTime` int NOT NULL,
PRIMARY KEY 
(
	`id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[mesasZonas]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `mesasZonas`(
	`CodigoZona` nvarchar(8) NOT NULL,
	`Rangos` nvarchar(36) NOT NULL,
PRIMARY KEY 
(
	`CodigoZona` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[mnuDeclares]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `mnuDeclares`(
	`id` bigint AUTO_INCREMENT NOT NULL,
	`ownerMenu` nvarchar(10) NOT NULL DEFAULT '',
	`Descripcion` nvarchar(50) NOT NULL DEFAULT '',
	`imageFile` nvarchar(128) NOT NULL DEFAULT '',
PRIMARY KEY 
(
	`id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[mnuItems]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `mnuItems`(
	`ownerMenu` nvarchar(10) NOT NULL DEFAULT '',
	`Posicion` smallint NOT NULL DEFAULT 0,
	`isTerminal` smallint NOT NULL DEFAULT 0,
	`CodigoItem` nvarchar(20) NOT NULL DEFAULT '',
	`Imagen` nvarchar(64) NULL DEFAULT '',
	`Descripcion` nvarchar(40) NOT NULL DEFAULT '',
	`Color` int NOT NULL DEFAULT 0,
	`ExtDesc` Longtext NOT NULL DEFAULT '',
	`textColor` int NOT NULL DEFAULT 0
) ;
/* SQLINES DEMO *** able [dbo].[MotivosDescuento]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `MotivosDescuento`(
	`Codigo` nvarchar(12) NOT NULL,
	`Descripcion` nvarchar(40) NOT NULL,
	`porcentaje` Double NOT NULL DEFAULT 0,
	`respetarMinimos` tinyint Unsigned NOT NULL DEFAULT 1,
	`nivelAutorizacion` tinyint Unsigned NOT NULL DEFAULT 1,
	`detallesModificables` tinyint Unsigned NOT NULL DEFAULT 0,
PRIMARY KEY 
(
	`Codigo` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[MovimientosBanco]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `MovimientosBanco`(
	`Numero` int AUTO_INCREMENT NOT NULL,
	`FechaRegistro` datetime(3) NOT NULL DEFAULT now(3),
	`FechaTransaccion` datetime(3) NOT NULL DEFAULT now(3),
	`Operador` nvarchar(8) NOT NULL DEFAULT '',
	`CodigoBanco` nvarchar(20) NOT NULL DEFAULT '',
	`Tipo` smallint NOT NULL DEFAULT 0,
	`Concepto` nvarchar(60) NOT NULL DEFAULT '',
	`Beneficiario` nvarchar(60) NOT NULL DEFAULT '',
	`Monto` Decimal(19,4) NOT NULL DEFAULT 0,
	`ReferenciaBanco` nvarchar(12) NOT NULL DEFAULT '',
	`Conciliado` int NOT NULL DEFAULT 0,
	`FechaEfectivo` datetime(3) NOT NULL DEFAULT now(3),
	`TipoDocRel` nvarchar(3) NOT NULL DEFAULT '',
	`NumeroDocRel` int NOT NULL DEFAULT 0,
	`Comision` Decimal(19,4) NOT NULL DEFAULT 0,
	`RetencionISLR` Decimal(19,4) NOT NULL DEFAULT 0,
	`Clasificacion` nvarchar(12) NOT NULL DEFAULT '',
	`valorMN` Decimal(19,4) NOT NULL DEFAULT 0,
	`montoIGTF` Decimal(19,4) NOT NULL DEFAULT 0,
PRIMARY KEY 
(
	`Numero` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[MovimientosCaja]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `MovimientosCaja`(
	`TransID` int AUTO_INCREMENT NOT NULL,
	`Sesion` int NOT NULL DEFAULT 0,
	`Operador` nvarchar(8) NOT NULL,
	`Debitos` Decimal(19,4) NOT NULL DEFAULT 0,
	`Creditos` Decimal(19,4) NOT NULL DEFAULT 0,
	`TipoEntidad` nvarchar(3) NOT NULL DEFAULT '',
	`CodigoEntidad` nvarchar(20) NOT NULL DEFAULT '',
	`TipoDocumento` nvarchar(3) NOT NULL DEFAULT '',
	`NumeroDocumento` int NOT NULL DEFAULT 0,
	`Fecha` datetime(3) NOT NULL DEFAULT now(3),
	`Descripcion` nvarchar(50) NULL,
	`Hora` Datetime NULL,
	`Clasificacion` nvarchar(12) NOT NULL DEFAULT '',
	`Beneficiario` nvarchar(50) NOT NULL DEFAULT '',
	`MachineID` int NOT NULL DEFAULT 0,
	`montoIGTF` Decimal(19,4) NOT NULL DEFAULT 0,
	`TipoCambio` Double NOT NULL DEFAULT 1,
PRIMARY KEY 
(
	`TransID` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[NCPOS]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `NCPOS`(
	`numero` int AUTO_INCREMENT NOT NULL,
	`idSesion` int NOT NULL,
	`Hora` datetime(3) NOT NULL DEFAULT now(3),
	`idMaquina` int NOT NULL,
	`correlativo` int NOT NULL,
	`montoVenta` Decimal(19,4) NOT NULL DEFAULT 0,
	`Impuesto` Decimal(19,4) NOT NULL,
	`idMaquinaOrigen` int NOT NULL,
	`correlativoOrigen` int NOT NULL,
	`fechaOrigen` datetime(3) NOT NULL,
	`numeroNotaRelacionada` int NOT NULL DEFAULT 0,
	`codigoCliente` nvarchar(20) NOT NULL DEFAULT '',
PRIMARY KEY 
(
	`numero` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[NCPOSdetalles]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `NCPOSdetalles`(
	`id` int AUTO_INCREMENT NOT NULL,
	`idNCPOS` int NOT NULL,
	`codigoItem` nvarchar(20) NOT NULL,
	`cantidad` Double NOT NULL,
	`precio` Decimal(19,4) NOT NULL,
	`porcentajeImpuesto` Double NOT NULL,
PRIMARY KEY 
(
	`id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[NNEE]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `NNEE`(
	`Numero` int NOT NULL DEFAULT 0,
	`FechaRegistro` datetime(3) NOT NULL DEFAULT now(3),
	`FechaTransaccion` datetime(3) NOT NULL DEFAULT now(3),
	`Operador` nvarchar(8) NOT NULL DEFAULT '',
	`CodigoCliente` nvarchar(20) NOT NULL DEFAULT '',
	`NombreCliente` nvarchar(50) NOT NULL DEFAULT '',
	`CodigoVendedor` nvarchar(15) NOT NULL DEFAULT '',
	`Estado` smallint NOT NULL DEFAULT 0,
	`PrecioLista` Decimal(19,4) NOT NULL DEFAULT 0,
	`PrecioVenta` Decimal(19,4) NOT NULL DEFAULT 0,
	`PrecioEfectivo` Decimal(19,4) NOT NULL DEFAULT 0,
	`Impuesto1` Decimal(19,4) NOT NULL DEFAULT 0,
	`Impuesto2` Decimal(19,4) NOT NULL DEFAULT 0,
	`IndiceReferencia` smallint NOT NULL DEFAULT 0,
	`IndiceVenta` smallint NOT NULL DEFAULT 0,
	`Descuento1` Double NOT NULL DEFAULT 0,
	`Descuento2` Double NOT NULL DEFAULT 0,
	`Condicion` nvarchar(8) NOT NULL DEFAULT '',
	`DireccionEntrega` nvarchar(160) NOT NULL DEFAULT '',
	`Notas` nvarchar(255) NOT NULL DEFAULT '',
	`ComprobanteAlmacen` int NOT NULL DEFAULT 0,
	`NumeroFacturaOrigen` int NOT NULL DEFAULT 0,
	`SaldoActual` Decimal(19,4) NOT NULL DEFAULT 0,
	`TipoCambio` Double NOT NULL DEFAULT 1,
PRIMARY KEY 
(
	`Numero` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[NNEEDetalles]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `NNEEDetalles`(
	`NumeroDocumento` int NOT NULL DEFAULT 0,
	`Renglon` smallint NOT NULL DEFAULT 0,
	`CodigoItem` nvarchar(20) NULL DEFAULT '',
	`Descripcion` nvarchar(50) NOT NULL DEFAULT '',
	`Presentacion` nvarchar(12) NOT NULL DEFAULT '',
	`FactorEmpaque` Double NOT NULL DEFAULT 0,
	`Cantidad` Double NOT NULL DEFAULT 0,
	`PrecioLista` Decimal(19,4) NOT NULL DEFAULT 0,
	`PrecioVenta` Decimal(19,4) NOT NULL DEFAULT 0,
	`PrecioEfectivo` Decimal(19,4) NOT NULL DEFAULT 0,
	`Impuesto1` Double NOT NULL DEFAULT 0,
	`Impuesto2` Double NOT NULL DEFAULT 0,
	`CostoUnitario` Decimal(19,4) NOT NULL DEFAULT 0,
	`SaldoCantidad` Double NOT NULL DEFAULT 0,
	`Descuentos` nvarchar(10) NOT NULL DEFAULT '',
	`Piezas` Double NOT NULL DEFAULT 0
);
/* SQLINES DEMO *** able [dbo].[NNEEDetalleSuplemento]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `NNEEDetalleSuplemento`(
	`NumeroDocumento` int NOT NULL DEFAULT 0,
	`Renglon` int NOT NULL DEFAULT 0,
	`NumeroRenglonOrigen` int NOT NULL DEFAULT 0,
	`CodigoItem` nvarchar(20) NOT NULL DEFAULT '',
	`Cantidad` Double NOT NULL DEFAULT 0,
	`Presentacion` nvarchar(12) NOT NULL DEFAULT '',
	`FactorPresentacion` Double NOT NULL DEFAULT 0,
	`PrecioNeto` Decimal(19,4) NOT NULL DEFAULT 0,
	`Impuesto1` Double NOT NULL DEFAULT 0,
	`Impuesto2` Double NOT NULL DEFAULT 0,
	`Piezas` Double NOT NULL DEFAULT 0
);
/* SQLINES DEMO *** able [dbo].[NNEEDevDetalles]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `NNEEDevDetalles`(
	`NumeroDevolucion` bigint NOT NULL,
	`Renglon` int NOT NULL DEFAULT 0,
	`NumeroDetalle` int NOT NULL,
	`CodigoItem` nvarchar(20) NULL,
	`Cantidad` Double NULL,
	`Presentacion` nvarchar(12) NULL,
	`FactorEmpaque` Double NULL,
	`PrecioUnitario` Decimal(19,4) NULL,
	`CostoUnitario` Decimal(19,4) NULL,
	`NumeroNota` bigint NULL,
	`Piezas` Double NOT NULL DEFAULT 0,
 /* Name ignored: CONSTRAINT `PK_NNEEDevDetalles` */ PRIMARY KEY 
(
	`NumeroDevolucion` ASC,
	`NumeroDetalle` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[NNEEDevoluciones]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `NNEEDevoluciones`(
	`Numero` bigint AUTO_INCREMENT NOT NULL,
	`FechaRegistro` datetime(3) NOT NULL DEFAULT now(3),
	`Operador` nvarchar(8) NULL,
	`FechaTransaccion` datetime(3) NOT NULL,
	`Almacen` nvarchar(12) NULL,
	`CodigoCliente` nvarchar(20) NULL,
	`Descripcion` nvarchar(50) NULL,
	`ValorPrecioVenta` Decimal(19,4) NULL,
	`CostoDevuelto` Decimal(19,4) NULL,
PRIMARY KEY 
(
	`Numero` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[NNEESuplemento]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `NNEESuplemento`(
	`Numero` int AUTO_INCREMENT NOT NULL,
	`NumeroNota` int NOT NULL DEFAULT 0,
	`FechaRegistro` datetime(3) NOT NULL DEFAULT now(3),
	`Operador` nvarchar(8) NOT NULL DEFAULT '',
	`FechaTransaccion` datetime(3) NOT NULL DEFAULT now(3),
	`CodigoCliente` nvarchar(20) NOT NULL DEFAULT '',
	`Descripcion` nvarchar(50) NULL DEFAULT '',
	`Impuesto1` Decimal(19,4) NOT NULL DEFAULT 0,
	`Impuesto2` Decimal(19,4) NOT NULL DEFAULT 0,
	`Valor` Decimal(19,4) NOT NULL DEFAULT 0,
	`TipoDocRel` nvarchar(3) NULL DEFAULT '',
	`NumeroDocRel` int NOT NULL DEFAULT 0,
PRIMARY KEY 
(
	`Numero` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[nomAsigDedScript]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `nomAsigDedScript`(
	`CodigoScript` nvarchar(20) NOT NULL DEFAULT '',
	`codigoAsigDed` nvarchar(24) NOT NULL DEFAULT '',
	`Orden` smallint NOT NULL DEFAULT 0
);
/* SQLINES DEMO *** able [dbo].[nomAtribTrabajador]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `nomAtribTrabajador`(
	`CodTrab` nvarchar(20) NOT NULL DEFAULT '',
	`CodAttrib` nvarchar(24) NOT NULL DEFAULT '',
	`ValAttrib` Double NOT NULL DEFAULT 0
);
/* SQLINES DEMO *** able [dbo].[nomCategoriasLaborales]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `nomCategoriasLaborales`(
	`Codigo` nvarchar(24) NOT NULL,
	`Descripcion` nvarchar(50) NOT NULL,
PRIMARY KEY 
(
	`Codigo` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[nomCodigosRecibo]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `nomCodigosRecibo`(
	`Codigo` nvarchar(24) NOT NULL,
	`Descripcion` nvarchar(50) NOT NULL,
PRIMARY KEY 
(
	`Codigo` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[nomCodigosReporte]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `nomCodigosReporte`(
	`Codigo` nvarchar(24) NOT NULL,
	`Descripcion` nvarchar(50) NOT NULL,
PRIMARY KEY 
(
	`Codigo` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[nomDefAsigDed]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `nomDefAsigDed`(
	`Codigo` nvarchar(24) NOT NULL,
	`Descripcion` nvarchar(50) NOT NULL,
	`Tipo` int NOT NULL,
	`ClaseLaboral` nvarchar(16) NOT NULL,
	`CodigoReporte` nvarchar(20) NOT NULL,
	`CodigoCuenta` nvarchar(20) NULL,
	`CodigoContrapartida` nvarchar(20) NULL,
	`Formula` Longtext NOT NULL,
	`CodigoRecibo` nvarchar(20) NOT NULL,
PRIMARY KEY 
(
	`Codigo` ASC
) 
) ;
/* SQLINES DEMO *** able [dbo].[nomDepartamentos]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `nomDepartamentos`(
	`Codigo` nvarchar(24) NOT NULL,
	`Descripcion` nvarchar(40) NOT NULL,
PRIMARY KEY 
(
	`Codigo` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[nomDescCargos]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `nomDescCargos`(
	`Codigo` nvarchar(24) NOT NULL,
	`Descripcion` nvarchar(40) NOT NULL,
PRIMARY KEY 
(
	`Codigo` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[nomDescHabilidad]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `nomDescHabilidad`(
	`Codigo` nvarchar(24) NOT NULL,
	`Descripcion` nvarchar(40) NOT NULL,
	`MinRango` smallint NOT NULL,
	`MaxRango` smallint NOT NULL,
PRIMARY KEY 
(
	`Codigo` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[nomDetallesProceso]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `nomDetallesProceso`(
	`ProcessID` int NOT NULL,
	`Trabajador` nvarchar(20) NOT NULL,
	`Departamento` nvarchar(24) NOT NULL,
	`Cargo` nvarchar(24) NOT NULL,
	`Tipo` smallint NOT NULL,
	`FechaCierre` datetime(3) NOT NULL,
	`ClaseLaboral` nvarchar(24) NOT NULL,
	`CodigoReporte` nvarchar(24) NOT NULL,
	`CodigoCuenta` nvarchar(20) NOT NULL DEFAULT '',
	`CodigoContrapartida` nvarchar(20) NOT NULL DEFAULT '',
	`CodigoRecibo` nvarchar(24) NOT NULL DEFAULT '',
	`CodigoAsigDed` nvarchar(24) NOT NULL DEFAULT '',
	`Valor` Decimal(19,4) NOT NULL DEFAULT 0,
	`Cantidad` Double NOT NULL DEFAULT 0
);
/* SQLINES DEMO *** able [dbo].[nomDetallesRecibo]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `nomDetallesRecibo`(
	`numeroProceso` int NOT NULL,
	`codigoTrabajador` nvarchar(20) NOT NULL,
	`varID` nvarchar(40) NOT NULL,
	`varType` int NOT NULL,
	`Value` Longtext NOT NULL
) ;
/* SQLINES DEMO *** able [dbo].[nomEnumHabilidades]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `nomEnumHabilidades`(
	`CodigoHabilidad` nvarchar(24) NOT NULL,
	`Enumerador` nvarchar(12) NOT NULL,
	`Valor` int NOT NULL
);
/* SQLINES DEMO *** able [dbo].[nomExcepciones]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `nomExcepciones`(
	`NumeroId` int AUTO_INCREMENT NOT NULL,
	`CodTrabajador` nvarchar(20) NOT NULL,
	`CodExcepcion` nvarchar(24) NOT NULL,
	`Fecha` datetime(3) NOT NULL,
	`Valor` Double NOT NULL,
	`Notas` nvarchar(255) NULL,
	`TipoRecurrencia` smallint NOT NULL,
	`Recurrencia` Double NOT NULL,
	`Operador` nvarchar(20) NULL,
	`FechaRegistro` datetime(3) NOT NULL,
PRIMARY KEY 
(
	`NumeroId` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[nomExcepcionesProceso]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `nomExcepcionesProceso`(
	`idProceso` int NOT NULL,
	`NumeroId` int NOT NULL,
	`CodTrabajador` nvarchar(20) NOT NULL,
	`CodExcepcion` nvarchar(24) NOT NULL,
	`Fecha` datetime(3) NOT NULL,
	`Valor` Double NOT NULL DEFAULT 0,
	`Notas` nvarchar(255) NULL,
	`TipoRecurrencia` smallint NOT NULL DEFAULT 0,
	`Recurrencia` Double NOT NULL DEFAULT 0,
	`Operador` nvarchar(20) NOT NULL DEFAULT '',
	`FechaRegistro` datetime(3) NOT NULL DEFAULT now(3),
 /* Name ignored: CONSTRAINT `PK_nomExcepcionesProceso` */ PRIMARY KEY 
(
	`idProceso` ASC,
	`NumeroId` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[nomFiltros]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `nomFiltros`(
	`Codigo` nvarchar(24) NOT NULL,
	`codigoAtributo` nvarchar(24) NOT NULL,
	`valorDesde` nvarchar(40) NOT NULL,
	`valorHasta` nvarchar(40) NOT NULL
);
/* SQLINES DEMO *** able [dbo].[nomFiltrosScript]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `nomFiltrosScript`(
	`CodigoScript` nvarchar(20) NOT NULL,
	`codigoFiltro` nvarchar(24) NOT NULL
);
/* SQLINES DEMO *** able [dbo].[nomHabilidadesTrabajador]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `nomHabilidadesTrabajador`(
	`CodigoTrabajador` nvarchar(20) NOT NULL,
	`CodigoHabilidad` nvarchar(24) NOT NULL,
	`Grado` smallint NOT NULL,
	`Notas` nvarchar(160) NOT NULL DEFAULT ''
);
/* SQLINES DEMO *** able [dbo].[nomHistTrab]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `nomHistTrab`(
	`CodigoTrabajador` nvarchar(20) NOT NULL,
	`Desde` datetime(3) NOT NULL,
	`Departamento` nvarchar(24) NOT NULL,
	`Cargo` nvarchar(24) NOT NULL,
	`Sueldo` Decimal(19,4) NOT NULL,
	`Base` smallint NOT NULL
);
/* SQLINES DEMO *** able [dbo].[nomObservaciones]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `nomObservaciones`(
	`Numero` int AUTO_INCREMENT NOT NULL,
	`CodigoTrabajador` nvarchar(20) NOT NULL,
	`Fecha` datetime(3) NOT NULL,
	`Operador` nvarchar(20) NOT NULL,
	`TipoObservacion` nvarchar(24) NOT NULL,
	`Observacion` Longtext NOT NULL,
PRIMARY KEY 
(
	`Numero` ASC
) 
) ;
/* SQLINES DEMO *** able [dbo].[nomPagosProceso]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `nomPagosProceso`(
	`ProcessID` int NOT NULL,
	`Trabajador` nvarchar(20) NOT NULL,
	`Fecha` datetime(3) NOT NULL,
	`Departamento` nvarchar(24) NOT NULL,
	`Cargo` nvarchar(24) NOT NULL,
	`MontoPagado` Decimal(19,4) NOT NULL,
	`Medio` nvarchar(20) NOT NULL,
	`CodigoBanco` nvarchar(20) NULL,
	`NumeroDocumento` nvarchar(12) NULL
);
/* SQLINES DEMO *** able [dbo].[nomParametrosGenerales]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `nomParametrosGenerales`(
	`sueldoMinimo` Decimal(19,4) NOT NULL DEFAULT 0
);
/* SQLINES DEMO *** able [dbo].[nomParametrosPrestamo]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `nomParametrosPrestamo`(
	`id` bigint AUTO_INCREMENT NOT NULL,
	`idPrestamo` int NOT NULL,
	`codigoProceso` nvarchar(20) NOT NULL,
	`porcentaje` Double NOT NULL,
PRIMARY KEY 
(
	`id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[nomRecibosScript]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `nomRecibosScript`(
	`CodigoScript` nvarchar(12) NOT NULL,
	`FileName` nvarchar(64) NOT NULL,
	`PrinterName` nvarchar(64) NOT NULL
);
/* SQLINES DEMO *** able [dbo].[nomSalarioMinimo]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `nomSalarioMinimo`(
	`Fecha` datetime(3) NOT NULL DEFAULT '18000101',
	`NetoVEF` Decimal(19,4) NOT NULL DEFAULT 0,
	`BonoVEF` Decimal(19,4) NOT NULL DEFAULT 0,
	`AJUSTE` Double NOT NULL DEFAULT 0,
PRIMARY KEY 
(
	`Fecha` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[nomScripts]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `nomScripts`(
	`Codigo` nvarchar(20) NOT NULL,
	`descripcionScript` nvarchar(60) NOT NULL,
	`codePostTrabajador` Longtext NOT NULL,
	`codeVerificarRestricciones` Longtext NOT NULL,
	`codeBaseScript` Longtext NULL,
	`codeTrabajadorElegible` Longtext NOT NULL,
PRIMARY KEY 
(
	`Codigo` ASC
) 
) ;
/* SQLINES DEMO *** able [dbo].[nomTasas6PB]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `nomTasas6PB`(
	`periodo` int NOT NULL,
	`tasa` Double NOT NULL DEFAULT 0,
PRIMARY KEY 
(
	`periodo` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[nomTiposAtributo]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `nomTiposAtributo`(
	`Codigo` nvarchar(24) NOT NULL,
	`Descripcion` nvarchar(50) NOT NULL,
PRIMARY KEY 
(
	`Codigo` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[nomTiposExcepcion]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `nomTiposExcepcion`(
	`Codigo` nvarchar(24) NOT NULL,
	`Descripcion` nvarchar(50) NOT NULL,
	`Visible` smallint NOT NULL,
PRIMARY KEY 
(
	`Codigo` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[nomTiposObservacion]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `nomTiposObservacion`(
	`Codigo` nvarchar(24) NOT NULL,
	`Descripcion` nvarchar(50) NOT NULL,
PRIMARY KEY 
(
	`Codigo` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[nomTMPListaExcepciones]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `nomTMPListaExcepciones`(
	`NumeroId` int NOT NULL,
	`CodTrabajador` nvarchar(20) NOT NULL,
	`CodExcepcion` nvarchar(24) NOT NULL,
	`Fecha` datetime(3) NOT NULL,
	`Valor` Double NOT NULL,
	`Notas` nvarchar(255) NOT NULL DEFAULT '',
	`TipoRecurrencia` smallint NOT NULL DEFAULT 0,
	`Recurrencia` Double NOT NULL DEFAULT 0,
	`Operador` nvarchar(20) NOT NULL DEFAULT ''
);
/* SQLINES DEMO *** able [dbo].[nomTMPResumenProceso]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `nomTMPResumenProceso`(
	`sUserID` nvarchar(8) NOT NULL,
	`sCodTrab` nvarchar(20) NOT NULL,
	`sCodDept` nvarchar(24) NOT NULL,
	`sCodGrup` nvarchar(24) NOT NULL,
	`nTipo` smallint NOT NULL,
	`vmValor` Decimal(19,4) NOT NULL
);
/* SQLINES DEMO *** able [dbo].[nomTrabajadores]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `nomTrabajadores`(
	`Codigo` nvarchar(20) NOT NULL,
	`Nombre` nvarchar(40) NOT NULL,
	`CI` nvarchar(12) NOT NULL,
	`Departamento` nvarchar(24) NOT NULL,
	`Cargo` nvarchar(24) NOT NULL,
	`FechaIngreso` datetime(3) NOT NULL,
	`FechaAsignacion` datetime(3) NOT NULL,
	`Sueldo` Decimal(19,4) NOT NULL,
	`BaseSueldo` smallint NOT NULL,
	`Direccion` nvarchar(160) NULL,
	`Telefono` nvarchar(30) NULL,
	`Sexo` smallint NOT NULL,
	`EstadoCivil` smallint NOT NULL,
	`FechaNacimiento` datetime(3) NOT NULL,
	`LugarNacimiento` nvarchar(20) NULL,
	`NombreConyuge` nvarchar(40) NULL,
	`NumeroDeHijos` smallint NOT NULL,
	`Activo` smallint NOT NULL DEFAULT 0,
	`ImageFile` nvarchar(80) NULL DEFAULT '',
	`EstadoAcceso` tinyint Unsigned NOT NULL DEFAULT 0,
	`ganaSueldoMinimo` smallint NOT NULL DEFAULT 0,
	`cuentaBancaria` nvarchar(20) NOT NULL DEFAULT '',
PRIMARY KEY 
(
	`Codigo` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[notas]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `notas`(
	`id` bigint AUTO_INCREMENT NOT NULL,
	`tipoEntidad` nvarchar(3) NOT NULL DEFAULT '',
	`codigoEntidad` nvarchar(20) NOT NULL DEFAULT '',
	`fecha` datetime(3) NOT NULL DEFAULT now(3),
	`contenido` Longtext NOT NULL DEFAULT '',
	`codigoOperador` nvarchar(12) NOT NULL DEFAULT '',
PRIMARY KEY 
(
	`id` ASC
) 
) ;
/* SQLINES DEMO *** able [dbo].[NotasDCCP]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `NotasDCCP`(
	`Numero` int NOT NULL DEFAULT 0,
	`Correlativo` int NOT NULL DEFAULT 0,
	`Serie` nvarchar(3) NOT NULL DEFAULT '',
	`correlativoSerie` int NOT NULL DEFAULT 0,
	`TipoEntidad` nvarchar(3) NOT NULL DEFAULT '',
	`CodigoEntidad` nvarchar(20) NOT NULL DEFAULT '',
	`FechaDoc` datetime(3) NOT NULL DEFAULT now(3),
	`Descripcion` nvarchar(40) NOT NULL DEFAULT '',
	`Monto` Decimal(19,4) NOT NULL DEFAULT 0,
	`Saldo` Decimal(19,4) NOT NULL DEFAULT 0,
	`Operador` nvarchar(8) NOT NULL DEFAULT '',
	`TipoOperacion` tinyint Unsigned NOT NULL DEFAULT 0,
	`DocumentoOrigen` int NOT NULL DEFAULT 0,
	`Clasificacion` nvarchar(12) NOT NULL DEFAULT '',
PRIMARY KEY 
(
	`Numero` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[ocDetalles]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `ocDetalles`(
	`NumeroDocumento` int NOT NULL DEFAULT 0,
	`Renglon` smallint NOT NULL DEFAULT 0,
	`CodigoItem` nvarchar(20) NULL DEFAULT '',
	`Descripcion` nvarchar(50) NULL DEFAULT '',
	`Presentacion` nvarchar(12) NULL DEFAULT 'UND.',
	`FactorEmpaque` Double NOT NULL DEFAULT 1,
	`Cantidad` Double NOT NULL DEFAULT 0,
	`PrecioRequerido` Decimal(19,4) NOT NULL DEFAULT 0,
	`Recibidas` Double NOT NULL DEFAULT 0,
	`PrecioMedio` Decimal(19,4) NOT NULL DEFAULT 0,
	`CantPaga` Double NOT NULL DEFAULT 0,
	`CantPromo` Double NOT NULL DEFAULT 0,
	`PVP` Decimal(19,4) NOT NULL DEFAULT 0,
	`Descuentos` nvarchar(15) NULL DEFAULT ''
);
/* SQLINES DEMO *** able [dbo].[ocOrdenes]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `ocOrdenes`(
	`Numero` int NOT NULL,
	`FechaRegistro` datetime(3) NOT NULL,
	`FechaTransaccion` datetime(3) NOT NULL,
	`Operador` nvarchar(8) NOT NULL,
	`CodigoProveedor` nvarchar(20) NOT NULL,
	`NombreProveedor` nvarchar(50) NULL,
	`FechaRequerido` datetime(3) NOT NULL,
	`Estado` smallint NOT NULL,
	`ValorNominal` Decimal(19,4) NOT NULL,
	`Descuento1` Double NOT NULL,
	`Descuento2` Double NOT NULL,
	`Notas` nvarchar(255) NULL,
	`TipoCambio` Double NOT NULL DEFAULT 1,
PRIMARY KEY 
(
	`Numero` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[ocRecibidas]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `ocRecibidas`(
	`NumeroOrden` int NOT NULL,
	`NumeroRenglon` smallint NOT NULL,
	`Fecha` datetime(3) NOT NULL,
	`CodigoItem` nvarchar(20) NOT NULL,
	`Cantidad` Double NOT NULL,
	`PrecioUnitario` Decimal(19,4) NOT NULL,
	`Unidad` nvarchar(12) NOT NULL,
	`Factor` Double NOT NULL,
	`TipoDocumento` nvarchar(5) NOT NULL,
	`NumeroDocumento` int NOT NULL
);
/* SQLINES DEMO *** able [dbo].[Opciones]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `Opciones`(
	`TipoOpcion` nvarchar(1) NOT NULL DEFAULT '',
	`CodigoItem` nvarchar(20) NOT NULL DEFAULT '',
	`Descripcion` nvarchar(50) NOT NULL DEFAULT '',
	`Pedido` nvarchar(2) NOT NULL DEFAULT ''
);
/* SQLINES DEMO *** able [dbo].[ParametrosEmpresa]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `ParametrosEmpresa`(
	`NombreEmpresa` nvarchar(50) NOT NULL,
	`RIF` nvarchar(20) NOT NULL DEFAULT '',
	`NIT` nvarchar(12) NOT NULL DEFAULT '',
	`Direccion` nvarchar(160) NOT NULL DEFAULT '',
	`Telefono` nvarchar(30) NOT NULL DEFAULT '',
	`MascaraPrecios` nvarchar(20) NOT NULL DEFAULT '',
	`MascaraMonetarios` nvarchar(20) NOT NULL DEFAULT '',
	`MascaraInventario` nvarchar(20) NOT NULL DEFAULT '',
	`MascaraCantidades` nvarchar(50) NOT NULL DEFAULT '',
	`FormatoSaldos` nvarchar(20) NOT NULL DEFAULT '',
	`FactorRedondeoPrecios` Double NOT NULL DEFAULT 0,
	`DefaultImpuesto1` nvarchar(3) NOT NULL DEFAULT '',
	`DefaultImpuesto2` nvarchar(3) NOT NULL DEFAULT '',
	`PrecioIncluyeImpuesto1` smallint NOT NULL DEFAULT 0,
	`PrecioIncluyeImpuesto2` smallint NOT NULL DEFAULT 0,
	`CodigoClienteMostrador` nvarchar(15) NOT NULL DEFAULT '',
	`MesInicioAnho` smallint NOT NULL DEFAULT 0,
	`AnhoActual` smallint NOT NULL DEFAULT 0,
	`PeriodoActual` smallint NOT NULL DEFAULT 0,
	`FormatoCodigos` nvarchar(20) NOT NULL DEFAULT '',
	`CuentaGanPer` nvarchar(20) NULL DEFAULT '',
	`Separador` nvarchar(1) NOT NULL DEFAULT '',
	`AcreditarComision` smallint NOT NULL DEFAULT 0,
	`PComisVenta1` Double NOT NULL DEFAULT 0,
	`PComisVenta2` Double NOT NULL DEFAULT 0,
	`PComisVenta3` Double NOT NULL DEFAULT 0,
	`PComisCobranza1` Double NOT NULL DEFAULT 0,
	`PComisCobranza2` Double NOT NULL DEFAULT 0,
	`PComisCobranza3` Double NOT NULL DEFAULT 0,
	`indexarPrecios` smallint NOT NULL DEFAULT 0,
	`valoracionInventario` smallint NOT NULL DEFAULT 0,
	`TituloPrecio1` nvarchar(20) NOT NULL DEFAULT '',
	`TituloPrecio2` nvarchar(20) NOT NULL DEFAULT '',
	`TituloPrecio3` nvarchar(20) NOT NULL DEFAULT '',
	`TituloPrecio4` nvarchar(20) NOT NULL DEFAULT '',
	`NombreImpuesto1` nvarchar(12) NOT NULL DEFAULT '',
	`NombreImpuesto2` nvarchar(12) NOT NULL DEFAULT '',
	`CuentaGeneralVentas` nvarchar(20) NOT NULL DEFAULT '',
	`CuentaGeneralInventario` nvarchar(20) NOT NULL DEFAULT '',
	`CuentaGeneralDeudas` nvarchar(20) NOT NULL DEFAULT '',
	`CuentaGeneralAcreencias` nvarchar(20) NOT NULL DEFAULT '',
	`CuentaGeneralBancos` nvarchar(20) NOT NULL DEFAULT '',
	`CuentaGeneralCosto` nvarchar(20) NOT NULL DEFAULT '',
	`CuentaGeneralDevoluciones` nvarchar(20) NOT NULL DEFAULT '',
	`CuentaPasivoComisiones` nvarchar(20) NOT NULL DEFAULT '',
	`CuentaGastosComisiones` nvarchar(20) NOT NULL DEFAULT '',
	`CuentaImpuesto1` nvarchar(20) NOT NULL DEFAULT '',
	`CuentaImpuesto2` nvarchar(20) NOT NULL DEFAULT '',
	`CuentaCaja` nvarchar(20) NOT NULL DEFAULT '',
	`ProximaMaquina` int NOT NULL DEFAULT 0,
	`InicioVigenciaIDB` datetime(3) NOT NULL DEFAULT '20000101',
	`FinVigenciaIDB` datetime(3) NOT NULL DEFAULT '20000101',
	`PorcentajeIDB` Double NOT NULL DEFAULT 0,
	`CuentaGastosIDB` nvarchar(20) NOT NULL DEFAULT '',
	`CuentaISLRAnticipado` nvarchar(20) NOT NULL DEFAULT '',
	`CuentaEgresosComisionTC` nvarchar(50) NOT NULL DEFAULT '',
	`TipoInventarioEnCurso` smallint NOT NULL DEFAULT 0,
	`AlmacenInventarioFisico` nvarchar(8) NOT NULL DEFAULT '',
	`CuentaDescuentosCobranza` nvarchar(20) NOT NULL DEFAULT '',
	`CuentaDescuentosPagos` nvarchar(20) NOT NULL DEFAULT '',
	`CuentaMercanciaDanhada` nvarchar(20) NOT NULL DEFAULT '',
	`CuentaISLRRetenido` nvarchar(20) NOT NULL DEFAULT '',
	`Ciudad` nvarchar(20) NOT NULL DEFAULT '',
	`CuentaServicio` nvarchar(20) NOT NULL DEFAULT '',
	`ClaveActivacion` int NOT NULL DEFAULT 0,
	`TipoCambio` Decimal(19,4) NOT NULL DEFAULT 1,
	`CuentaMercanciaTransito` nvarchar(20) NOT NULL DEFAULT '',
	`Contribuyente` int NOT NULL DEFAULT 0,
	`PorcentajeRetencionIVACE` Double NOT NULL DEFAULT 0,
	`ValorActualUT` Decimal(19,4) NOT NULL DEFAULT 0,
	`CuentaDiferencias` nvarchar(20) NOT NULL DEFAULT '',
	`CuentaDeudoraConsignaciones` nvarchar(20) NOT NULL DEFAULT '',
	`CuentaAcreedoraConsignaciones` nvarchar(20) NOT NULL DEFAULT '',
	`CuentaIVACompras` nvarchar(20) NOT NULL DEFAULT '',
	`CuentaRetIVACompras` nvarchar(20) NOT NULL DEFAULT '',
	`CuentaRetIVAVentas` nvarchar(20) NOT NULL DEFAULT '',
	`ClaveActivacionV7` int NOT NULL DEFAULT 0,
	`ClaveActivacionV8` int NOT NULL DEFAULT 0,
	`Version` int NOT NULL DEFAULT 8005,
	`cuentaResultadosAEF` nvarchar(20) NOT NULL DEFAULT '',
	`nombreRIF` nvarchar(5) NOT NULL DEFAULT 'RIF',
	`cuentaGastosTransferencia` nvarchar(20) NOT NULL DEFAULT '',
	`cuentaAjustesCambiarios` nvarchar(20) NOT NULL DEFAULT '',
	`TipoCambio2` Decimal(19,4) NOT NULL DEFAULT 1,
	`claveActivacionV9` int NOT NULL DEFAULT 0,
	`clasificador1` nvarchar(10) NOT NULL DEFAULT 'linea',
	`clasificador2` nvarchar(10) NOT NULL DEFAULT 'grupo',
	`clasificador3` nvarchar(10) NOT NULL DEFAULT 'marca',
	`generoClasif1` tinyint Unsigned NOT NULL DEFAULT 0,
	`generoClasif2` tinyint Unsigned NOT NULL DEFAULT 1,
	`generoClasif3` tinyint Unsigned NOT NULL DEFAULT 0,
	`FormatoMEX` nvarchar(20) NOT NULL DEFAULT '$ #,##0.00',
	`ControlarPiezas` tinyint Unsigned NOT NULL DEFAULT 0,
	`PorcentajeIGTF456` Double NOT NULL DEFAULT 0,
	`claveActivacionV10` int NOT NULL DEFAULT 0,
	`cuentaIGTFRetenido` nvarchar(20) NOT NULL DEFAULT '',
	`cuentaIGTFPagado` nvarchar(20) NOT NULL DEFAULT '',
	`idEmpresa` smallint NOT NULL DEFAULT 0
);
/* SQLINES DEMO *** able [dbo].[PedidosAvila]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `PedidosAvila`(
	`fact_num` int NULL,
	`ped_num` int NULL,
	`enviado` Tinyint NULL,
	`rowguid` Char(36) NULL
);
/* SQLINES DEMO *** able [dbo].[pedidositemstemp ]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `pedidositemstemp `(
	`fact_num` int NULL,
	`co_art` char(30) NULL,
	`total_art` decimal(18, 5) NULL,
	`uni_venta` char(6) NULL,
	`prec_vta` decimal(18, 5) NULL,
	`tipo_imp` decimal(18, 2) NULL,
	`reng_neto` decimal(18, 5) NULL,
	`comentario` Longtext NULL
) ;
/* SQLINES DEMO *** able [dbo].[pedidostemp]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `pedidostemp`(
	`fact_num` int NULL,
	`co_cli` char(20) NULL,
	`co_ven` char(6) NULL,
	`forma_pag` char(6) NULL,
	`fec_emis` Datetime NULL,
	`tot_neto` decimal(18, 2) NULL,
	`iva` decimal(18, 2) NULL,
	`tot_bruto` decimal(18, 2) NULL,
	`comentario` Longtext NULL
) ;
/* SQLINES DEMO *** able [dbo].[perfilDescripcion]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `perfilDescripcion`(
	`CodigoPerfil` nvarchar(12) NOT NULL,
	`DescripcionPerfil` nvarchar(36) NOT NULL,
PRIMARY KEY 
(
	`CodigoPerfil` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[perfilElementos]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `perfilElementos`(
	`Valor` smallint NOT NULL,
	`Descripcion` nvarchar(48) NOT NULL,
	`Posicion` smallint NOT NULL
);
/* SQLINES DEMO *** able [dbo].[perfilesPermisos]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `perfilesPermisos`(
	`CodigoPerfil` nvarchar(12) NOT NULL,
	`Permiso` smallint NOT NULL
);
/* SQLINES DEMO *** able [dbo].[perfilesPrecios]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `perfilesPrecios`(
	`codigoPerfil` nvarchar(12) NOT NULL,
	`descripcion` nvarchar(30) NOT NULL,
	`indicePrecioBase` tinyint Unsigned NOT NULL,
	`porcentajeDescuento1` Double NOT NULL,
	`porcentajeDescuento2` Double NOT NULL,
	`baseDescuentoLinea` tinyint Unsigned NOT NULL,
	`isStrict` tinyint Unsigned NOT NULL DEFAULT 0,
PRIMARY KEY 
(
	`codigoPerfil` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[Prefijos]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `Prefijos`(
	`Prefijo` nvarchar(1) NOT NULL,
	`Uso` tinyint Unsigned NOT NULL DEFAULT 0,
PRIMARY KEY 
(
	`Prefijo` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[Proveedores]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `Proveedores`(
	`Codigo` nvarchar(20) NOT NULL,
	`Nombre` nvarchar(50) NOT NULL DEFAULT '',
	`RIF` nvarchar(20) NOT NULL DEFAULT '',
	`CGCuenta` nvarchar(20) NOT NULL DEFAULT '',
	`Condiciones` nvarchar(50) NOT NULL DEFAULT '',
	`Direccion` nvarchar(160) NOT NULL DEFAULT '',
	`Telefono` nvarchar(30) NOT NULL DEFAULT '',
	`SaldoActual` Decimal(19,4) NOT NULL DEFAULT 0,
	`LimiteCredito` Decimal(19,4) NOT NULL DEFAULT 0,
	`FechaUltimaCompra` datetime(3) NOT NULL DEFAULT '19000101',
	`Notas` nvarchar(255) NOT NULL DEFAULT '',
	`FechaCreacion` datetime(3) NOT NULL DEFAULT now(3),
	`Importacion` smallint NOT NULL DEFAULT 0,
	`TipoRetencion` tinyint Unsigned NOT NULL DEFAULT 1,
	`TipoPersona` tinyint Unsigned NOT NULL DEFAULT 2,
	`tipoCambio` Double NOT NULL DEFAULT 1,
	`TiempoEntrega` smallint NOT NULL DEFAULT 0,
	`ID` int AUTO_INCREMENT NOT NULL,
	`contribuyenteEspecial` tinyint Unsigned NOT NULL DEFAULT 0,
PRIMARY KEY 
(
	`Codigo` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[ProveedorProducto]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `ProveedorProducto`(
	`CodigoProveedor` nvarchar(20) NOT NULL DEFAULT '',
	`CodigoItem` nvarchar(20) NOT NULL DEFAULT '',
	`RefProductoProveedor` nvarchar(20) NULL DEFAULT '',
	`PrecioReferencia` Decimal(19,4) NOT NULL DEFAULT 0,
	`FechaOferta` datetime(3) NOT NULL DEFAULT now(3),
	`PrecioUltimaCompra` Decimal(19,4) NOT NULL DEFAULT 0,
	`FechaUltimaCompra` datetime(3) NOT NULL DEFAULT now(3),
	`Notas` nvarchar(255) NOT NULL DEFAULT ''
);
/* SQLINES DEMO *** able [dbo].[RelacionesIVARetenido]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `RelacionesIVARetenido`(
	`NumeroRetencion` bigint NOT NULL,
	`Fecha` datetime(3) NOT NULL,
	`Operador` nvarchar(20) NOT NULL,
	`AnhoFiscal` int NOT NULL,
	`Mes` int NOT NULL,
	`RifProveedor` nvarchar(13) NOT NULL,
	`NombreProveedor` nvarchar(50) NOT NULL,
	`Reporte` int NOT NULL DEFAULT 0,
PRIMARY KEY 
(
	`NumeroRetencion` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[renglonesComanda]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `renglonesComanda`(
	`numero` bigint AUTO_INCREMENT NOT NULL,
	`cuenta` int NOT NULL,
	`codigoItem` nvarchar(20) NOT NULL DEFAULT '',
	`porcentajeIVA` Double NOT NULL DEFAULT 0,
	`precio` Decimal(19,4) NOT NULL DEFAULT 0,
	`cantidad` Double NOT NULL DEFAULT 0,
	`descripcion` nvarchar(50) NOT NULL DEFAULT '',
	`usuario` nvarchar(20) NOT NULL DEFAULT '',
PRIMARY KEY 
(
	`numero` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[RenglonesConsumoSesion]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `RenglonesConsumoSesion`(
	`OwnerID` int NOT NULL DEFAULT 0,
	`Renglon` int NOT NULL DEFAULT 0,
	`Descripcion` nvarchar(255) NOT NULL DEFAULT ''
);
/* SQLINES DEMO *** able [dbo].[RenglonesCuentaPOS]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `RenglonesCuentaPOS`(
	`id` bigint AUTO_INCREMENT NOT NULL,
	`IDCuenta` int NOT NULL DEFAULT 0,
	`CodigoItem` nvarchar(20) NOT NULL DEFAULT '',
	`PrecioUnitario` Decimal(19,4) NOT NULL DEFAULT 0,
	`Cantidad` Double NOT NULL DEFAULT 0,
	`NumeroRenglon` int NOT NULL DEFAULT 0,
	`Usuario` nvarchar(20) NULL DEFAULT '',
	`Precio` Decimal(19,4) NOT NULL DEFAULT 0,
	`idCombo` int NOT NULL DEFAULT 0,
PRIMARY KEY 
(
	`id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[RenglonesFacturaPOS]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `RenglonesFacturaPOS`(
	`idMaquina` int NOT NULL DEFAULT 0,
	`numeroTicket` int NOT NULL DEFAULT 0,
	`numeroLinea` smallint NOT NULL DEFAULT 0,
	`Producto` nvarchar(20) NOT NULL DEFAULT '',
	`Cantidad` Double NOT NULL DEFAULT 0,
	`PrecioUnitario` Decimal(19,4) NOT NULL DEFAULT 0,
	`PorcentajeImpuesto` Double NOT NULL DEFAULT 0,
	`Usuario` nvarchar(20) NULL DEFAULT '',
	`NumeroFactura` int NOT NULL DEFAULT 0,
	`idCombo` int NOT NULL DEFAULT 0
);
/* SQLINES DEMO *** able [dbo].[RenglonesSesion]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `RenglonesSesion`(
	`SessionID` int NOT NULL DEFAULT 0,
	`NumeroRenglon` smallint NOT NULL DEFAULT 0,
	`CodigoItem` nvarchar(20) NOT NULL DEFAULT '',
	`PrecioUnitario` Decimal(19,4) NOT NULL DEFAULT 0,
	`Cantidad` Double NOT NULL DEFAULT 0,
	`PorcentajeImpuesto` Double NOT NULL DEFAULT 0,
	`TipoImpuesto` nvarchar(3) NOT NULL DEFAULT '',
	`PrecioLista` Decimal(19,4) NOT NULL DEFAULT 0,
	`Usuario` nvarchar(20) NULL DEFAULT '',
	`idCombo` int NOT NULL DEFAULT 0,
	`precioOriginal` Decimal(19,4) NOT NULL DEFAULT 0
);
/* SQLINES DEMO *** able [dbo].[RenglonesTransferencia]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `RenglonesTransferencia`(
	`NumeroTransferencia` int NOT NULL DEFAULT 0,
	`Renglon` smallint NOT NULL DEFAULT 0,
	`CodigoProducto` nvarchar(20) NOT NULL DEFAULT '',
	`Cantidad` Double NOT NULL DEFAULT 0,
	`CostoUnitario` Decimal(19,4) NOT NULL DEFAULT 0,
	`piezas` Double NOT NULL DEFAULT 0
);
/* SQLINES DEMO *** able [dbo].[RetencionesISLR]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `RetencionesISLR`(
	`Numero` int AUTO_INCREMENT NOT NULL,
	`tipoEntidadRelacionada` nvarchar(3) NOT NULL,
	`codigoEntidad` nvarchar(20) NOT NULL DEFAULT '',
	`fecha` datetime(3) NOT NULL DEFAULT now(3),
	`refDocumento` nvarchar(20) NOT NULL DEFAULT '',
	`totalPagado` Decimal(19,4) NOT NULL DEFAULT 0,
	`baseImponible` Decimal(19,4) NOT NULL DEFAULT 0,
	`porcentajeRetencion` Double NOT NULL DEFAULT 0,
	`montoRetenido` Decimal(19,4) NOT NULL DEFAULT 0,
	`numRef` int NULL DEFAULT 0,
	`TipoDoc` nvarchar(3) NOT NULL DEFAULT '',
	`NumDoc` int NOT NULL DEFAULT 0,
	`RIFSujeto` nvarchar(15) NOT NULL DEFAULT '',
	`NombreSujeto` nvarchar(50) NOT NULL DEFAULT '',
	`DireccionSujeto` nvarchar(160) NOT NULL DEFAULT '',
	`ConceptoRetencion` int NOT NULL DEFAULT 0,
	`TipoPersona` tinyint Unsigned NOT NULL DEFAULT 0,
PRIMARY KEY 
(
	`Numero` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[RetencionesIVA]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `RetencionesIVA`(
	`Id` int AUTO_INCREMENT NOT NULL,
	`CodigoCliente` nvarchar(20) NOT NULL DEFAULT '',
	`NumFactura` int NOT NULL DEFAULT 0,
	`FechaCobro` datetime(3) NOT NULL DEFAULT now(3),
	`MontoRetencion` Decimal(19,4) NOT NULL DEFAULT 0,
	`NumeroComprobante` bigint NOT NULL DEFAULT 0,
	`RefReporte` int NOT NULL DEFAULT 0,
	`tipoDoc` nvarchar(3) NOT NULL DEFAULT 'FCT',
	`Fecha` datetime(3) NULL DEFAULT now(3),
	`TipoDocFiscal` nvarchar(3) NULL DEFAULT 'FCT',
	`Referencia` nvarchar(30) NOT NULL DEFAULT '',
	`NumeroControlInicial` nvarchar(16) NOT NULL DEFAULT '',
	`Exento` Decimal(19,4) NOT NULL DEFAULT 0,
	`Gravable1` Decimal(19,4) NOT NULL DEFAULT 0,
	`Gravable2` Decimal(19,4) NOT NULL DEFAULT 0,
	`Impuesto1` Decimal(19,4) NOT NULL DEFAULT 0,
	`Impuesto2` Decimal(19,4) NOT NULL DEFAULT 0,
	`RifEntidad` nvarchar(14) NOT NULL DEFAULT '',
	`NombreEntidad` nvarchar(50) NOT NULL DEFAULT '',
PRIMARY KEY 
(
	`Id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[RetirosPOS]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `RetirosPOS`(
	`idSesion` int NOT NULL DEFAULT 0,
	`Hora` datetime(3) NOT NULL DEFAULT now(3),
	`Tipo` smallint NOT NULL DEFAULT 0,
	`Descripcion` nvarchar(50) NOT NULL DEFAULT '',
	`Monto` Decimal(19,4) NOT NULL DEFAULT 0
);
/* SQLINES DEMO *** able [dbo].[rislrConceptos]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `rislrConceptos`(
	`Id` int NOT NULL,
	`Codigo` nvarchar(50) NULL,
	`Descripcion` nvarchar(70) NULL,
	`Referencia` nvarchar(50) NULL,
	`orden` smallint NULL,
PRIMARY KEY 
(
	`Id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[rislrMetodos]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `rislrMetodos`(
	`Id` int AUTO_INCREMENT NOT NULL,
	`IdConcepto` int NULL,
	`TipoPersona` tinyint Unsigned NULL,
	`TipoMetodo` tinyint Unsigned NULL,
	`PorcentajeBase` Double NULL,
	`MontoMinimo` Decimal(19,4) NULL,
	`Deducible` Decimal(19,4) NULL,
	`Limite` Decimal(19,4) NULL,
	`Porcentaje` Double NULL,
	`Codigo` smallint NOT NULL DEFAULT 0,
PRIMARY KEY 
(
	`Id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[rislrParametrosT2]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `rislrParametrosT2`(
	`id` int AUTO_INCREMENT NOT NULL,
	`idMetodo` int NULL,
	`Hasta` Decimal(19,4) NULL,
	`Unidad` Tinyint NOT NULL,
	`Porcentaje` Double NULL,
PRIMARY KEY 
(
	`id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[rislrParametrosT3]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `rislrParametrosT3`(
	`id` int AUTO_INCREMENT PRIMARY KEY NOT NULL,
	`idMetodo` int NULL,
	`Archivo` nvarchar(128) NULL
);
/* SQLINES DEMO *** able [dbo].[rpBalanceGeneral]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `rpBalanceGeneral`(
	`CodigoCuenta` nvarchar(24) NOT NULL,
	`Titulo` nvarchar(70) NOT NULL,
	`SaldoNivel0` Double NOT NULL,
	`SaldoNivel1` Double NOT NULL,
	`SaldoNivel2` Double NOT NULL,
	`SaldoNivel3` Double NOT NULL
);
/* SQLINES DEMO *** able [dbo].[rwsDetallesOrden]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `rwsDetallesOrden`(
	`NumeroOrden` int NULL,
	`NumeroRenglon` int NULL,
	`CodigoProducto` nvarchar(20) NULL,
	`Descripcion` nvarchar(50) NULL,
	`PrecioUnitario` Decimal(19,4) NULL,
	`Cantidad` Double NULL
);
/* SQLINES DEMO *** able [dbo].[rwsEquipos]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `rwsEquipos`(
	`TipoEquipo` nvarchar(8) NULL,
	`Serial` nvarchar(20) NULL,
	`Propietario` nvarchar(20) NULL,
	`Notas` Longtext NULL,
	`Estado` smallint NULL,
	`Saldo` Decimal(19,4) NULL
) ;
/* SQLINES DEMO *** able [dbo].[rwsOrdenesTrabajo]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `rwsOrdenesTrabajo`(
	`Numero` int NOT NULL,
	`TipoEquipo` nvarchar(8) NULL,
	`Serial` nvarchar(20) NULL,
	`FechaRecepcion` Datetime NULL,
	`Sintomas` Longtext NULL,
	`Estado` smallint NULL,
	`Tecnico` nvarchar(20) NULL,
	`Notas` Longtext NULL,
	`Factura` int NULL,
PRIMARY KEY 
(
	`Numero` ASC
) 
) ;
/* SQLINES DEMO *** able [dbo].[rwsTiposEquipo]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `rwsTiposEquipo`(
	`Codigo` nvarchar(8) NOT NULL,
	`Descripcion` nvarchar(30) NULL,
PRIMARY KEY 
(
	`Codigo` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[saldoEfectivoSesion]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `saldoEfectivoSesion`(
	`id` int AUTO_INCREMENT NOT NULL,
	`idSesion` int NOT NULL DEFAULT 0,
	`machineID` int NOT NULL,
	`efectivoMN` Decimal(19,4) NOT NULL,
PRIMARY KEY 
(
	`id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[SaldosEntidadPeriodo]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `SaldosEntidadPeriodo`(
	`TipoEntidad` nvarchar(3) NOT NULL DEFAULT '',
	`CodigoEntidad` nvarchar(20) NOT NULL DEFAULT '',
	`NumeroPeriodo` int NOT NULL DEFAULT 0,
	`SaldoInicial` Decimal(19,4) NOT NULL DEFAULT 0,
	`Debitos` Decimal(19,4) NOT NULL DEFAULT 0,
	`Creditos` Decimal(19,4) NOT NULL DEFAULT 0
);
/* SQLINES DEMO *** able [dbo].[SaldosPeriodo]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `SaldosPeriodo`(
	`CodigoCuenta` nvarchar(20) NOT NULL DEFAULT '',
	`NumeroPeriodo` int NOT NULL DEFAULT 0,
	`SaldoInicial` Double NOT NULL DEFAULT 0,
	`Debitos` Double NOT NULL DEFAULT 0,
	`Creditos` Double NOT NULL DEFAULT 0
);
/* SQLINES DEMO *** able [dbo].[saveDenominaciones]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `saveDenominaciones`(
	`id` bigint AUTO_INCREMENT NOT NULL,
	`idDetalle` int NOT NULL,
	`Denominacion` Decimal(19,4) NOT NULL,
	`CantidadRecibida` int NOT NULL,
PRIMARY KEY 
(
	`id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[saveDetallesCaja]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `saveDetallesCaja`(
	`id` int AUTO_INCREMENT NOT NULL,
	`transID` int NOT NULL,
	`Medio` nvarchar(8) NOT NULL,
	`Emisor` nvarchar(20) NOT NULL,
	`numeroDocumento` nvarchar(20) NOT NULL,
	`claveAutorizacion` nvarchar(6) NOT NULL,
	`monto` Decimal(19,4) NOT NULL,
	`numeroCuenta` nvarchar(20) NOT NULL,
	`idTitular` nvarchar(20) NOT NULL,
	`montoNominal` Decimal(19,4) NOT NULL,
PRIMARY KEY 
(
	`id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[saveMovsCaja]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `saveMovsCaja`(
	`id` int AUTO_INCREMENT NOT NULL,
	`clave` nvarchar(20) NOT NULL,
PRIMARY KEY 
(
	`id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[Seriales]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `Seriales`(
	`CodigoItem` nvarchar(20) NOT NULL DEFAULT '',
	`Serial` nvarchar(20) NOT NULL DEFAULT '',
	`EnStock` smallint NOT NULL DEFAULT 0,
	`Locked` smallint NOT NULL DEFAULT 0
);
/* SQLINES DEMO *** able [dbo].[serialesCuentaPOS]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `serialesCuentaPOS`(
	`id` int AUTO_INCREMENT NOT NULL,
	`idCuenta` int NOT NULL,
	`renglon` smallint NOT NULL,
	`codigoArticulo` nvarchar(20) NOT NULL,
	`serial` nvarchar(20) NOT NULL,
PRIMARY KEY 
(
	`id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[SerialesDetalles]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `SerialesDetalles`(
	`NumeroDetalle` int NOT NULL DEFAULT 0,
	`CodigoItem` nvarchar(20) NOT NULL DEFAULT '',
	`Serial` nvarchar(20) NOT NULL DEFAULT '',
	`TipoDocumento` nvarchar(5) NOT NULL DEFAULT '',
	`NumeroDocumento` int NOT NULL DEFAULT 0,
	`Renglon` smallint NOT NULL DEFAULT 0,
	`Tipo` int NOT NULL DEFAULT 0,
	`FechaTransaccion` datetime(3) NOT NULL DEFAULT now(3),
	`isTemporal` int NOT NULL DEFAULT 0,
	`prevStatus` smallint NOT NULL DEFAULT 0
);
/* SQLINES DEMO *** able [dbo].[serialesSesion]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `serialesSesion`(
	`id` int AUTO_INCREMENT NOT NULL,
	`sesion` int NOT NULL,
	`renglon` smallint NOT NULL,
	`codigoArticulo` nvarchar(20) NOT NULL,
	`serial` nvarchar(20) NOT NULL,
PRIMARY KEY 
(
	`id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[Series]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `Series`(
	`CodigoSerie` nvarchar(3) NOT NULL DEFAULT '',
	`Descripcion` nvarchar(24) NOT NULL DEFAULT '',
	`CuentaIngreso` nvarchar(50) NOT NULL DEFAULT '',
	`ProximaFactura` int NOT NULL DEFAULT 0,
	`ProximaNota` int NOT NULL DEFAULT 1,
	`CuentaImpuesto1` nvarchar(20) NOT NULL DEFAULT '',
	`CuentaImpuesto2` nvarchar(20) NOT NULL DEFAULT '',
	`CuentaCosto` nvarchar(20) NOT NULL DEFAULT '',
	`Nivel` smallint NOT NULL DEFAULT 0,
PRIMARY KEY 
(
	`CodigoSerie` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[SesionesRemotas]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `SesionesRemotas`(
	`NumeroSesion` int NOT NULL,
	`MachineID` int NOT NULL,
	`SesionLocal` int NOT NULL,
	`Almacen` nvarchar(20) NOT NULL DEFAULT '',
 /* Name ignored: CONSTRAINT `PK_SesionesRemotas` */ PRIMARY KEY 
(
	`NumeroSesion` ASC,
	`MachineID` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[solicitudesAutorizacion]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `solicitudesAutorizacion`(
	`id` bigint AUTO_INCREMENT NOT NULL,
	`usuario` nvarchar(20) NOT NULL,
	`terminal` int NOT NULL,
	`request` nvarchar(255) NOT NULL,
	`autorizadaPor` nvarchar(8) NOT NULL DEFAULT '',
	`hora` datetime(3) NOT NULL DEFAULT now(3),
PRIMARY KEY 
(
	`id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[subDocsMB]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `subDocsMB`(
	`ID` int AUTO_INCREMENT PRIMARY KEY NOT NULL,
	`TransID` int NOT NULL,
	`TipoDoc` nvarchar(3) NOT NULL,
	`NumDoc` int NOT NULL,
	`Debitos` Decimal(19,4) NOT NULL,
	`Creditos` Decimal(19,4) NOT NULL
);
/* SQLINES DEMO *** able [dbo].[subDocsMC]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `subDocsMC`(
	`ID` int AUTO_INCREMENT PRIMARY KEY NOT NULL,
	`TransID` int NOT NULL,
	`TipoDoc` nvarchar(3) NOT NULL,
	`NumDoc` int NOT NULL,
	`Debitos` Decimal(19,4) NOT NULL,
	`Creditos` Decimal(19,4) NOT NULL
);
/* SQLINES DEMO *** able [dbo].[SubLineas]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `SubLineas`(
	`Codigo` nvarchar(8) NOT NULL,
	`Descripcion` nvarchar(30) NOT NULL DEFAULT '',
PRIMARY KEY 
(
	`Codigo` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[SyncQueue]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `SyncQueue`(
	`id` bigint AUTO_INCREMENT NOT NULL,
	`cmdCode` nvarchar(12) NOT NULL,
	`objectID` int NOT NULL,
PRIMARY KEY 
(
	`id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[TarjetasCredito]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `TarjetasCredito`(
	`Codigo` nvarchar(8) NOT NULL,
	`Nombre` nvarchar(16) NOT NULL DEFAULT '',
	`Banco` nvarchar(20) NOT NULL DEFAULT '',
	`PorcentajeComision` Double NOT NULL DEFAULT 0,
	`PorcentajeISLR` Double NOT NULL DEFAULT 0,
	`CuentaComision` nvarchar(20) NOT NULL DEFAULT '',
	`CuentaISLR` nvarchar(50) NOT NULL DEFAULT '',
PRIMARY KEY 
(
	`Codigo` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[TempAjustes]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `TempAjustes`(
	`Numero` int AUTO_INCREMENT NOT NULL,
	`Fecha` Datetime NOT NULL DEFAULT now(3),
	`refAjuste` nvarchar(20) NOT NULL DEFAULT '',
	`Tipo` Tinyint NOT NULL DEFAULT 0,
	`Descripcion` nvarchar(50) NOT NULL DEFAULT '',
	`Notas` nvarchar(255) NOT NULL DEFAULT '',
	`Contrapartida` nvarchar(20) NOT NULL DEFAULT '',
	`Almacen` nvarchar(8) NOT NULL DEFAULT '',
PRIMARY KEY 
(
	`Numero` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[TiposCliente]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `TiposCliente`(
	`Codigo` nvarchar(8) NOT NULL,
	`Descripcion` nvarchar(50) NOT NULL DEFAULT '',
PRIMARY KEY 
(
	`Codigo` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[TiposCuentaPOS]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `TiposCuentaPOS`(
	`Prefijo` nvarchar(3) NOT NULL DEFAULT '',
	`Base` int NOT NULL DEFAULT 0,
	`Porcentaje` Double NOT NULL DEFAULT 0,
	`IndicePrecio` smallint NOT NULL DEFAULT 0
);
/* SQLINES DEMO *** able [dbo].[TiposImpuesto]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `TiposImpuesto`(
	`Codigo` nvarchar(3) NOT NULL,
	`Descripcion` nvarchar(30) NOT NULL DEFAULT '',
	`Porcentaje` Double NOT NULL DEFAULT 0,
	`VigenteDesde` datetime(3) NOT NULL DEFAULT '19000101',
	`VigenteHasta` datetime(3) NULL DEFAULT '18991231',
	`Cuenta` nvarchar(20) NOT NULL DEFAULT '',
PRIMARY KEY 
(
	`Codigo` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[tmpResumenPOS]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `tmpResumenPOS`(
	`Sesion` int NOT NULL,
	`Producto` nvarchar(20) NOT NULL,
	`Precio` Decimal(19,4) NOT NULL,
	`Cantidad` Double NOT NULL,
	`PorcentajeImpuesto` Double NOT NULL,
	`Fecha` datetime(3) NOT NULL
);
/* SQLINES DEMO *** able [dbo].[tmpTransferencias]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `tmpTransferencias`(
	`ID` int AUTO_INCREMENT NOT NULL,
	`Descripcion` nvarchar(50) NOT NULL DEFAULT '',
	`Notas` nvarchar(255) NOT NULL DEFAULT '',
	`FechaRegistro` datetime(3) NOT NULL DEFAULT now(3),
	`Operador` nvarchar(12) NOT NULL DEFAULT '',
	`AlmacenOrigen` nvarchar(8) NOT NULL DEFAULT '',
	`AlmacenDestino` nvarchar(8) NOT NULL DEFAULT '',
	`extRef` nvarchar(20) NOT NULL DEFAULT '',
	`Clasificacion` nvarchar(20) NOT NULL DEFAULT '',
PRIMARY KEY 
(
	`ID` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[tmpTransferenciasDetalles]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `tmpTransferenciasDetalles`(
	`Renglon` int AUTO_INCREMENT NOT NULL,
	`transID` int NOT NULL DEFAULT 0,
	`CodigoItem` nvarchar(20) NOT NULL DEFAULT '',
	`Cantidad` Double NOT NULL DEFAULT 0,
	`piezas` Double NOT NULL DEFAULT 0,
PRIMARY KEY 
(
	`Renglon` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[transaccionEfectivoDetalles]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `transaccionEfectivoDetalles`(
	`id` bigint AUTO_INCREMENT NOT NULL,
	`transId` int NOT NULL DEFAULT 0,
	`codigoMedio` nvarchar(8) NOT NULL DEFAULT '',
	`valorMN` Decimal(19,4) NOT NULL DEFAULT 0,
	`valorNominal` Decimal(19,4) NOT NULL DEFAULT 0,
PRIMARY KEY 
(
	`id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[TransaccionesEfectivo]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `TransaccionesEfectivo`(
	`id` int AUTO_INCREMENT NOT NULL,
	`tipoTrans` tinyint Unsigned NOT NULL,
	`idOrigen` int NOT NULL,
	`machineID` int NOT NULL,
	`efectivoMN` Decimal(19,4) NOT NULL,
PRIMARY KEY 
(
	`id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[Transferencias]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `Transferencias`(
	`Numero` int NOT NULL,
	`FechaRegistro` datetime(3) NOT NULL DEFAULT now(3),
	`FechaTransferencia` datetime(3) NOT NULL DEFAULT now(3),
	`Operador` nvarchar(8) NOT NULL DEFAULT '',
	`AlmacenOrigen` nvarchar(8) NOT NULL DEFAULT '',
	`AlmacenDestino` nvarchar(8) NOT NULL DEFAULT '',
	`Descripcion` nvarchar(50) NOT NULL DEFAULT '',
	`Notas` nvarchar(255) NOT NULL DEFAULT '',
	`extRef` nvarchar(20) NOT NULL DEFAULT '',
	`Clasificacion` nvarchar(20) NOT NULL DEFAULT '',
PRIMARY KEY 
(
	`Numero` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[transferenciasCajas]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `transferenciasCajas`(
	`id` int AUTO_INCREMENT NOT NULL,
	`fecha` datetime(3) NOT NULL DEFAULT now(3),
	`operador` nvarchar(8) NOT NULL,
	`descripcion` nvarchar(40) NOT NULL,
	`cajaOrigen` int NOT NULL,
	`cajaDestino` int NOT NULL,
	`montoTotal` Decimal(19,4) NOT NULL,
	`sesionOrigen` int NOT NULL,
	`sesionDestino` int NOT NULL,
PRIMARY KEY 
(
	`id` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[Unidades]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `Unidades`(
	`Codigo` nvarchar(12) NOT NULL DEFAULT '',
	`Unidad` nvarchar(20) NOT NULL DEFAULT '',
	`Equivalencia` nvarchar(20) NOT NULL DEFAULT '',
	`Factor` Double NOT NULL DEFAULT 0
);
/* SQLINES DEMO *** able [dbo].[Usuarios]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `Usuarios`(
	`Codigo` nvarchar(8) NOT NULL,
	`Clave` int NOT NULL DEFAULT 0,
	`Nivel` tinyint Unsigned NOT NULL DEFAULT 0,
	`Nombre` nvarchar(40) NOT NULL DEFAULT '',
	`Perfil` nvarchar(12) NOT NULL DEFAULT '',
	`uniqid` nvarchar(23) NOT NULL DEFAULT '',
	`tema` nvarchar(20) NOT NULL DEFAULT 'Default',
	`ID` int AUTO_INCREMENT NOT NULL,
PRIMARY KEY 
(
	`Codigo` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[valoresCaja]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `valoresCaja`(
	`Numero` int AUTO_INCREMENT PRIMARY KEY NOT NULL,
	`nSesion` int NOT NULL,
	`MachineID` int NOT NULL,
	`TipoDoc` nvarchar(3) NOT NULL,
	`NumDoc` int NOT NULL,
	`MedioPago` smallint NOT NULL,
	`Emisor` nvarchar(20) NOT NULL,
	`NumCuenta` nvarchar(20) NOT NULL,
	`RefDocumento` nvarchar(20) NOT NULL,
	`ClaveAut` nvarchar(8) NOT NULL,
	`Fecha` datetime(3) NOT NULL,
	`Monto` Decimal(19,4) NOT NULL
);
/* SQLINES DEMO *** able [dbo].[VencimientosISPC]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `VencimientosISPC`(
	`NumeroDocumento` int NOT NULL DEFAULT 0,
	`FechaVencimiento` datetime(3) NOT NULL DEFAULT now(3),
	`Monto` Decimal(19,4) NOT NULL DEFAULT 0
);
/* SQLINES DEMO *** able [dbo].[Vendedores]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `Vendedores`(
	`Codigo` nvarchar(15) NOT NULL,
	`Nombre` nvarchar(50) NOT NULL DEFAULT '',
	`CI` nvarchar(12) NOT NULL DEFAULT '',
	`Direccion` nvarchar(160) NOT NULL DEFAULT '',
	`Telefono` nvarchar(30) NOT NULL DEFAULT '',
	`NoCobraComision` smallint NOT NULL DEFAULT 0,
	`TipoComisionVenta` smallint NOT NULL DEFAULT 0,
	`TipoComisionCobranza` smallint NOT NULL DEFAULT 0,
	`SaldoActual` Decimal(19,4) NOT NULL DEFAULT 0,
	`CuentaPasivo` nvarchar(20) NOT NULL DEFAULT '',
	`FechaCreacion` datetime(3) NOT NULL DEFAULT now(3),
	`ID` int AUTO_INCREMENT NOT NULL,
PRIMARY KEY 
(
	`Codigo` ASC
) 
);
/* SQLINES DEMO *** able [dbo].[Zonas]    Script Date: 28/3/2025 3:56:58 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
CREATE TABLE `Zonas`(
	`Codigo` nvarchar(8) NOT NULL DEFAULT '',
	`Descripcion` nvarchar(30) NOT NULL DEFAULT '',
	`latitud` Double NOT NULL DEFAULT 0,
	`longitud` Double NOT NULL DEFAULT 0,
PRIMARY KEY 
(
	`Codigo` ASC
) 
);
/* SQLINES DEMO *** ndex [ndxSesion]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `ndxSesion` ON `adelantosEfectivo`
(
	`idSesion` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [Referencia]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `Referencia` ON `Ajustes`
(
	`refAjuste` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [Descripcion]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `Descripcion` ON `Almacenes`
(
	`Nombre` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [ItemsVentaAlternosItemVenta]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `ItemsVentaAlternosItemVenta` ON `AlternosItemVenta`
(
	`CodigoItemVenta` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [ItemVenta]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `ItemVenta` ON `AlternosItemVenta`
(
	`CodigoItemVenta` ASC,
	`CodigoAlterno` ASC
) ;
 
/* SQLINES DEMO *** ndex [ndx_ID]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `ndx_ID` ON `AlternosItemVenta`
(
	`ID` ASC
) ;
 
/* SQLINES DEMO *** ndex [ndxIdAtributos]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `ndxIdAtributos` ON `Atributos`
(
	`ID` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [PorAtributo]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `PorAtributo` ON `Atributos`
(
	`CodigoAtributo` ASC,
	`ValorAtributo` ASC,
	`TipoEntidad` ASC,
	`CodigoEntidad` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [IX_atributosDescriptor]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `IX_atributosDescriptor` ON `atributosDescriptor`
(
	`tipoEntidad` ASC,
	`codigoAtributo` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [NDX_BalancesMEX]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `NDX_BalancesMEX` ON `BalancesMensualesMEX`
(
	`TipoEntidad` ASC,
	`CodigoEntidad` ASC,
	`IndicePeriodo` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [IndiceNombre]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IndiceNombre` ON `Bancos`
(
	`Nombre` ASC
) ;
 
/* SQLINES DEMO *** ndex [ndxIdBancos]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `ndxIdBancos` ON `Bancos`
(
	`id` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [ix_ChequesDevueltosCliente]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `ix_ChequesDevueltosCliente` ON `ChequesDevueltos`
(
	`CodigoCliente` ASC,
	`FechaDevolucion` ASC
) ;
 
/* SQLINES DEMO *** ndex [IFecha]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IFecha` ON `CierresZ`
(
	`Apertura` ASC
) ;
 
/* SQLINES DEMO *** ndex [ndx_Terminal]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `ndx_Terminal` ON `CierresZ`
(
	`idTerminal` ASC,
	`Numero` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [IndiceNombre]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IndiceNombre` ON `Clientes`
(
	`Nombre` ASC
) ;
 
/* SQLINES DEMO *** ndex [NDXIDCLIENTES]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `NDXIDCLIENTES` ON `Clientes`
(
	`ID` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [RIF]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `RIF` ON `Clientes`
(
	`RIF` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [Ruta]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `Ruta` ON `Clientes`
(
	`Ruta` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [Zona]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `Zona` ON `Clientes`
(
	`Zona` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [IX_Cobranzas_VendedorFecha]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IX_Cobranzas_VendedorFecha` ON `Cobranzas`
(
	`codVend` ASC,
	`Fecha` ASC
) ;
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `PrimaryKey` ON `CobrosPOS`
(
	`SessionID` ASC,
	`Hora` ASC
) ;
 
/* SQLINES DEMO *** ndex [SesionesPOSCobrosPOS]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `SesionesPOSCobrosPOS` ON `CobrosPOS`
(
	`SessionID` ASC
) ;
 
/* SQLINES DEMO *** ndex [IX_CobrosPostdatadosFecha]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IX_CobrosPostdatadosFecha` ON `CobrosPostdatados`
(
	`FechaPresentacion` ASC
) ;
 
/* SQLINES DEMO *** ndex [IX_CobrosPostdatadosMedios]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IX_CobrosPostdatadosMedios` ON `CobrosPostdatadosMedios`
(
	`idCobro` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [IndiceItemInv]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IndiceItemInv` ON `ComposicionItemsInventario`
(
	`CodigoItemInventario` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [IndiceItemInv]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IndiceItemInv` ON `ComposicionItemsVenta`
(
	`CodigoItemInventario` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [ItemsVentaComposicionItemsVenta]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `ItemsVentaComposicionItemsVenta` ON `ComposicionItemsVenta`
(
	`CodigoItemVenta` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [ProveedoresCompras]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `ProveedoresCompras` ON `Compras`
(
	`CodigoProveedor` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [RefProveedor]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `RefProveedor` ON `Compras`
(
	`CodigoProveedor` ASC,
	`RefProveedor` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [SecuencialProveedor]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `SecuencialProveedor` ON `Compras`
(
	`CodigoProveedor` ASC,
	`FechaTransaccion` ASC,
	`Numero` ASC
) ;
 
/* SQLINES DEMO *** ndex [CorrPeriodo]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `CorrPeriodo` ON `Comprobantes`
(
	`Periodo` ASC,
	`CorrelativoPeriodo` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [Referencia]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `Referencia` ON `Comprobantes`
(
	`Referencia` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [AlmacenesComprobantesAlmacen]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `AlmacenesComprobantesAlmacen` ON `ComprobantesAlmacen`
(
	`Almacen` ASC
) ;
 
/* SQLINES DEMO *** ndex [IndiceFecha]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IndiceFecha` ON `ComprobantesAlmacen`
(
	`FechaRegistro` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [IndiceOrigen]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IndiceOrigen` ON `ComprobantesAlmacen`
(
	`TipoEntidadOrigen` ASC,
	`NumeroDocumentoOrigen` ASC
) ;
 
/* SQLINES DEMO *** ndex [OrdenDespacho]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `OrdenDespacho` ON `ComprobantesAlmacen`
(
	`OrdenDespacho` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [ndxConciliacionesBanco]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `ndxConciliacionesBanco` ON `Conciliaciones`
(
	`CodigoBanco` ASC,
	`FechaEC` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [IX_Liquidada]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IX_Liquidada` ON `ConsignacionesCompra`
(
	`Liquidada` ASC,
	`CodigoProveedor` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [IX_ProvFecha]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IX_ProvFecha` ON `ConsignacionesCompra`
(
	`CodigoProveedor` ASC,
	`FechaTransaccion` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [IX_ProvRef]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IX_ProvRef` ON `ConsignacionesCompra`
(
	`CodigoProveedor` ASC,
	`RefProveedor` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [IX_Item]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IX_Item` ON `ConsignacionesDetalles`
(
	`CodigoItem` ASC,
	`NumeroConsignacion` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [IX_ItemConsignacion]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IX_ItemConsignacion` ON `ConsignacionesDetalles`
(
	`NumeroConsignacion` ASC,
	`CodigoItem` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [IX_ItemsConsignados]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IX_ItemsConsignados` ON `ConsignacionesDetalles`
(
	`Pendientes` ASC,
	`CodigoItem` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `Contactos`
(
	`CodigoEntidad` ASC,
	`TipoEntidad` ASC,
	`NombreContacto` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [Cliente]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `Cliente` ON `Cotizaciones`
(
	`CodigoCliente` ASC,
	`FechaTransaccion` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [ClientesCotizaciones]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `ClientesCotizaciones` ON `Cotizaciones`
(
	`CodigoCliente` ASC
) ;
 
/* SQLINES DEMO *** ndex [Fecha]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `Fecha` ON `Cotizaciones`
(
	`FechaTransaccion` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [Vendedor]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `Vendedor` ON `Cotizaciones`
(
	`CodigoVendedor` ASC,
	`FechaTransaccion` ASC
) ;
 
/* SQLINES DEMO *** ndex [CotizacionesCotizacionesDetalles]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `CotizacionesCotizacionesDetalles` ON `CotizacionesDetalles`
(
	`NumeroDocumento` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [IndiceItem]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IndiceItem` ON `CotizacionesDetalles`
(
	`CodigoItem` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [ItemFactura]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `ItemFactura` ON `CotizacionesDetalles`
(
	`NumeroDocumento` ASC,
	`CodigoItem` ASC
) ;
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `CotizacionesDetalles`
(
	`NumeroDocumento` ASC,
	`Renglon` ASC
) ;
 
/* SQLINES DEMO *** ndex [CotizacionesDetallesCotizacionesEntregas]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `CotizacionesDetallesCotizacionesEntregas` ON `CotizacionesEntregas`
(
	`NumeroCotizacion` ASC,
	`NumeroRenglon` ASC
) ;
 
/* SQLINES DEMO *** ndex [CotizacionesEntregasNumeroDocumento]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `CotizacionesEntregasNumeroDocumento` ON `CotizacionesEntregas`
(
	`NumeroDocumento` ASC
) ;
 
/* SQLINES DEMO *** ndex [NumeroCotizacion]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `NumeroCotizacion` ON `CotizacionesEntregas`
(
	`NumeroCotizacion` ASC,
	`NumeroRenglon` ASC,
	`Fecha` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [IndiceTitulo]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IndiceTitulo` ON `Cuentas`
(
	`Titulo` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [ndxCuentasAlterno]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `ndxCuentasAlterno` ON `Cuentas`
(
	`Alterno` ASC
) ;
 
/* SQLINES DEMO *** ndex [ndx_CuentaPOS_Owner]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `ndx_CuentaPOS_Owner` ON `CuentasPOS`
(
	`tipo` ASC,
	`ownerID` ASC
) ;
 
/* SQLINES DEMO *** ndex [ndx_DescuentosSesion_Sesion]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `ndx_DescuentosSesion_Sesion` ON `DescuentosSesion`
(
	`sesion` ASC
) ;
 
/* SQLINES DEMO *** ndex [ComprobantesDetalles]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `ComprobantesDetalles` ON `Detalles`
(
	`NumeroComprobante` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [CuentasDetalles]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `CuentasDetalles` ON `Detalles`
(
	`Cuenta` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [IndicePorCuenta]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IndicePorCuenta` ON `Detalles`
(
	`Cuenta` ASC,
	`RefPeriodo` ASC,
	`NumeroComprobante` ASC,
	`NumeroLinea` ASC
) ;
 
/* SQLINES DEMO *** ndex [IX_DetallesAnul]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IX_DetallesAnul` ON `DetallesAnulacionPOS`
(
	`numDevol` ASC,
	`idDetalle` ASC
) ;
 
/* SQLINES DEMO *** ndex [ComprasDetallesCompra]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `ComprasDetallesCompra` ON `DetallesCompra`
(
	`NumeroDocumento` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [iCodigoItem]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `iCodigoItem` ON `DetallesCompra`
(
	`CodigoItem` ASC,
	`NumeroDocumento` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [dceDocOrigen]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `dceDocOrigen` ON `DetallesCuentaEntidad`
(
	`TipoDocOrigen` ASC,
	`NumeroDocOrigen` ASC
) ;
 
/* SQLINES DEMO *** ndex [SecuenciaDocumento]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `SecuenciaDocumento` ON `DetallesCuentaEntidad`
(
	`Documento` ASC,
	`Fecha` ASC,
	`Correlativo` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [SecuenciaEntidad]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `SecuenciaEntidad` ON `DetallesCuentaEntidad`
(
	`CodigoEntidad` ASC,
	`TipoEntidad` ASC,
	`Fecha` ASC,
	`Correlativo` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [SecuenciaPeriodo]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `SecuenciaPeriodo` ON `DetallesCuentaEntidad`
(
	`CodigoEntidad` ASC,
	`TipoEntidad` ASC,
	`RefPeriodo` ASC,
	`Correlativo` ASC
) ;
 
/* SQLINES DEMO *** ndex [idxDetallesDenominacionDetalle]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `idxDetallesDenominacionDetalle` ON `DetallesDenominacion`
(
	`IdDetalle` ASC,
	`Id` ASC
) ;
 
/* SQLINES DEMO *** ndex [idxDetallesDenominacionID]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `idxDetallesDenominacionID` ON `DetallesDenominacion`
(
	`Id` ASC
) ;
 
/* SQLINES DEMO *** ndex [DevolucionesCompraDetallesDevolucionCompra]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `DevolucionesCompraDetallesDevolucionCompra` ON `DetallesDevolucionCompra`
(
	`numeroDevolucion` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [Item]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `Item` ON `DetallesDevolucionCompra`
(
	`codigoItem` ASC,
	`numeroDevolucion` ASC
) ;
 
/* SQLINES DEMO *** ndex [DevolucionesVentaDetallesDevolucionVenta]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `DevolucionesVentaDetallesDevolucionVenta` ON `DetallesDevolucionVenta`
(
	`NumeroDevolucion` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [Item]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `Item` ON `DetallesDevolucionVenta`
(
	`CodigoItemVenta` ASC,
	`NumeroDevolucion` ASC
) ;
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `DetallesDevolucionVenta`
(
	`NumeroDevolucion` ASC,
	`NumeroRenglon` ASC
) ;
 
/* SQLINES DEMO *** ndex [FacturasDetallesFactura]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `FacturasDetallesFactura` ON `DetallesFactura`
(
	`NumeroDocumento` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [IndiceItem]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IndiceItem` ON `DetallesFactura`
(
	`CodigoItem` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [ItemFactura]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `ItemFactura` ON `DetallesFactura`
(
	`NumeroDocumento` ASC,
	`CodigoItem` ASC
) ;
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `DetallesFactura`
(
	`NumeroDocumento` ASC,
	`Renglon` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [idxDetallesIngresoCajaMedioEmisor]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `idxDetallesIngresoCajaMedioEmisor` ON `DetallesIngresoCaja`
(
	`Medio` ASC,
	`Emisor` ASC
) ;
 
/* SQLINES DEMO *** ndex [idxDetallesIngresoCajaTransID]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `idxDetallesIngresoCajaTransID` ON `DetallesIngresoCaja`
(
	`TransID` ASC,
	`id` ASC
) ;
 
/* SQLINES DEMO *** ndex [MovimientosCajaDetallesIngresoCaja]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `MovimientosCajaDetallesIngresoCaja` ON `DetallesIngresoCaja`
(
	`TransID` ASC
) ;
 
/* SQLINES DEMO *** ndex [TransID]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `TransID` ON `DetallesIngresoCaja`
(
	`TransID` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [Cliente]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `Cliente` ON `DetallesItemVenta`
(
	`CodigoCliente` ASC,
	`FechaOperacion` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [IndiceDocumento]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IndiceDocumento` ON `DetallesItemVenta`
(
	`TipoDocumento` ASC,
	`NumeroDocumento` ASC,
	`CodigoItem` ASC,
	`PrecioVenta` ASC
) ;
 
/* SQLINES DEMO *** ndex [IndiceFecha]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IndiceFecha` ON `DetallesItemVenta`
(
	`FechaOperacion` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [Item]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `Item` ON `DetallesItemVenta`
(
	`CodigoItem` ASC,
	`FechaOperacion` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [ItemCliente]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `ItemCliente` ON `DetallesItemVenta`
(
	`CodigoCliente` ASC,
	`CodigoItem` ASC,
	`FechaOperacion` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [ItemsVentaDetallesItemVenta]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `ItemsVentaDetallesItemVenta` ON `DetallesItemVenta`
(
	`CodigoItem` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [ItemVendedor]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `ItemVendedor` ON `DetallesItemVenta`
(
	`CodigoVendedor` ASC,
	`CodigoItem` ASC,
	`FechaOperacion` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [ndxPOS]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `ndxPOS` ON `DetallesItemVenta`
(
	`NumeroDocumento` ASC,
	`TipoDocumento` ASC,
	`CodigoItem` ASC,
	`CodigoVendedor` ASC,
	`CodigoCliente` ASC,
	`PrecioVenta` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [Vendedor]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `Vendedor` ON `DetallesItemVenta`
(
	`CodigoVendedor` ASC,
	`CodigoItem` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [IndiceFecha]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IndiceFecha` ON `DetallesMINV`
(
	`FechaOperacion` ASC,
	`CodigoItem` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [IndiceItem]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IndiceItem` ON `DetallesMINV`
(
	`CodigoItem` ASC,
	`FechaOperacion` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [ItemDocumento]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `ItemDocumento` ON `DetallesMINV`
(
	`NumeroDocumento` ASC,
	`CodigoItem` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [itemsInventarioDetallesMINV]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `itemsInventarioDetallesMINV` ON `DetallesMINV`
(
	`CodigoItem` ASC
) ;
 
/* SQLINES DEMO *** ndex [IX_NumDocumento]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IX_NumDocumento` ON `DetallesMINV`
(
	`NumeroDocumento` ASC
) ;
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `DetallesMINV`
(
	`NumeroDocumento` ASC,
	`Renglon` ASC
) ;
 
/* SQLINES DEMO *** ndex [Numero]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `Numero` ON `DevolucionesCompra`
(
	`Numero` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [ProveedoresDevolucionesCompra]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `ProveedoresDevolucionesCompra` ON `DevolucionesCompra`
(
	`CodigoProveedor` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [ClientesDevolucionesVenta]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `ClientesDevolucionesVenta` ON `DevolucionesVenta`
(
	`CodigoCliente` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [iCliente]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `iCliente` ON `DevolucionesVenta`
(
	`CodigoCliente` ASC,
	`FechaTransaccion` ASC,
	`Numero` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [IndiceBanco]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IndiceBanco` ON `DiferidosBanco`
(
	`CodigoBanco` ASC,
	`FechaPresentacion` ASC
) ;
 
/* SQLINES DEMO *** ndex [IndiceFecha]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IndiceFecha` ON `DiferidosBanco`
(
	`FechaPresentacion` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [Documentos_Fiscales_DocumentosEntidad]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `Documentos_Fiscales_DocumentosEntidad` ON `DocumentosFiscales`
(
	`TipoEntidad` ASC,
	`CodigoEntidad` ASC,
	`Fecha` ASC,
	`Id` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [DocumentosDocumento]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `DocumentosDocumento` ON `DocumentosFiscales`
(
	`TipoEntidad` ASC,
	`CodigoEntidad` ASC,
	`TipoDoc` ASC,
	`Referencia` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [DocumentosFiscales_Documentos]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `DocumentosFiscales_Documentos` ON `DocumentosFiscales`
(
	`TipoDoc` ASC,
	`NumeroDoc` ASC
) ;
 
/* SQLINES DEMO *** ndex [ix_ReporteDocFis]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `ix_ReporteDocFis` ON `DocumentosFiscales`
(
	`Reporte` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [IndiceDoc]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IndiceDoc` ON `DocumentosISPC`
(
	`NumDoc` ASC,
	`TipoDoc` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [IndiceEntidad]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `IndiceEntidad` ON `DocumentosISPC`
(
	`CodigoEntidad` ASC,
	`TipoEntidad` ASC,
	`Numero` ASC
) ;
 
/* SQLINES DEMO *** ndex [ix_sesion]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `ix_sesion` ON `EliminacionesPOS`
(
	`Sesion` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [AlmacenesExistenciaUbicacion]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `AlmacenesExistenciaUbicacion` ON `ExistenciaUbicacion`
(
	`Almacen` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [IndiceAlmacen]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IndiceAlmacen` ON `ExistenciaUbicacion`
(
	`Almacen` ASC,
	`TipoUbicacion` ASC,
	`CodigoItem` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [itemsInventarioExistenciaUbicacion]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `itemsInventarioExistenciaUbicacion` ON `ExistenciaUbicacion`
(
	`CodigoItem` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `ExistenciaUbicacion`
(
	`CodigoItem` ASC,
	`TipoUbicacion` ASC,
	`Almacen` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [Cliente]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `Cliente` ON `Facturas`
(
	`CodigoCliente` ASC,
	`FechaTransaccion` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [ClientesFacturas]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `ClientesFacturas` ON `Facturas`
(
	`CodigoCliente` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [Correlativo]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `Correlativo` ON `Facturas`
(
	`Serie` ASC,
	`Correlativo` ASC
) ;
 
/* SQLINES DEMO *** ndex [Fecha]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `Fecha` ON `Facturas`
(
	`FechaTransaccion` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [Referencia]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `Referencia` ON `Facturas`
(
	`ExtRef` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [Vendedor]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `Vendedor` ON `Facturas`
(
	`CodigoVendedor` ASC,
	`FechaTransaccion` ASC
) ;
 
/* SQLINES DEMO *** ndex [idSesion]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `idSesion` ON `FacturasPOS`
(
	`idSesion` ASC,
	`NumeroTicket` ASC
) ;
 
/* SQLINES DEMO *** ndex [IX_HoraFacturasPOS]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IX_HoraFacturasPOS` ON `FacturasPOS`
(
	`Hora` ASC
) ;
 
/* SQLINES DEMO *** ndex [IX_MaquinaTicket]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `IX_MaquinaTicket` ON `FacturasPOS`
(
	`idMaquina` ASC,
	`NumeroTicket` ASC
) ;
 
/* SQLINES DEMO *** ndex [ndxFacturaPOS_Sesion]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `ndxFacturaPOS_Sesion` ON `FacturasPOS`
(
	`idSesion` ASC
) ;
 
/* SQLINES DEMO *** ndex [ix_GastosFactura]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `ix_GastosFactura` ON `GastosCompra`
(
	`Factura` ASC,
	`id` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [iKey]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `iKey` ON `HotKeys`
(
	`Tecla` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [ItemsVentaHotKeys]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `ItemsVentaHotKeys` ON `HotKeys`
(
	`Normal` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [Descripcion]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `Descripcion` ON `itemsInventario`
(
	`Descripcion` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [Grupo]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `Grupo` ON `itemsInventario`
(
	`Grupo` ASC,
	`Codigo` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [LineaCodigo]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `LineaCodigo` ON `itemsInventario`
(
	`Linea` ASC,
	`Codigo` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [LineaDescripcion]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `LineaDescripcion` ON `itemsInventario`
(
	`Linea` ASC,
	`Descripcion` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [LineaGrupo]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `LineaGrupo` ON `itemsInventario`
(
	`Linea` ASC,
	`Grupo` ASC,
	`Codigo` ASC
) ;
 
/* SQLINES DEMO *** ndex [NDXIDINVENTARIO]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `NDXIDINVENTARIO` ON `itemsInventario`
(
	`ID` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [ndxItemsInvUbicacion]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `ndxItemsInvUbicacion` ON `itemsInventario`
(
	`Ubicacion` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [Descripcion]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `Descripcion` ON `ItemsVenta`
(
	`Descripcion` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [Grupo]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `Grupo` ON `ItemsVenta`
(
	`Grupo` ASC,
	`Codigo` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [Linea]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `Linea` ON `ItemsVenta`
(
	`Linea` ASC,
	`Codigo` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [LineaDesc]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `LineaDesc` ON `ItemsVenta`
(
	`Linea` ASC,
	`Descripcion` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [LineaGrupo]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `LineaGrupo` ON `ItemsVenta`
(
	`Linea` ASC,
	`Grupo` ASC,
	`Codigo` ASC
) ;
 
/* SQLINES DEMO *** ndex [NDXIDITEMVENTA]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `NDXIDITEMVENTA` ON `ItemsVenta`
(
	`ID` ASC
) ;
 
/* SQLINES DEMO *** ndex [NumeroPLU]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `NumeroPLU` ON `ItemsVenta`
(
	`NumeroPLU` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [Ubicacion]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `Ubicacion` ON `ItemsVenta`
(
	`Ubicacion` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [IndiceDescripcion]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IndiceDescripcion` ON `Lineas`
(
	`Descripcion` ASC
) ;
 
/* SQLINES DEMO *** ndex [Account]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `Account` ON `mesasAmbientes`
(
	`AccountOffset` ASC
) ;
 
/* SQLINES DEMO *** ndex [NDXIDAMBIENTE]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `NDXIDAMBIENTE` ON `mesasAmbientes`
(
	`ID` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [Prefijo]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `Prefijo` ON `mesasAmbientes`
(
	`Prefijo` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `mesasAmbientes`
(
	`Codigo` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `mesasItems`
(
	`Codigo` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `mesasMesas`
(
	`Ambiente` ASC,
	`IDMesa` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [item]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `item` ON `mnuItems`
(
	`CodigoItem` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `mnuItems`
(
	`ownerMenu` ASC,
	`Posicion` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [BancoFecha]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `BancoFecha` ON `MovimientosBanco`
(
	`CodigoBanco` ASC,
	`FechaTransaccion` ASC,
	`Numero` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [BancoNumero]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `BancoNumero` ON `MovimientosBanco`
(
	`CodigoBanco` ASC,
	`Numero` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [BancosMovimientosBanco]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `BancosMovimientosBanco` ON `MovimientosBanco`
(
	`CodigoBanco` ASC
) ;
 
/* SQLINES DEMO *** ndex [FechaTransaccion]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `FechaTransaccion` ON `MovimientosBanco`
(
	`FechaTransaccion` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [ndxDocumento]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `ndxDocumento` ON `MovimientosBanco`
(
	`TipoDocRel` ASC,
	`NumeroDocRel` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [Documento]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `Documento` ON `MovimientosCaja`
(
	`TipoDocumento` ASC,
	`NumeroDocumento` ASC
) ;
 
/* SQLINES DEMO *** ndex [idxSesion]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `idxSesion` ON `MovimientosCaja`
(
	`Sesion` ASC
) ;
 
/* SQLINES DEMO *** ndex [ndxCorrelativo]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `ndxCorrelativo` ON `NCPOS`
(
	`idMaquina` ASC,
	`correlativo` ASC
) ;
 
/* SQLINES DEMO *** ndex [ndxSesion]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `ndxSesion` ON `NCPOS`
(
	`idSesion` ASC,
	`numero` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [Cliente]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `Cliente` ON `NNEE`
(
	`CodigoCliente` ASC,
	`FechaTransaccion` ASC,
	`Numero` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [ClientesNNEE]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `ClientesNNEE` ON `NNEE`
(
	`CodigoCliente` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [CodigoItem]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `CodigoItem` ON `NNEEDetalles`
(
	`CodigoItem` ASC,
	`NumeroDocumento` ASC
) ;
 
/* SQLINES DEMO *** ndex [NNEENNEEDetalles]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `NNEENNEEDetalles` ON `NNEEDetalles`
(
	`NumeroDocumento` ASC
) ;
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `NNEEDetalles`
(
	`NumeroDocumento` ASC,
	`Renglon` ASC
) ;
 
/* SQLINES DEMO *** ndex [NNEESuplementoNNEEDetalleSuplemento]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `NNEESuplementoNNEEDetalleSuplemento` ON `NNEEDetalleSuplemento`
(
	`NumeroDocumento` ASC
) ;
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `NNEEDetalleSuplemento`
(
	`NumeroDocumento` ASC,
	`Renglon` ASC
) ;
 
/* SQLINES DEMO *** ndex [IX_DevolucionNota]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IX_DevolucionNota` ON `NNEEDevDetalles`
(
	`NumeroNota` ASC,
	`NumeroDevolucion` ASC,
	`NumeroDetalle` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [IX_Cliente]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IX_Cliente` ON `NNEEDevoluciones`
(
	`CodigoCliente` ASC,
	`Numero` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [IndiceDocumento]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IndiceDocumento` ON `NNEESuplemento`
(
	`TipoDocRel` ASC,
	`NumeroDocRel` ASC
) ;
 
/* SQLINES DEMO *** ndex [IndiceNota]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IndiceNota` ON `NNEESuplemento`
(
	`NumeroNota` ASC,
	`FechaTransaccion` ASC
) ;
 
/* SQLINES DEMO *** ndex [NNEENNEESuplemento]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `NNEENNEESuplemento` ON `NNEESuplemento`
(
	`NumeroNota` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [CodAttrib]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `CodAttrib` ON `nomAtribTrabajador`
(
	`CodAttrib` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `nomAtribTrabajador`
(
	`CodTrab` ASC,
	`CodAttrib` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `nomCategoriasLaborales`
(
	`Codigo` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `nomCodigosRecibo`
(
	`Codigo` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `nomCodigosReporte`
(
	`Codigo` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [I1]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `I1` ON `nomDefAsigDed`
(
	`Descripcion` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `nomDefAsigDed`
(
	`Codigo` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `nomDepartamentos`
(
	`Codigo` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `nomDescCargos`
(
	`Codigo` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `nomDescHabilidad`
(
	`Codigo` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [I1]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `I1` ON `nomDetallesProceso`
(
	`Trabajador` ASC,
	`ClaseLaboral` ASC,
	`FechaCierre` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [I2]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `I2` ON `nomDetallesProceso`
(
	`Trabajador` ASC,
	`CodigoReporte` ASC,
	`FechaCierre` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [I3]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `I3` ON `nomDetallesProceso`
(
	`Trabajador` ASC,
	`ProcessID` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [I4]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `I4` ON `nomDetallesProceso`
(
	`ProcessID` ASC,
	`Trabajador` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `nomDetallesRecibo`
(
	`numeroProceso` ASC,
	`codigoTrabajador` ASC,
	`varID` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [varID]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `varID` ON `nomDetallesRecibo`
(
	`varID` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [Enumerador]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `Enumerador` ON `nomEnumHabilidades`
(
	`Enumerador` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `nomEnumHabilidades`
(
	`CodigoHabilidad` ASC,
	`Valor` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [CodTrabajador]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `CodTrabajador` ON `nomExcepciones`
(
	`CodTrabajador` ASC,
	`Fecha` ASC,
	`NumeroId` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [IX_nomExcepcionesProcesoTrabajador]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IX_nomExcepcionesProcesoTrabajador` ON `nomExcepcionesProceso`
(
	`idProceso` ASC,
	`CodTrabajador` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `nomFiltros`
(
	`Codigo` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `nomFiltrosScript`
(
	`CodigoScript` ASC,
	`codigoFiltro` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [CodigoHabilidad]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `CodigoHabilidad` ON `nomHabilidadesTrabajador`
(
	`CodigoHabilidad` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `nomHabilidadesTrabajador`
(
	`CodigoTrabajador` ASC,
	`CodigoHabilidad` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [TrabHabil]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `TrabHabil` ON `nomHabilidadesTrabajador`
(
	`CodigoHabilidad` ASC,
	`CodigoTrabajador` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `nomHistTrab`
(
	`CodigoTrabajador` ASC,
	`Desde` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [CodTrabFecha]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `CodTrabFecha` ON `nomObservaciones`
(
	`CodigoTrabajador` ASC,
	`Fecha` ASC,
	`Numero` ASC
) ;
 
/* SQLINES DEMO *** ndex [IX_nomPagosPrestamoPrestamo]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IX_nomPagosPrestamoPrestamo` ON `nomPagosPrestamo`
(
	`idPrestamo` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `nomPagosProceso`
(
	`ProcessID` ASC,
	`Trabajador` ASC
) ;
 
/* SQLINES DEMO *** ndex [ProcessID]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `ProcessID` ON `nomPagosProceso`
(
	`ProcessID` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [IX_idPrestamoProceso]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `IX_idPrestamoProceso` ON `nomParametrosPrestamo`
(
	`idPrestamo` ASC,
	`codigoProceso` ASC
) ;
 
/* SQLINES DEMO *** ndex [IX_nomParametrosPrestamoPrestamo]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IX_nomParametrosPrestamoPrestamo` ON `nomParametrosPrestamo`
(
	`idPrestamo` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [IX_nomPrestamos_Trabajador]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IX_nomPrestamos_Trabajador` ON `nomPrestamos`
(
	`trabajador` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [I1]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `I1` ON `nomProcesos`
(
	`CodigoScript` ASC,
	`FechaInicioPeriodo` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [I2]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `I2` ON `nomProcesos`
(
	`CodigoScript` ASC,
	`FechaFinPeriodo` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [I3]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `I3` ON `nomProcesos`
(
	`CodigoScript` ASC,
	`FechaCierre` ASC
) ;
 
/* SQLINES DEMO *** ndex [I4]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `I4` ON `nomProcesos`
(
	`FechaCierre` ASC
) ;
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `nomProcesos`
(
	`Numero` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [I1]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `I1` ON `nomRecibosScript`
(
	`CodigoScript` ASC,
	`FileName` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `nomScripts`
(
	`Codigo` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `nomTiposAtributo`
(
	`Codigo` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `nomTiposExcepcion`
(
	`Codigo` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `nomTiposObservacion`
(
	`Codigo` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [CodExcepcion]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `CodExcepcion` ON `nomTMPListaExcepciones`
(
	`NumeroId` ASC,
	`CodExcepcion` ASC,
	`Fecha` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [CodTrabajador]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `CodTrabajador` ON `nomTMPListaExcepciones`
(
	`NumeroId` ASC,
	`CodTrabajador` ASC,
	`CodExcepcion` ASC,
	`Fecha` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [I1]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `I1` ON `nomTMPResumenProceso`
(
	`sUserID` ASC,
	`sCodDept` ASC,
	`sCodTrab` ASC,
	`nTipo` ASC,
	`sCodGrup` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [sUserID]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `sUserID` ON `nomTMPResumenProceso`
(
	`sUserID` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [CI]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `CI` ON `nomTrabajadores`
(
	`CI` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [Nombre]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `Nombre` ON `nomTrabajadores`
(
	`Nombre` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `nomTrabajadores`
(
	`Codigo` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [ix_Notas_Entidad]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `ix_Notas_Entidad` ON `notas`
(
	`tipoEntidad` ASC,
	`codigoEntidad` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [Entidad]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `Entidad` ON `NotasDCCP`
(
	`TipoEntidad` ASC,
	`CodigoEntidad` ASC,
	`FechaDoc` ASC,
	`Numero` ASC
) ;
 
/* SQLINES DEMO *** ndex [iCorrelativo]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `iCorrelativo` ON `NotasDCCP`
(
	`Correlativo` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [ndxSerie]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `ndxSerie` ON `NotasDCCP`
(
	`Serie` ASC,
	`Correlativo` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [CodigoItem]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `CodigoItem` ON `ocDetalles`
(
	`CodigoItem` ASC
) ;
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `ocDetalles`
(
	`NumeroDocumento` ASC,
	`Renglon` ASC
) ;
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `ocOrdenes`
(
	`Numero` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [Proveedor]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `Proveedor` ON `ocOrdenes`
(
	`CodigoProveedor` ASC,
	`FechaTransaccion` ASC,
	`Numero` ASC
) ;
 
/* SQLINES DEMO *** ndex [Renglon]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `Renglon` ON `ocRecibidas`
(
	`NumeroOrden` ASC,
	`NumeroRenglon` ASC,
	`Fecha` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `perfilDescripcion`
(
	`CodigoPerfil` ASC
) ;
 
/* SQLINES DEMO *** ndex [Posicion]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `Posicion` ON `perfilElementos`
(
	`Posicion` ASC
) ;
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `perfilElementos`
(
	`Valor` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `perfilesPermisos`
(
	`CodigoPerfil` ASC,
	`Permiso` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [IndiceNombre]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IndiceNombre` ON `Proveedores`
(
	`Nombre` ASC
) ;
 
/* SQLINES DEMO *** ndex [NDXIDPROVEEDOR]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `NDXIDPROVEEDOR` ON `Proveedores`
(
	`ID` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [iItem]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `iItem` ON `ProveedorProducto`
(
	`CodigoItem` ASC,
	`CodigoProveedor` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [iProveedor]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE UNIQUE INDEX `iProveedor` ON `ProveedorProducto`
(
	`CodigoProveedor` ASC,
	`CodigoItem` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [itemsInventarioProveedorProducto]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `itemsInventarioProveedorProducto` ON `ProveedorProducto`
(
	`CodigoItem` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [ProveedoresProveedorProducto]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `ProveedoresProveedorProducto` ON `ProveedorProducto`
(
	`CodigoProveedor` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [refProveedor]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `refProveedor` ON `ProveedorProducto`
(
	`CodigoProveedor` ASC,
	`RefProductoProveedor` ASC
) ;
 
/* SQLINES DEMO *** ndex [IX_Numero]    Script Date: 28/3/2025 3:56:58 p. m. ******/
CREATE INDEX `IX_Numero` ON `RelacionesIVARetenido`
(
	`NumeroRetencion` ASC
) ;
 
/* SQLINES DEMO *** ndex [OwnerID]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE INDEX `OwnerID` ON `RenglonesConsumoSesion`
(
	`OwnerID` ASC
) ;
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE INDEX `PrimaryKey` ON `RenglonesConsumoSesion`
(
	`OwnerID` ASC,
	`Renglon` ASC
) ;
 
/* SQLINES DEMO *** ndex [FacturasPOSRenglonesFacturaPOS]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE INDEX `FacturasPOSRenglonesFacturaPOS` ON `RenglonesFacturaPOS`
(
	`idMaquina` ASC,
	`numeroTicket` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [IX_RenglonesFacturaPOSProducto]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE INDEX `IX_RenglonesFacturaPOSProducto` ON `RenglonesFacturaPOS`
(
	`Producto` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [ndxUsuario]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE INDEX `ndxUsuario` ON `RenglonesFacturaPOS`
(
	`Usuario` ASC
) ;
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `RenglonesFacturaPOS`
(
	`idMaquina` ASC,
	`numeroTicket` ASC,
	`numeroLinea` ASC
) ;
 
/* SQLINES DEMO *** ndex [RenglonesFacturaPOSNumeroFactura]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE INDEX `RenglonesFacturaPOSNumeroFactura` ON `RenglonesFacturaPOS`
(
	`NumeroFactura` ASC
) ;
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `RenglonesSesion`
(
	`SessionID` ASC,
	`NumeroRenglon` ASC
) ;
 
/* SQLINES DEMO *** ndex [NumeroTransferencia]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE INDEX `NumeroTransferencia` ON `RenglonesTransferencia`
(
	`NumeroTransferencia` ASC
) ;
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `RenglonesTransferencia`
(
	`NumeroTransferencia` ASC,
	`Renglon` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [FechaProv]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE INDEX `FechaProv` ON `RetencionesISLR`
(
	`fecha` ASC,
	`tipoEntidadRelacionada` ASC,
	`codigoEntidad` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [ixRIF]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE INDEX `ixRIF` ON `RetencionesISLR`
(
	`RIFSujeto` ASC,
	`Numero` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [ProvFecha]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE INDEX `ProvFecha` ON `RetencionesISLR`
(
	`tipoEntidadRelacionada` ASC,
	`codigoEntidad` ASC,
	`fecha` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [retDocOrigen]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE INDEX `retDocOrigen` ON `RetencionesISLR`
(
	`TipoDoc` ASC,
	`NumDoc` ASC
) ;
 
/* SQLINES DEMO *** ndex [ix_ReporteRetIVA]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE INDEX `ix_ReporteRetIVA` ON `RetencionesIVA`
(
	`RefReporte` ASC
) ;
 
/* SQLINES DEMO *** ndex [SesionesPOSRetirosPOS]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE INDEX `SesionesPOSRetirosPOS` ON `RetirosPOS`
(
	`idSesion` ASC
) ;
 
/* SQLINES DEMO *** ndex [tmSesion]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE INDEX `tmSesion` ON `RetirosPOS`
(
	`idSesion` ASC,
	`Hora` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [IX_rislrConceptos]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE UNIQUE INDEX `IX_rislrConceptos` ON `rislrConceptos`
(
	`Codigo` ASC
) ;
 
/* SQLINES DEMO *** ndex [IX_rislrMetodos]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE UNIQUE INDEX `IX_rislrMetodos` ON `rislrMetodos`
(
	`IdConcepto` ASC,
	`TipoPersona` ASC
) ;
 
/* SQLINES DEMO *** ndex [IX_rislrParametrosT2]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE INDEX `IX_rislrParametrosT2` ON `rislrParametrosT2`
(
	`idMetodo` ASC,
	`Hasta` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `rpBalanceGeneral`
(
	`CodigoCuenta` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `SaldosEntidadPeriodo`
(
	`TipoEntidad` ASC,
	`CodigoEntidad` ASC,
	`NumeroPeriodo` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [CuentasSaldosPeriodo]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE INDEX `CuentasSaldosPeriodo` ON `SaldosPeriodo`
(
	`CodigoCuenta` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `SaldosPeriodo`
(
	`CodigoCuenta` ASC,
	`NumeroPeriodo` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [IX_saveMovCaja]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE UNIQUE INDEX `IX_saveMovCaja` ON `saveMovsCaja`
(
	`clave` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [ndxSerial]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE INDEX `ndxSerial` ON `Seriales`
(
	`Serial` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `Seriales`
(
	`CodigoItem` ASC,
	`Serial` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [iDocLinea]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE INDEX `iDocLinea` ON `SerialesDetalles`
(
	`NumeroDocumento` ASC,
	`TipoDocumento` ASC,
	`Renglon` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [iItem]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE INDEX `iItem` ON `SerialesDetalles`
(
	`CodigoItem` ASC,
	`Serial` ASC,
	`FechaTransaccion` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [iSerial]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE INDEX `iSerial` ON `SerialesDetalles`
(
	`Serial` ASC
) ;
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `SerialesDetalles`
(
	`NumeroDetalle` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [Descripcion]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE INDEX `Descripcion` ON `Series`
(
	`Descripcion` ASC
) ;
 
/* SQLINES DEMO *** ndex [MachineID]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE INDEX `MachineID` ON `SesionesCerradas`
(
	`MachineID` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [usrID]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE INDEX `usrID` ON `SesionesCerradas`
(
	`usrID` ASC
) ;
 
/* SQLINES DEMO *** ndex [MachineID]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE INDEX `MachineID` ON `SesionesPOS`
(
	`MachineID` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [usrID]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE INDEX `usrID` ON `SesionesPOS`
(
	`usrID` ASC
) ;
 
/* SQLINES DEMO *** ndex [IX_SesionLocal]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE INDEX `IX_SesionLocal` ON `SesionesRemotas`
(
	`SesionLocal` ASC
) ;
 
/* SQLINES DEMO *** ndex [MovimientosCajasubDocsMC]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE INDEX `MovimientosCajasubDocsMC` ON `subDocsMB`
(
	`TransID` ASC
) ;
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `subDocsMB`
(
	`ID` ASC
) ;
 
/* SQLINES DEMO *** ndex [TransID]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE INDEX `TransID` ON `subDocsMB`
(
	`TransID` ASC
) ;
 
/* SQLINES DEMO *** ndex [MovimientosCajasubDocsMC]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE INDEX `MovimientosCajasubDocsMC` ON `subDocsMC`
(
	`TransID` ASC
) ;
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `subDocsMC`
(
	`ID` ASC
) ;
 
/* SQLINES DEMO *** ndex [TransID]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE INDEX `TransID` ON `subDocsMC`
(
	`TransID` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [IndiceDescripcion]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE INDEX `IndiceDescripcion` ON `SubLineas`
(
	`Descripcion` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [IndiceDescripcion]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE INDEX `IndiceDescripcion` ON `TiposCliente`
(
	`Descripcion` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `tmpResumenPOS`
(
	`Sesion` ASC,
	`Producto` ASC,
	`Precio` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [Producto]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE INDEX `Producto` ON `tmpResumenPOS`
(
	`Producto` ASC,
	`Sesion` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `Unidades`
(
	`Codigo` ASC
) ;
 
/* SQLINES DEMO *** ndex [ClaveUsuario]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE INDEX `ClaveUsuario` ON `Usuarios`
(
	`Clave` ASC
) ;
 
/* SQLINES DEMO *** ndex [ndxUsuarios_ID]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE INDEX `ndxUsuarios_ID` ON `Usuarios`
(
	`ID` ASC
) ;
 
/* SQLINES DEMO *** ndex [DocumentosISPCVencimientosISPC]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE INDEX `DocumentosISPCVencimientosISPC` ON `VencimientosISPC`
(
	`NumeroDocumento` ASC
) ;
 
/* SQLINES DEMO *** ndex [FechaVencimiento]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE INDEX `FechaVencimiento` ON `VencimientosISPC`
(
	`FechaVencimiento` ASC
) ;
 
/* SQLINES DEMO *** ndex [PrimaryKey]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE UNIQUE INDEX `PrimaryKey` ON `VencimientosISPC`
(
	`NumeroDocumento` ASC,
	`FechaVencimiento` ASC
) ;
 
/* SQLINES DEMO *** ndex [NDXIDVENDEDOR]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE UNIQUE INDEX `NDXIDVENDEDOR` ON `Vendedores`
(
	`ID` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [Nombre]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE INDEX `Nombre` ON `Vendedores`
(
	`Nombre` ASC
) ;
 
/* SET ANSI_PADDING ON */
 
/* SQLINES DEMO *** ndex [IndiceDescripcion]    Script Date: 28/3/2025 3:56:59 p. m. ******/
CREATE INDEX `IndiceDescripcion` ON `Zonas`
(
	`Descripcion` ASC
) ;
 
/* Moved to CREATE TABLE
ALTER TABLE `acumuladoresTipoIVASesion` ADD  DEFAULT ((0)) FOR `numeroSesion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `acumuladoresTipoIVASesion` ADD  DEFAULT ('') FOR `tipoImpuesto`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `acumuladoresTipoIVASesion` ADD  DEFAULT ((0)) FOR `valorAcumulado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `acumuladoresTipoIVASesion` ADD  DEFAULT ((0)) FOR `porcentajeIVA`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `adelantosEfectivo` ADD  DEFAULT (now(3)) FOR `hora`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `adelantosEfectivo` ADD  DEFAULT ('') FOR `codigoCliente`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `adelantosEfectivo` ADD  DEFAULT ((0)) FOR `montoCobrado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `adelantosEfectivo` ADD  DEFAULT ((0)) FOR `montoEntregado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `adelantosEfectivo` ADD  DEFAULT ('') FOR `operador`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Ajustes` ADD  DEFAULT ((0)) FOR `Numero`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Ajustes` ADD  DEFAULT ('') FOR `refAjuste`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Ajustes` ADD  DEFAULT ((0)) FOR `Tipo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Ajustes` ADD  DEFAULT ('') FOR `Descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Ajustes` ADD  DEFAULT ('') FOR `Notas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Ajustes` ADD  DEFAULT (now(3)) FOR `FechaRegistro`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Ajustes` ADD  DEFAULT (now(3)) FOR `FechaTransaccion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Ajustes` ADD  DEFAULT ('') FOR `Operador`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Ajustes` ADD  DEFAULT ('') FOR `Contrapartida`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Ajustes` ADD  DEFAULT ('') FOR `Almacen`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Ajustes` ADD  DEFAULT ((0)) FOR `Status`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Ajustes` ADD  DEFAULT ((0)) FOR `Valor`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Almacenes` ADD  DEFAULT ('') FOR `Nombre`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Almacenes` ADD  DEFAULT ('') FOR `CuentaActivo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `AlternosItemVenta` ADD  DEFAULT ('') FOR `CodigoItemVenta`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `AnulacionesPOS` ADD  DEFAULT ((0)) FOR `SessionID`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `AnulacionesPOS` ADD  DEFAULT ((0)) FOR `IDMaquina`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `AnulacionesPOS` ADD  DEFAULT (now(3)) FOR `Hora`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `AnulacionesPOS` ADD  DEFAULT ((0)) FOR `NumeroTicket`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `AnulacionesPOS` ADD  DEFAULT ((0)) FOR `MontoVenta`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `AnulacionesPOS` ADD  DEFAULT ((0)) FOR `Impuesto`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `AnulacionesPOS` ADD  DEFAULT ((0)) FOR `Servicio`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `AnulacionesPOS` ADD  DEFAULT ((0)) FOR `numFactura`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `appLog` ADD  DEFAULT (now(3)) FOR `Hora`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `appLog` ADD  DEFAULT ('') FOR `Usuario`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `appLog` ADD  DEFAULT ((0)) FOR `machineID`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `appLog` ADD  DEFAULT ('') FOR `descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Atributos` ADD  DEFAULT ('') FOR `ValorAtributo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `atributosDescriptor` ADD  DEFAULT ('') FOR `tipoEntidad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `atributosDescriptor` ADD  DEFAULT ('') FOR `codigoAtributo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `atributosDescriptor` ADD  DEFAULT ('') FOR `descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `atributosDescriptor` ADD  DEFAULT ('') FOR `tipoDato`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `autorizadores` ADD  DEFAULT ('') FOR `usrID`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Bancos` ADD  DEFAULT ('') FOR `Cuenta`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Bancos` ADD  DEFAULT ('') FOR `Nombre`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Bancos` ADD  DEFAULT ('') FOR `Banco`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Bancos` ADD  DEFAULT ((0)) FOR `TipoCuenta`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Bancos` ADD  DEFAULT ('') FOR `CGCuenta`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Bancos` ADD  DEFAULT ((0)) FOR `SaldoActual`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Bancos` ADD  DEFAULT ((0)) FOR `DepositosDiferidos`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Bancos` ADD  DEFAULT ((0)) FOR `ChequesPostdatados`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Bancos` ADD  DEFAULT (now(3)) FOR `UltimaActualizacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Bancos` ADD  DEFAULT ((0)) FOR `ProximoCheque`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Bancos` ADD  DEFAULT (now(3)) FOR `FechaCreacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Bancos` ADD  DEFAULT ((0)) FOR `monedaExtranjera`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Bancos` ADD  DEFAULT ((1)) FOR `factorTipoCambio`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Bancos` ADD  DEFAULT ((1)) FOR `tipoCambioReferencial`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Bancos` ADD  DEFAULT ('VES') FOR `simboloMoneda`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Bancos` ADD  DEFAULT ((0)) FOR `metodos`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Bancos` ADD  DEFAULT ('') FOR `emailZelle`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Bancos` ADD  DEFAULT ('') FOR `beneficiarioPago`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Bancos` ADD  DEFAULT ('') FOR `telefonoPagoMovil`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Bancos` ADD  DEFAULT ('') FOR `idPagoMovil`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Bancos` ADD  DEFAULT ((0)) FOR `tipoIGTF`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Bancos` ADD  DEFAULT ((1)) FOR `autoRetIGTF`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `chequeDevueltoComis` ADD  DEFAULT ((0)) FOR `idCheque`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `chequeDevueltoComis` ADD  DEFAULT ('') FOR `tipoDocRel`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `chequeDevueltoComis` ADD  DEFAULT ('') FOR `refDocRel`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `chequeDevueltoComis` ADD  DEFAULT ('') FOR `codigoVendedor`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `chequeDevueltoComis` ADD  DEFAULT ((0)) FOR `montoComision`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CierresZ` ADD  DEFAULT ((0)) FOR `idTerminal`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CierresZ` ADD  DEFAULT ((0)) FOR `Numero`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CierresZ` ADD  DEFAULT (now(3)) FOR `Apertura`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CierresZ` ADD  DEFAULT (now(3)) FOR `HoraUltimaOperacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CierresZ` ADD  DEFAULT ((0)) FOR `qFacturas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CierresZ` ADD  DEFAULT ((0)) FOR `PrimeraFactura`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CierresZ` ADD  DEFAULT ((0)) FOR `UltimaFactura`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CierresZ` ADD  DEFAULT ((0)) FOR `Turnos`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CierresZ` ADD  DEFAULT ((0)) FOR `Exento`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CierresZ` ADD  DEFAULT ((0)) FOR `Servicio`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CierresZ` ADD  DEFAULT ((0)) FOR `Gravable1`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CierresZ` ADD  DEFAULT ((0)) FOR `Gravable2`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CierresZ` ADD  DEFAULT ((0)) FOR `Impuesto1`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CierresZ` ADD  DEFAULT ((0)) FOR `Impuesto2`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CierresZ` ADD  DEFAULT ((0)) FOR `IGTFRetenido`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `clasif3` ADD  DEFAULT ('') FOR `descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Clasificaciones` ADD  DEFAULT ('') FOR `Codigo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Clasificaciones` ADD  DEFAULT ('') FOR `Descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Clientes` ADD  DEFAULT ('') FOR `Nombre`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Clientes` ADD  DEFAULT ('') FOR `Tipo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Clientes` ADD  DEFAULT ('') FOR `RIF`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Clientes` ADD  DEFAULT ('') FOR `NIT`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Clientes` ADD  DEFAULT ('') FOR `CGCuenta`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Clientes` ADD  DEFAULT ('') FOR `CuentaIngresos`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Clientes` ADD  DEFAULT ('') FOR `Direccion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Clientes` ADD  DEFAULT ('') FOR `Telefono`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Clientes` ADD  DEFAULT ('') FOR `Zona`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Clientes` ADD  DEFAULT ('') FOR `Ruta`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Clientes` ADD  DEFAULT ('') FOR `Estado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Clientes` ADD  DEFAULT ('') FOR `Municipio`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Clientes` ADD  DEFAULT ('') FOR `VendedorAsignado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Clientes` ADD  DEFAULT ('CONTADO') FOR `CondicionStandard`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Clientes` ADD  DEFAULT ('') FOR `PrecioStandard`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Clientes` ADD  DEFAULT ((0)) FOR `SaldoActual`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Clientes` ADD  DEFAULT ((0)) FOR `LimiteCredito`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Clientes` ADD  DEFAULT ((0)) FOR `Status`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Clientes` ADD  DEFAULT ('20000101') FOR `FechaUltimaVenta`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Clientes` ADD  DEFAULT ('') FOR `Notas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Clientes` ADD  DEFAULT (now(3)) FOR `FechaCreacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Clientes` ADD  DEFAULT ((0)) FOR `Contribuyente`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Clientes` ADD  DEFAULT ((0)) FOR `ContribuyenteEspecial`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Clientes` ADD  DEFAULT ((1)) FOR `IndicePrecio`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Clientes` ADD  DEFAULT ('PRECIO1') FOR `PerfilPrecios`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Clientes` ADD  DEFAULT ((0)) FOR `CuentaME`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Clientes` ADD  DEFAULT ((0)) FOR `Latitud`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Clientes` ADD  DEFAULT ((0)) FOR `Longitud`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Clientes` ADD  DEFAULT ('') FOR `email`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Cobranzas` ADD  DEFAULT ((0)) FOR `MontoCobrado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Cobranzas` ADD  DEFAULT ((0)) FOR `MontoNeto`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Cobranzas` ADD  DEFAULT ((0)) FOR `RetencionIVA`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Cobranzas` ADD  DEFAULT ((0)) FOR `RetencionISLR`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Cobranzas` ADD  DEFAULT ((0)) FOR `NetoFacturas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Cobranzas` ADD  DEFAULT ((0)) FOR `IVACobrado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Cobranzas` ADD  DEFAULT ((0)) FOR `Descuentos`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CobrosPOS` ADD  DEFAULT ((0)) FOR `SessionID`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CobrosPOS` ADD  DEFAULT (now(3)) FOR `Hora`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CobrosPOS` ADD  DEFAULT ('') FOR `CodigoCliente`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CobrosPOS` ADD  DEFAULT ('') FOR `Descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CobrosPOS` ADD  DEFAULT ((0)) FOR `Monto`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CobrosPostdatados` ADD  DEFAULT (now(3)) FOR `FechaRegistro`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ColaVendedores` ADD  DEFAULT (now(3)) FOR `UltimoServicio`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Competencia` ADD  DEFAULT ('') FOR `CodigoItem`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Competencia` ADD  DEFAULT ('') FOR `Establecimiento`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Competencia` ADD  DEFAULT ((0)) FOR `Precio`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Compras` ADD  DEFAULT ((0)) FOR `Numero`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Compras` ADD  DEFAULT (now(3)) FOR `FechaRegistro`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Compras` ADD  DEFAULT (now(3)) FOR `FechaTransaccion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Compras` ADD  DEFAULT (now(3)) FOR `FechaEmision`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Compras` ADD  DEFAULT ('') FOR `Operador`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Compras` ADD  DEFAULT ('') FOR `CodigoProveedor`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Compras` ADD  DEFAULT ('') FOR `RefProveedor`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Compras` ADD  DEFAULT ('') FOR `NombreProveedor`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Compras` ADD  DEFAULT ((0)) FOR `CostoMercancia`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Compras` ADD  DEFAULT ((0)) FOR `Descuento1`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Compras` ADD  DEFAULT ((0)) FOR `Descuento2`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Compras` ADD  DEFAULT ((0)) FOR `Impuesto1`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Compras` ADD  DEFAULT ((0)) FOR `Impuesto2`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Compras` ADD  DEFAULT ('') FOR `Almacen`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Compras` ADD  DEFAULT ((0)) FOR `EstadoRecepcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Compras` ADD  DEFAULT ((0)) FOR `EstadoAdministrativo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Compras` ADD  DEFAULT ('C00') FOR `Condicion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Compras` ADD  DEFAULT ('') FOR `Notas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Compras` ADD  DEFAULT ((0)) FOR `Saldo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Compras` ADD  DEFAULT ((0)) FOR `NumeroControl`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Compras` ADD  DEFAULT ((0)) FOR `Diferencia`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Compras` ADD  DEFAULT ((0)) FOR `TipoCambio`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Compras` ADD  DEFAULT ((0)) FOR `TiempoRespuesta`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Comprobantes` ADD  DEFAULT ('') FOR `Referencia`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Comprobantes` ADD  DEFAULT ('') FOR `Descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Comprobantes` ADD  DEFAULT ('') FOR `Autor`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Comprobantes` ADD  DEFAULT (now(3)) FOR `Fecha`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Comprobantes` ADD  DEFAULT ((0)) FOR `Debitos`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Comprobantes` ADD  DEFAULT ((0)) FOR `Creditos`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Comprobantes` ADD  DEFAULT (now(3)) FOR `Modificado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Comprobantes` ADD  DEFAULT ('') FOR `documentoOrigen`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Comprobantes` ADD  DEFAULT ((0)) FOR `numeroDocumentoOrigen`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ComprobantesAlmacen` ADD  DEFAULT ('') FOR `Almacen`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ComprobantesAlmacen` ADD  DEFAULT ('') FOR `Operador`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ComprobantesAlmacen` ADD  DEFAULT (now(3)) FOR `FechaRegistro`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ComprobantesAlmacen` ADD  DEFAULT (now(3)) FOR `FechaTransaccion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ComprobantesAlmacen` ADD  DEFAULT ('') FOR `TipoEntidadOrigen`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ComprobantesAlmacen` ADD  DEFAULT ((0)) FOR `NumeroDocumentoOrigen`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ComprobantesAlmacen` ADD  DEFAULT ((0)) FOR `OrdenDespacho`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ComprobantesAlmacen` ADD  DEFAULT ('') FOR `Descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ComprobantesAlmacen` ADD  DEFAULT ((0)) FOR `ValorMN`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ComprobantesAlmacen` ADD  DEFAULT ((0)) FOR `ValorUSD`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ComprobantesAlmacen` ADD  DEFAULT ((1)) FOR `TipoCambio`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Conciliaciones` ADD  DEFAULT ('') FOR `CodigoBanco`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Conciliaciones` ADD  DEFAULT ((0)) FOR `SaldoBanco`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Conciliaciones` ADD  DEFAULT ((0)) FOR `NuestroSaldo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Conciliaciones` ADD  DEFAULT ((0)) FOR `ChequesEnTransito`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Conciliaciones` ADD  DEFAULT ((0)) FOR `OtrosMovimientos`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Conciliaciones` ADD  DEFAULT ((0)) FOR `Diferencias`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Condiciones` ADD  DEFAULT ('') FOR `Descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Condiciones` ADD  DEFAULT ((0)) FOR `Modo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Condiciones` ADD  DEFAULT ('') FOR `CuentaIngresos`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Condiciones` ADD  DEFAULT ((1)) FOR `nCuotas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Condiciones` ADD  DEFAULT ('d') FOR `intervalo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CondicVen` ADD  DEFAULT ('') FOR `CodigoCondicion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CondicVen` ADD  DEFAULT ((0)) FOR `Correlativo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CondicVen` ADD  DEFAULT ((0)) FOR `Plazo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CondicVen` ADD  DEFAULT ((0)) FOR `Porcentaje`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ConsignacionesCompra` ADD  DEFAULT (now(3)) FOR `FechaRegistro`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ConsignacionesCompra` ADD  DEFAULT ('') FOR `Operador`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ConsignacionesCompra` ADD  DEFAULT ('') FOR `CodigoProveedor`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ConsignacionesCompra` ADD  DEFAULT ('') FOR `RefProveedor`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ConsignacionesCompra` ADD  DEFAULT ((0)) FOR `CostoMercancia`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ConsignacionesCompra` ADD  DEFAULT ((0)) FOR `Descuento1`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ConsignacionesCompra` ADD  DEFAULT ((0)) FOR `Descuento2`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ConsignacionesCompra` ADD  DEFAULT ((0)) FOR `Impuesto1`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ConsignacionesCompra` ADD  DEFAULT ((0)) FOR `Impuesto2`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ConsignacionesCompra` ADD  DEFAULT ('') FOR `Almacen`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ConsignacionesCompra` ADD  DEFAULT ((0)) FOR `Liquidada`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ConsignacionesCompra` ADD  DEFAULT ((0)) FOR `Procesada`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ConsignacionesCompra` ADD  DEFAULT ('') FOR `Notas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ConsignacionesCompra` ADD  DEFAULT ((1)) FOR `TipoCambio`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ConsignacionesDetalles` ADD  DEFAULT ((0)) FOR `Piezas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Contactos` ADD  DEFAULT ('') FOR `Departamento`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Contactos` ADD  DEFAULT ('') FOR `Cargo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Contactos` ADD  DEFAULT ('') FOR `Direccion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Contactos` ADD  DEFAULT ('') FOR `Telefono`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Contactos` ADD  DEFAULT ('') FOR `TelefonoCelular`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Contactos` ADD  DEFAULT ('') FOR `FAX`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Contactos` ADD  DEFAULT ('') FOR `eMail`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Contactos` ADD  DEFAULT ('') FOR `Notas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Contadores` ADD  DEFAULT ((1)) FOR `Factura`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Contadores` ADD  DEFAULT ((1)) FOR `NotaEntrega`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Contadores` ADD  DEFAULT ((1)) FOR `Cotizacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Contadores` ADD  DEFAULT ((1)) FOR `DevolucionVenta`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Contadores` ADD  DEFAULT ((1)) FOR `Compra`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Contadores` ADD  DEFAULT ((1)) FOR `OrdenCompra`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Contadores` ADD  DEFAULT ((1)) FOR `DevolucionCompra`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Contadores` ADD  DEFAULT ((1)) FOR `Ajuste`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Contadores` ADD  DEFAULT ((1)) FOR `Transferencia`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Contadores` ADD  DEFAULT ((1)) FOR `NotaDBCR`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Contadores` ADD  DEFAULT (now(3)) FOR `Apertura`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Contadores` ADD  DEFAULT ((0)) FOR `Clave`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Contadores` ADD  DEFAULT ((0)) FOR `Status`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Contadores` ADD  DEFAULT ((0)) FOR `Operacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Contadores` ADD  DEFAULT ((0)) FOR `NotaFiscal`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Contadores` ADD  DEFAULT ((0)) FOR `RetencionISLR`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Contadores` ADD  DEFAULT ((1)) FOR `ProximaRelacionIR`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Contadores` ADD  DEFAULT ((1)) FOR `ProximoDocumentoISPC`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Contadores` ADD  DEFAULT (now(3)) FOR `FechaUltimoUso`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Contadores` ADD  DEFAULT ((1)) FOR `adelantoEfectivo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Contadores` ADD  DEFAULT ((0)) FOR `ProximoComprobanteAlmacen`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Contadores` ADD  DEFAULT ((0)) FOR `lastUpdate`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `controlMesasSesion` ADD  DEFAULT ((0)) FOR `idSesion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `controlMesasSesion` ADD  DEFAULT ((0)) FOR `nCuentasInicial`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `controlMesasSesion` ADD  DEFAULT ((0)) FOR `montoCuentasInicial`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `controlMesasSesion` ADD  DEFAULT ((0)) FOR `nCuentasAbiertas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `controlMesasSesion` ADD  DEFAULT ((0)) FOR `montoCargado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `controlMesasSesion` ADD  DEFAULT ((0)) FOR `nCuentasEliminadas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `controlMesasSesion` ADD  DEFAULT ((0)) FOR `montoEliminado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `controlMesasSesion` ADD  DEFAULT ((0)) FOR `nTransferencias`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `controlMesasSesion` ADD  DEFAULT ((0)) FOR `montoTransferencias`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `controlMesasSesion` ADD  DEFAULT ((0)) FOR `nCuentasPendientes`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `controlMesasSesion` ADD  DEFAULT ((0)) FOR `montoCuentasPendientes`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `controlMesasSesion` ADD  DEFAULT ((0)) FOR `nCerradas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `controlMesasSesion` ADD  DEFAULT ((0)) FOR `montoCerrado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CorrelativosMaquina` ADD  DEFAULT ((1)) FOR `ProximaFactura`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CorrelativosMaquina` ADD  DEFAULT ((1)) FOR `ProximaNC`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CorrelativosMaquina` ADD  DEFAULT ('') FOR `serialPF`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CorrelativosMaquina` ADD  DEFAULT ('') FOR `Descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Cotizaciones` ADD  DEFAULT (now(3)) FOR `FechaRegistro`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Cotizaciones` ADD  DEFAULT (now(3)) FOR `FechaTransaccion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Cotizaciones` ADD  DEFAULT ('') FOR `Operador`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Cotizaciones` ADD  DEFAULT ('') FOR `CodigoCliente`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Cotizaciones` ADD  DEFAULT ('') FOR `NombreCliente`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Cotizaciones` ADD  DEFAULT ('') FOR `CodigoVendedor`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Cotizaciones` ADD  DEFAULT ((0)) FOR `PrecioLista`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Cotizaciones` ADD  DEFAULT ((0)) FOR `PrecioVenta`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Cotizaciones` ADD  DEFAULT ((0)) FOR `PrecioEfectivo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Cotizaciones` ADD  DEFAULT ((0)) FOR `Impuesto1`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Cotizaciones` ADD  DEFAULT ((0)) FOR `Impuesto2`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Cotizaciones` ADD  DEFAULT ((0)) FOR `IndiceReferencia`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Cotizaciones` ADD  DEFAULT ((0)) FOR `IndiceVenta`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Cotizaciones` ADD  DEFAULT ((0)) FOR `Descuento1`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Cotizaciones` ADD  DEFAULT ((0)) FOR `Descuento2`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Cotizaciones` ADD  DEFAULT ('') FOR `Condicion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Cotizaciones` ADD  DEFAULT ('') FOR `Notas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Cotizaciones` ADD  DEFAULT ((0)) FOR `Estado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Cotizaciones` ADD  DEFAULT ('') FOR `Almacen`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Cotizaciones` ADD  DEFAULT ((1)) FOR `TipoCambio`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CotizacionesDetalles` ADD  DEFAULT ('') FOR `CodigoItem`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CotizacionesDetalles` ADD  DEFAULT ('') FOR `Descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CotizacionesDetalles` ADD  DEFAULT ('') FOR `Presentacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CotizacionesDetalles` ADD  DEFAULT ((0)) FOR `FactorEmpaque`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CotizacionesDetalles` ADD  DEFAULT ((0)) FOR `Cantidad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CotizacionesDetalles` ADD  DEFAULT ((0)) FOR `PrecioLista`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CotizacionesDetalles` ADD  DEFAULT ((0)) FOR `PrecioVenta`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CotizacionesDetalles` ADD  DEFAULT ((0)) FOR `PrecioEfectivo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CotizacionesDetalles` ADD  DEFAULT ((0)) FOR `Impuesto1`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CotizacionesDetalles` ADD  DEFAULT ((0)) FOR `Impuesto2`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CotizacionesDetalles` ADD  DEFAULT ((0)) FOR `CostoUnitario`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CotizacionesDetalles` ADD  DEFAULT ((0)) FOR `CantidadFacturada`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CotizacionesDetalles` ADD  DEFAULT ((0)) FOR `Ancho`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CotizacionesDetalles` ADD  DEFAULT ((0)) FOR `Alto`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CotizacionesDetalles` ADD  DEFAULT ((0)) FOR `Largo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CotizacionesDetalles` ADD  DEFAULT ('') FOR `Descuentos`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CotizacionesEntregas` ADD  DEFAULT ((0)) FOR `NumeroCotizacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CotizacionesEntregas` ADD  DEFAULT ((0)) FOR `NumeroRenglon`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CotizacionesEntregas` ADD  DEFAULT (now(3)) FOR `Fecha`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CotizacionesEntregas` ADD  DEFAULT ('') FOR `CodigoItem`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CotizacionesEntregas` ADD  DEFAULT ((0)) FOR `Cantidad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CotizacionesEntregas` ADD  DEFAULT ((0)) FOR `PrecioUnitario`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CotizacionesEntregas` ADD  DEFAULT ((0)) FOR `Unidad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CotizacionesEntregas` ADD  DEFAULT ((0)) FOR `Factor`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CotizacionesEntregas` ADD  DEFAULT ('') FOR `TipoDocumento`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CotizacionesEntregas` ADD  DEFAULT ((0)) FOR `NumeroDocumento`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Cuentas` ADD  DEFAULT ('') FOR `Titulo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Cuentas` ADD  DEFAULT ((0)) FOR `Status`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Cuentas` ADD  DEFAULT ((0)) FOR `Lado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Cuentas` ADD  DEFAULT ((0)) FOR `Saldo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Cuentas` ADD  DEFAULT ('') FOR `Alterno`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CuentasPOS` ADD  DEFAULT ((0)) FOR `tipo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CuentasPOS` ADD  DEFAULT ((0)) FOR `ownerID`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CuentasPOS` ADD  DEFAULT ('') FOR `CodigoCuenta`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CuentasPOS` ADD  DEFAULT (now(3)) FOR `HoraApertura`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CuentasPOS` ADD  DEFAULT (now(3)) FOR `HoraUltimaTransaccion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CuentasPOS` ADD  DEFAULT ('') FOR `Vendedor`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CuentasPOS` ADD  DEFAULT ((0)) FOR `Estado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CuentasPOS` ADD  DEFAULT ((1)) FOR `Personas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CuentasPOS` ADD  DEFAULT ('') FOR `Cliente`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CuentasPOS` ADD  DEFAULT ('') FOR `Ambiente`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CuentasPOS` ADD  DEFAULT ((0)) FOR `idMesa`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CuentasPOS` ADD  DEFAULT ('') FOR `Condiciones`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CuentasPOS` ADD  DEFAULT ('') FOR `Extra`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CuentasPOS` ADD  DEFAULT ((0)) FOR `Bloqueada`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CuentasPOS` ADD  DEFAULT (now(3)) FOR `horaBloqueo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CuentasPOS` ADD  DEFAULT ((0)) FOR `Correlativo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CuentasPOS` ADD  DEFAULT ('') FOR `codigoDescuento`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CuentasPOS` ADD  DEFAULT ('') FOR `autorizadoDescuento`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CuentasPOS` ADD  DEFAULT ('') FOR `explicacionDescuento`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CuentasPOS` ADD  DEFAULT ((0)) FOR `porcentajeDescuento`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CuentasPOS` ADD  DEFAULT ((1)) FOR `TipoCambio`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CVcajaDetalles` ADD  DEFAULT ((0)) FOR `idCEC`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CVcajaDetalles` ADD  DEFAULT ('') FOR `codigoMedio`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CVcajaDetalles` ADD  DEFAULT ((0)) FOR `valorMN`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `CVcajaDetalles` ADD  DEFAULT ((0)) FOR `valorNominal`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `descripcionRCP` ADD  DEFAULT ('') FOR `descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `descripcionRFP` ADD  DEFAULT ('') FOR `descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `descripcionRS` ADD  DEFAULT ('') FOR `Descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DescuentosSesion` ADD  DEFAULT ('ERROR') FOR `codigoMotivo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DescuentosSesion` ADD  DEFAULT ('ERROR') FOR `autorizadoDescuento`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DescuentosSesion` ADD  DEFAULT ('ERROR') FOR `explicacionDescuento`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DescuentosSesion` ADD  DEFAULT ((0)) FOR `porcentajeDescuento`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DescuentosSesion` ADD  DEFAULT (now(3)) FOR `Hora`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DescuentosSesion` ADD  DEFAULT ((0)) FOR `numeroTicket`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DescuentosSesion` ADD  DEFAULT ((0)) FOR `caja`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DescuentosSesion` ADD  DEFAULT ((0)) FOR `valorOriginal`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DescuentosSesion` ADD  DEFAULT ((0)) FOR `valorFinal`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Detalles` ADD  DEFAULT ('') FOR `NumeroComprobante`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Detalles` ADD  DEFAULT ('') FOR `NumeroLinea`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Detalles` ADD  DEFAULT ((0)) FOR `RefPeriodo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Detalles` ADD  DEFAULT ('') FOR `Cuenta`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Detalles` ADD  DEFAULT ('') FOR `RefDetalle`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Detalles` ADD  DEFAULT ('') FOR `Descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Detalles` ADD  DEFAULT ((0)) FOR `Debe`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Detalles` ADD  DEFAULT ((0)) FOR `Haber`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesAnulacionPOS` ADD  DEFAULT ((0)) FOR `numDevol`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesAnulacionPOS` ADD  DEFAULT ('') FOR `Producto`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesAnulacionPOS` ADD  DEFAULT ((0)) FOR `Cantidad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesAnulacionPOS` ADD  DEFAULT ((0)) FOR `PrecioUnitario`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesAnulacionPOS` ADD  DEFAULT ((0)) FOR `PorcentajeImpuesto`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesAnulacionPOS` ADD  DEFAULT ('') FOR `Usuario`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesCobranza` ADD  DEFAULT ((0)) FOR `MontoCobrado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesCobranza` ADD  DEFAULT ((0)) FOR `MontoNeto`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesCobranza` ADD  DEFAULT ((0)) FOR `RetencionIVA`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesCobranza` ADD  DEFAULT ((0)) FOR `RetencionISLR`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesCobranza` ADD  DEFAULT ((0)) FOR `NetoFacturas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesCobranza` ADD  DEFAULT ((0)) FOR `IVACobrado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesCobranza` ADD  DEFAULT ((0)) FOR `Descuentos`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesCompra` ADD  DEFAULT ((0)) FOR `NumeroDocumento`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesCompra` ADD  DEFAULT ((0)) FOR `Renglon`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesCompra` ADD  DEFAULT ('') FOR `CodigoItem`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesCompra` ADD  DEFAULT ('') FOR `Descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesCompra` ADD  DEFAULT ('') FOR `Presentacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesCompra` ADD  DEFAULT ((0)) FOR `FactorEmpaque`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesCompra` ADD  DEFAULT ((0)) FOR `CantidadFacturada`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesCompra` ADD  DEFAULT ((0)) FOR `CantidadPromocion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesCompra` ADD  DEFAULT ((0)) FOR `PrecioNominal`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesCompra` ADD  DEFAULT ((0)) FOR `PrecioEfectivo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesCompra` ADD  DEFAULT ((0)) FOR `Impuesto1`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesCompra` ADD  DEFAULT ((0)) FOR `Impuesto2`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesCompra` ADD  DEFAULT ((0)) FOR `CostoUnitario`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesCompra` ADD  DEFAULT ((0)) FOR `Recibidas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesCompra` ADD  DEFAULT ('') FOR `Almacen`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesCompra` ADD  DEFAULT ((0)) FOR `Devueltas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesCompra` ADD  DEFAULT ((0)) FOR `Recargos`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesCompra` ADD  DEFAULT ((0)) FOR `Piezas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesCuentaEntidad` ADD  DEFAULT ('') FOR `CodigoEntidad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesCuentaEntidad` ADD  DEFAULT ('') FOR `TipoEntidad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesCuentaEntidad` ADD  DEFAULT ((0)) FOR `Correlativo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesCuentaEntidad` ADD  DEFAULT ((0)) FOR `Documento`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesCuentaEntidad` ADD  DEFAULT (now(3)) FOR `Fecha`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesCuentaEntidad` ADD  DEFAULT ((0)) FOR `RefPeriodo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesCuentaEntidad` ADD  DEFAULT ('') FOR `Descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesCuentaEntidad` ADD  DEFAULT ((0)) FOR `Debe`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesCuentaEntidad` ADD  DEFAULT ((0)) FOR `Haber`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesCuentaEntidad` ADD  DEFAULT ('') FOR `TipoDocOrigen`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesCuentaEntidad` ADD  DEFAULT ((0)) FOR `NumeroDocOrigen`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesCuentaEntidad` ADD  DEFAULT ((1)) FOR `TipoCambio`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesDenominacion` ADD  DEFAULT ((0)) FOR `IdDetalle`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesDenominacion` ADD  DEFAULT ((0)) FOR `Denominacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesDenominacion` ADD  DEFAULT ((0)) FOR `CantidadRecibida`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesDevolucionCompra` ADD  DEFAULT ((0)) FOR `numeroDevolucion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesDevolucionCompra` ADD  DEFAULT ((0)) FOR `numeroRenglon`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesDevolucionCompra` ADD  DEFAULT ('') FOR `codigoItem`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesDevolucionCompra` ADD  DEFAULT ((0)) FOR `cantidadDevuelta`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesDevolucionCompra` ADD  DEFAULT ('') FOR `presentacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesDevolucionCompra` ADD  DEFAULT ((0)) FOR `factorEmpaque`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesDevolucionCompra` ADD  DEFAULT ('') FOR `descripcionItem`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesDevolucionCompra` ADD  DEFAULT ((0)) FOR `costo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesDevolucionCompra` ADD  DEFAULT ((0)) FOR `danhada`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesDevolucionCompra` ADD  DEFAULT ((0)) FOR `Piezas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesDevolucionVenta` ADD  DEFAULT ((0)) FOR `NumeroDevolucion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesDevolucionVenta` ADD  DEFAULT ((0)) FOR `NumeroRenglon`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesDevolucionVenta` ADD  DEFAULT ('') FOR `CodigoItemVenta`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesDevolucionVenta` ADD  DEFAULT ((0)) FOR `CantidadDevuelta`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesDevolucionVenta` ADD  DEFAULT ('') FOR `Presentacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesDevolucionVenta` ADD  DEFAULT ((0)) FOR `FactorEmpaque`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesDevolucionVenta` ADD  DEFAULT ('') FOR `DescripcionItem`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesDevolucionVenta` ADD  DEFAULT ((0)) FOR `Valor`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesDevolucionVenta` ADD  DEFAULT ((0)) FOR `Costo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesDevolucionVenta` ADD  DEFAULT ((0)) FOR `Danhada`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesDevolucionVenta` ADD  DEFAULT ((0)) FOR `Piezas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesFactura` ADD  DEFAULT ((0)) FOR `NumeroDocumento`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesFactura` ADD  DEFAULT ((0)) FOR `Renglon`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesFactura` ADD  DEFAULT ('') FOR `CodigoItem`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesFactura` ADD  DEFAULT ('') FOR `Descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesFactura` ADD  DEFAULT ('') FOR `Presentacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesFactura` ADD  DEFAULT ((0)) FOR `FactorEmpaque`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesFactura` ADD  DEFAULT ((0)) FOR `Cantidad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesFactura` ADD  DEFAULT ((0)) FOR `PrecioLista`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesFactura` ADD  DEFAULT ((0)) FOR `PrecioVenta`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesFactura` ADD  DEFAULT ((0)) FOR `PrecioEfectivo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesFactura` ADD  DEFAULT ((0)) FOR `Impuesto1`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesFactura` ADD  DEFAULT ((0)) FOR `Impuesto2`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesFactura` ADD  DEFAULT ((0)) FOR `CostoUnitario`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesFactura` ADD  DEFAULT ((0)) FOR `Entregadas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesFactura` ADD  DEFAULT ((0)) FOR `Asignadas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesFactura` ADD  DEFAULT ((0)) FOR `Transito`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesFactura` ADD  DEFAULT ((0)) FOR `Devueltas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesFactura` ADD  DEFAULT ((0)) FOR `Piezas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesIngresoCaja` ADD  DEFAULT ((0)) FOR `TransID`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesIngresoCaja` ADD  DEFAULT ('') FOR `Medio`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesIngresoCaja` ADD  DEFAULT ('') FOR `Emisor`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesIngresoCaja` ADD  DEFAULT ('') FOR `NumeroDocumento`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesIngresoCaja` ADD  DEFAULT ('') FOR `ClaveAutorizacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesIngresoCaja` ADD  DEFAULT ((0)) FOR `Monto`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesIngresoCaja` ADD  DEFAULT ('') FOR `NumeroCuenta`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesIngresoCaja` ADD  DEFAULT ('') FOR `idTitular`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesIngresoCaja` ADD  DEFAULT ((0)) FOR `MontoNominal`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesItemVenta` ADD  DEFAULT ((0)) FOR `NumeroDocumento`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesItemVenta` ADD  DEFAULT ('???') FOR `TipoDocumento`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesItemVenta` ADD  DEFAULT ('') FOR `Serie`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesItemVenta` ADD  DEFAULT (now(3)) FOR `FechaOperacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesItemVenta` ADD  DEFAULT ('') FOR `CodigoItem`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesItemVenta` ADD  DEFAULT ('') FOR `CodigoCliente`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesItemVenta` ADD  DEFAULT ('') FOR `CodigoVendedor`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesItemVenta` ADD  DEFAULT ((0)) FOR `PrecioReferencia`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesItemVenta` ADD  DEFAULT ((0)) FOR `PrecioVenta`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesItemVenta` ADD  DEFAULT ((0)) FOR `Cantidad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesItemVenta` ADD  DEFAULT ((0)) FOR `CostoStandard`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesMINV` ADD  DEFAULT ((0)) FOR `NumeroDocumento`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesMINV` ADD  DEFAULT ((0)) FOR `Renglon`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesMINV` ADD  DEFAULT (now(3)) FOR `FechaOperacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesMINV` ADD  DEFAULT ('') FOR `TipoMovimiento`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesMINV` ADD  DEFAULT ('') FOR `CodigoItem`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesMINV` ADD  DEFAULT ((0)) FOR `Entradas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesMINV` ADD  DEFAULT ((0)) FOR `Salidas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesMINV` ADD  DEFAULT ((0)) FOR `Costo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DetallesTA` ADD  DEFAULT ((0)) FOR `Piezas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DevolucionesCompra` ADD  DEFAULT ((0)) FOR `Numero`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DevolucionesCompra` ADD  DEFAULT (now(3)) FOR `FechaRegistro`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DevolucionesCompra` ADD  DEFAULT (now(3)) FOR `FechaTransaccion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DevolucionesCompra` ADD  DEFAULT ('') FOR `Operador`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DevolucionesCompra` ADD  DEFAULT ('') FOR `CodigoProveedor`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DevolucionesCompra` ADD  DEFAULT ((0)) FOR `Factura`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DevolucionesCompra` ADD  DEFAULT ((0)) FOR `ValorMercancia`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DevolucionesCompra` ADD  DEFAULT ((0)) FOR `Impuesto1`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DevolucionesCompra` ADD  DEFAULT ((0)) FOR `Impuesto2`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DevolucionesCompra` ADD  DEFAULT ('') FOR `Notas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DevolucionesCompra` ADD  DEFAULT ('') FOR `RefProveedor`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DevolucionesCompra` ADD  DEFAULT ('') FOR `TipoDocumento`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DevolucionesVenta` ADD  DEFAULT ('') FOR `Serie`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DevolucionesVenta` ADD  DEFAULT (now(3)) FOR `FechaRegistro`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DevolucionesVenta` ADD  DEFAULT (now(3)) FOR `FechaTransaccion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DevolucionesVenta` ADD  DEFAULT ('') FOR `Operador`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DevolucionesVenta` ADD  DEFAULT ((0)) FOR `NumeroFactura`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DevolucionesVenta` ADD  DEFAULT ('') FOR `CodigoCliente`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DevolucionesVenta` ADD  DEFAULT ('') FOR `NombreCliente`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DevolucionesVenta` ADD  DEFAULT ((0)) FOR `Valor`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DevolucionesVenta` ADD  DEFAULT ((0)) FOR `Impuesto1`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DevolucionesVenta` ADD  DEFAULT ((0)) FOR `Impuesto2`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DevolucionesVenta` ADD  DEFAULT ((0)) FOR `Costo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DevolucionesVenta` ADD  DEFAULT ('') FOR `Notas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DevolucionesVenta` ADD  DEFAULT ('') FOR `CodigoVendedor`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DevolucionesVenta` ADD  DEFAULT ((0)) FOR `ComisionAnulada`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DiferidosBanco` ADD  DEFAULT ('') FOR `CodigoBanco`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DiferidosBanco` ADD  DEFAULT (now(3)) FOR `FechaPresentacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DiferidosBanco` ADD  DEFAULT ((0)) FOR `MontoDiferido`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DiferidosBanco` ADD  DEFAULT ((0)) FOR `TipoMovimiento`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DiferidosBanco` ADD  DEFAULT ('') FOR `Descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DiferidosBanco` ADD  DEFAULT ('') FOR `RefBanco`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DocumentosFiscales` ADD  DEFAULT (now(3)) FOR `Fecha`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DocumentosFiscales` ADD  DEFAULT ('') FOR `TipoDoc`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DocumentosFiscales` ADD  DEFAULT ((0)) FOR `NumeroDoc`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DocumentosFiscales` ADD  DEFAULT ('') FOR `TipoEntidad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DocumentosFiscales` ADD  DEFAULT ('') FOR `CodigoEntidad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DocumentosFiscales` ADD  DEFAULT ('') FOR `Referencia`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DocumentosFiscales` ADD  DEFAULT ('') FOR `NumeroControlInicial`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DocumentosFiscales` ADD  DEFAULT ('') FOR `NumeroControlFinal`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DocumentosFiscales` ADD  DEFAULT ('') FOR `FacturaRelacionada`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DocumentosFiscales` ADD  DEFAULT ((0)) FOR `Exento`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DocumentosFiscales` ADD  DEFAULT ((0)) FOR `Gravable1`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DocumentosFiscales` ADD  DEFAULT ((0)) FOR `Tasa1`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DocumentosFiscales` ADD  DEFAULT ((0)) FOR `Gravable2`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DocumentosFiscales` ADD  DEFAULT ((0)) FOR `Tasa2`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DocumentosFiscales` ADD  DEFAULT ((0)) FOR `Impuesto1`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DocumentosFiscales` ADD  DEFAULT ((0)) FOR `Impuesto2`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DocumentosFiscales` ADD  DEFAULT ((0)) FOR `Retencion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DocumentosFiscales` ADD  DEFAULT ('') FOR `TipoDocFiscal`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DocumentosFiscales` ADD  DEFAULT ('') FOR `RifEntidad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DocumentosFiscales` ADD  DEFAULT ('') FOR `NombreEntidad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DocumentosFiscales` ADD  DEFAULT ((0)) FOR `Relacionado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DocumentosFiscales` ADD  DEFAULT ((0)) FOR `Importado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DocumentosFiscales` ADD  DEFAULT ((0)) FOR `Contribuyente`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DocumentosFiscales` ADD  DEFAULT (now(3)) FOR `FechaNacionalizacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DocumentosFiscales` ADD  DEFAULT ('') FOR `DocumentoNacionalizacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DocumentosFiscales` ADD  DEFAULT ((0)) FOR `Reporte`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DocumentosISPC` ADD  DEFAULT ('') FOR `TipoEntidad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DocumentosISPC` ADD  DEFAULT ('') FOR `CodigoEntidad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DocumentosISPC` ADD  DEFAULT ((0)) FOR `NumDoc`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DocumentosISPC` ADD  DEFAULT ('') FOR `TipoDoc`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DocumentosISPC` ADD  DEFAULT (now(3)) FOR `FechaDoc`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DocumentosISPC` ADD  DEFAULT ((0)) FOR `Monto`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DocumentosISPC` ADD  DEFAULT ((0)) FOR `Saldo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DocumentosISPC` ADD  DEFAULT ((1)) FOR `TipoCambio`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `DocumentosISPC` ADD  DEFAULT ((1)) FOR `TipoCambioOriginal`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `EliminacionesPOS` ADD  DEFAULT ('') FOR `Cuenta`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `EliminacionesPOS` ADD  DEFAULT ('') FOR `Autorizado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `EliminacionesPOS` ADD  DEFAULT (now(3)) FOR `Hora`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `EliminacionesPOS` ADD  DEFAULT ((0)) FOR `numCta`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Empaques` ADD  DEFAULT ((0)) FOR `Factor`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ExistenciaUbicacion` ADD  DEFAULT ('') FOR `CodigoItem`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ExistenciaUbicacion` ADD  DEFAULT ((0)) FOR `TipoUbicacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ExistenciaUbicacion` ADD  DEFAULT ('') FOR `Almacen`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ExistenciaUbicacion` ADD  DEFAULT ((0)) FOR `Existencia`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ExistenciaUbicacion` ADD  DEFAULT ((0)) FOR `Asignadas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ExistenciaUbicacion` ADD  DEFAULT ((0)) FOR `Piezas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `extDesc` ADD  DEFAULT ('') FOR `codigoItem`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `extDesc` ADD  DEFAULT ('') FOR `value`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Facturas` ADD  DEFAULT (now(3)) FOR `FechaRegistro`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Facturas` ADD  DEFAULT (now(3)) FOR `FechaTransaccion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Facturas` ADD  DEFAULT ('') FOR `Operador`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Facturas` ADD  DEFAULT ('') FOR `Serie`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Facturas` ADD  DEFAULT ((0)) FOR `Correlativo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Facturas` ADD  DEFAULT ('') FOR `ExtRef`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Facturas` ADD  DEFAULT ('') FOR `CodigoCliente`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Facturas` ADD  DEFAULT ('') FOR `NombreCliente`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Facturas` ADD  DEFAULT ('') FOR `CodigoVendedor`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Facturas` ADD  DEFAULT ((0)) FOR `EstadoDespacho`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Facturas` ADD  DEFAULT ((0)) FOR `PrecioLista`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Facturas` ADD  DEFAULT ((0)) FOR `PrecioVenta`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Facturas` ADD  DEFAULT ((0)) FOR `PrecioEfectivo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Facturas` ADD  DEFAULT ((0)) FOR `Impuesto1`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Facturas` ADD  DEFAULT ((0)) FOR `Impuesto2`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Facturas` ADD  DEFAULT ((0)) FOR `IndiceReferencia`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Facturas` ADD  DEFAULT ((0)) FOR `IndiceVenta`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Facturas` ADD  DEFAULT ((0)) FOR `Descuento1`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Facturas` ADD  DEFAULT ((0)) FOR `Descuento2`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Facturas` ADD  DEFAULT ((0)) FOR `Costo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Facturas` ADD  DEFAULT ((0)) FOR `SituacionAdministrativa`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Facturas` ADD  DEFAULT ('') FOR `Condicion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Facturas` ADD  DEFAULT ((0)) FOR `DescuentosProntoPago`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Facturas` ADD  DEFAULT ((0)) FOR `Comision`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Facturas` ADD  DEFAULT ((0)) FOR `ComisionAcreditada`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Facturas` ADD  DEFAULT ('') FOR `DireccionEntrega`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Facturas` ADD  DEFAULT ('') FOR `Notas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Facturas` ADD  DEFAULT ((0)) FOR `OrdenDespacho`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Facturas` ADD  DEFAULT ((0)) FOR `ComprobanteInventario`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Facturas` ADD  DEFAULT ((0)) FOR `PrecioDevuelto`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Facturas` ADD  DEFAULT ((0)) FOR `CostoDevuelto`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Facturas` ADD  DEFAULT ((0)) FOR `Saldo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Facturas` ADD  DEFAULT ((0)) FOR `Impuesto1Devuelto`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Facturas` ADD  DEFAULT ((0)) FOR `Impuesto2Devuelto`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Facturas` ADD  DEFAULT ('') FOR `Almacen`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Facturas` ADD  DEFAULT ((1)) FOR `TipoCambio`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `FacturasPOS` ADD  DEFAULT (now(3)) FOR `Hora`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `FacturasPOS` ADD  DEFAULT ((0)) FOR `tipoConsumo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `FacturasPOS` ADD  DEFAULT ((1)) FOR `TipoCambio`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `generalEmisores` ADD  DEFAULT ('') FOR `TipoDocumento`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `generalEmisores` ADD  DEFAULT ('') FOR `CodigoEmisor`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `HotKeys` ADD  DEFAULT ('') FOR `Tecla`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `HotKeys` ADD  DEFAULT ('') FOR `Normal`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `htc` ADD  DEFAULT (now(3)) FOR `hora`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Indicadores` ADD  DEFAULT ('') FOR `Codigo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Indicadores` ADD  DEFAULT ('') FOR `Formula`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Indicadores` ADD  DEFAULT (now(3)) FOR `Modificado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Indicadores` ADD  DEFAULT ('') FOR `Autor`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `itemsInventario` ADD  DEFAULT ('') FOR `Descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `itemsInventario` ADD  DEFAULT ('') FOR `Linea`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `itemsInventario` ADD  DEFAULT ((0)) FOR `CostoPromedio`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `itemsInventario` ADD  DEFAULT ((0)) FOR `UltimoCosto`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `itemsInventario` ADD  DEFAULT ('') FOR `ClaseImpuesto1`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `itemsInventario` ADD  DEFAULT ('') FOR `ClaseImpuesto2`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `itemsInventario` ADD  DEFAULT ((0)) FOR `Existencia`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `itemsInventario` ADD  DEFAULT ((0)) FOR `Asignadas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `itemsInventario` ADD  DEFAULT ((0)) FOR `EnTransito`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `itemsInventario` ADD  DEFAULT ('19000101') FOR `FechaUltimaCompra`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `itemsInventario` ADD  DEFAULT ('') FOR `UltimoProveedor`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `itemsInventario` ADD  DEFAULT ((0)) FOR `PrecioUltimaCompra`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `itemsInventario` ADD  DEFAULT ('') FOR `CuentaActivo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `itemsInventario` ADD  DEFAULT ('') FOR `CostoDeVentas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `itemsInventario` ADD  DEFAULT ('') FOR `NombreUnidad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `itemsInventario` ADD  DEFAULT ('') FOR `NombreEmpaque`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `itemsInventario` ADD  DEFAULT ((1)) FOR `CantidadEmpaque`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `itemsInventario` ADD  DEFAULT ((0)) FOR `ExistenciaMinima`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `itemsInventario` ADD  DEFAULT ((0)) FOR `ExistenciaMaxima`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `itemsInventario` ADD  DEFAULT ((0)) FOR `UsaSeriales`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `itemsInventario` ADD  DEFAULT (now(3)) FOR `FechaCreacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `itemsInventario` ADD  DEFAULT ('') FOR `Grupo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `itemsInventario` ADD  DEFAULT ((0)) FOR `Consignadas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `itemsInventario` ADD  DEFAULT ((0)) FOR `Importado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `itemsInventario` ADD  DEFAULT ((0)) FOR `CostoME`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `itemsInventario` ADD  DEFAULT ('') FOR `Ubicacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `itemsInventario` ADD  DEFAULT ((0)) FOR `peso`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `itemsInventario` ADD  DEFAULT ('') FOR `clasif3`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `itemsInventario` ADD  DEFAULT ('') FOR `proveedorPreferido`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `itemsInventario` ADD  DEFAULT ((0)) FOR `merma`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `itemsInventario` ADD  DEFAULT ((0)) FOR `diasStock`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `itemsInventario` ADD  DEFAULT ((0)) FOR `ControlarPiezas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `itemsInventario` ADD  DEFAULT ((0)) FOR `Piezas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ItemsVenta` ADD  DEFAULT ('') FOR `Linea`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ItemsVenta` ADD  DEFAULT ('') FOR `Descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ItemsVenta` ADD  DEFAULT ('') FOR `CuentaIngreso`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ItemsVenta` ADD  DEFAULT ('') FOR `CuentaDevolucion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ItemsVenta` ADD  DEFAULT ('') FOR `CuentaCosto`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ItemsVenta` ADD  DEFAULT ((0)) FOR `Precio1`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ItemsVenta` ADD  DEFAULT ((0)) FOR `Precio2`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ItemsVenta` ADD  DEFAULT ((0)) FOR `Precio3`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ItemsVenta` ADD  DEFAULT ((0)) FOR `Precio4`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ItemsVenta` ADD  DEFAULT ('') FOR `TipoImpuesto1`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ItemsVenta` ADD  DEFAULT ('') FOR `TipoImpuesto2`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ItemsVenta` ADD  DEFAULT ((0)) FOR `CostoStandard`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ItemsVenta` ADD  DEFAULT ((0)) FOR `PComis1`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ItemsVenta` ADD  DEFAULT ((0)) FOR `PComis2`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ItemsVenta` ADD  DEFAULT ((0)) FOR `PComis3`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ItemsVenta` ADD  DEFAULT ('') FOR `Presentacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ItemsVenta` ADD  DEFAULT ('') FOR `Unidad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ItemsVenta` ADD  DEFAULT ((0)) FOR `CantidadPresentacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ItemsVenta` ADD  DEFAULT ((0)) FOR `NumeroPLU`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ItemsVenta` ADD  DEFAULT ((0)) FOR `PrecioIndexado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ItemsVenta` ADD  DEFAULT (now(3)) FOR `FechaCreacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ItemsVenta` ADD  DEFAULT ('') FOR `ImageFile`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ItemsVenta` ADD  DEFAULT ('') FOR `Ubicacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ItemsVenta` ADD  DEFAULT ('') FOR `Grupo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ItemsVenta` ADD  DEFAULT ((0)) FOR `porcentajeImputable`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ItemsVenta` ADD  DEFAULT ((0)) FOR `Regulado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ItemsVenta` ADD  DEFAULT ((0)) FOR `isCostoME`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ItemsVenta` ADD  DEFAULT ('') FOR `clasif3`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Lineas` ADD  DEFAULT ('') FOR `Codigo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Lineas` ADD  DEFAULT ('') FOR `Descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MediosPago` ADD  DEFAULT ((0)) FOR `Atributos`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MediosPago` ADD  DEFAULT ((0)) FOR `PorcentajeRetencionEmisor`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MediosPago` ADD  DEFAULT ((0)) FOR `PorcentajeISLR`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MediosPago` ADD  DEFAULT ('') FOR `CuentaActivo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MediosPago` ADD  DEFAULT ('') FOR `CuentaComisiones`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MediosPago` ADD  DEFAULT ('') FOR `BancoRelacionado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MediosPago` ADD  DEFAULT ((0)) FOR `Clase`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MediosPago` ADD  DEFAULT ('') FOR `titulo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MediosPago` ADD  DEFAULT ('') FOR `textoAyuda`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MediosPago` ADD  DEFAULT ((1)) FOR `posicion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MediosPago` ADD  DEFAULT ((0)) FOR `isMedioElectronico`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mensajesInternos` ADD  DEFAULT (now(3)) FOR `fechaCreacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mensajesInternos` ADD  DEFAULT ((0)) FOR `idOrigen`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mensajesLeidos` ADD  DEFAULT (now(3)) FOR `fechaLectura`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mesasAmbientes` ADD  DEFAULT ('') FOR `Codigo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mesasAmbientes` ADD  DEFAULT ('') FOR `Prefijo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mesasAmbientes` ADD  DEFAULT ('') FOR `Descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mesasAmbientes` ADD  DEFAULT ((0)) FOR `AccountOffset`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mesasAmbientes` ADD  DEFAULT ((0)) FOR `PorcentajeServicio`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mesasAmbientes` ADD  DEFAULT ((0)) FOR `IndicePrecio`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mesasAmbientes` ADD  DEFAULT ((0)) FOR `Escala`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mesasAmbientes` ADD  DEFAULT ((0)) FOR `BackColor`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mesasAmbientes` ADD  DEFAULT ((0)) FOR `ColorSillas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mesasAmbientes` ADD  DEFAULT ((0)) FOR `ColorMesas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mesasAmbientes` ADD  DEFAULT ((0)) FOR `FormaMesas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mesasAmbientes` ADD  DEFAULT ((0)) FOR `FormaSillas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mesasAmbientes` ADD  DEFAULT ((0)) FOR `SillasVisibles`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mesasAmbientes` ADD  DEFAULT ('') FOR `imagenFondo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mesasItems` ADD  DEFAULT ('') FOR `Codigo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mesasItems` ADD  DEFAULT ((0)) FOR `Precio`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mesasMesas` ADD  DEFAULT ('') FOR `Ambiente`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mesasMesas` ADD  DEFAULT ((0)) FOR `IDMesa`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mesasMesas` ADD  DEFAULT ((0)) FOR `x`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mesasMesas` ADD  DEFAULT ((0)) FOR `y`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mesasMesas` ADD  DEFAULT ((0)) FOR `enmStat`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mesasMesas` ADD  DEFAULT ((0)) FOR `nPersonas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mesasMesas` ADD  DEFAULT ('') FOR `cMesonero`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mesasMesas` ADD  DEFAULT ((0)) FOR `MontoDespachado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mesasMesas` ADD  DEFAULT (now(3)) FOR `Apertura`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mesasMesas` ADD  DEFAULT ((0)) FOR `Cuenta`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mesasMesas` ADD  DEFAULT ((0)) FOR `idTipo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mnuDeclares` ADD  DEFAULT ('') FOR `ownerMenu`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mnuDeclares` ADD  DEFAULT ('') FOR `Descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mnuDeclares` ADD  DEFAULT ('') FOR `imageFile`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mnuItems` ADD  DEFAULT ('') FOR `ownerMenu`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mnuItems` ADD  DEFAULT ((0)) FOR `Posicion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mnuItems` ADD  DEFAULT ((0)) FOR `isTerminal`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mnuItems` ADD  DEFAULT ('') FOR `CodigoItem`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mnuItems` ADD  DEFAULT ('') FOR `Imagen`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mnuItems` ADD  DEFAULT ('') FOR `Descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mnuItems` ADD  DEFAULT ((0)) FOR `Color`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mnuItems` ADD  DEFAULT ('') FOR `ExtDesc`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `mnuItems` ADD  DEFAULT ((0)) FOR `textColor`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MotivosDescuento` ADD  DEFAULT ((0)) FOR `porcentaje`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MotivosDescuento` ADD  DEFAULT ((1)) FOR `respetarMinimos`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MotivosDescuento` ADD  DEFAULT ((1)) FOR `nivelAutorizacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MotivosDescuento` ADD  DEFAULT ((0)) FOR `detallesModificables`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MovimientosBanco` ADD  DEFAULT (now(3)) FOR `FechaRegistro`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MovimientosBanco` ADD  DEFAULT (now(3)) FOR `FechaTransaccion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MovimientosBanco` ADD  DEFAULT ('') FOR `Operador`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MovimientosBanco` ADD  DEFAULT ('') FOR `CodigoBanco`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MovimientosBanco` ADD  DEFAULT ((0)) FOR `Tipo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MovimientosBanco` ADD  DEFAULT ('') FOR `Concepto`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MovimientosBanco` ADD  DEFAULT ('') FOR `Beneficiario`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MovimientosBanco` ADD  DEFAULT ((0)) FOR `Monto`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MovimientosBanco` ADD  DEFAULT ('') FOR `ReferenciaBanco`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MovimientosBanco` ADD  DEFAULT ((0)) FOR `Conciliado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MovimientosBanco` ADD  DEFAULT (now(3)) FOR `FechaEfectivo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MovimientosBanco` ADD  DEFAULT ('') FOR `TipoDocRel`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MovimientosBanco` ADD  DEFAULT ((0)) FOR `NumeroDocRel`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MovimientosBanco` ADD  DEFAULT ((0)) FOR `Comision`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MovimientosBanco` ADD  DEFAULT ((0)) FOR `RetencionISLR`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MovimientosBanco` ADD  DEFAULT ('') FOR `Clasificacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MovimientosBanco` ADD  DEFAULT ((0)) FOR `valorMN`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MovimientosBanco` ADD  DEFAULT ((0)) FOR `montoIGTF`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MovimientosCaja` ADD  DEFAULT ((0)) FOR `Sesion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MovimientosCaja` ADD  DEFAULT ((0)) FOR `Debitos`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MovimientosCaja` ADD  DEFAULT ((0)) FOR `Creditos`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MovimientosCaja` ADD  DEFAULT ('') FOR `TipoEntidad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MovimientosCaja` ADD  DEFAULT ('') FOR `CodigoEntidad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MovimientosCaja` ADD  DEFAULT ('') FOR `TipoDocumento`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MovimientosCaja` ADD  DEFAULT ((0)) FOR `NumeroDocumento`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MovimientosCaja` ADD  DEFAULT (now(3)) FOR `Fecha`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MovimientosCaja` ADD  DEFAULT ('') FOR `Clasificacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MovimientosCaja` ADD  DEFAULT ('') FOR `Beneficiario`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MovimientosCaja` ADD  DEFAULT ((0)) FOR `MachineID`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MovimientosCaja` ADD  DEFAULT ((0)) FOR `montoIGTF`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `MovimientosCaja` ADD  DEFAULT ((1)) FOR `TipoCambio`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NCPOS` ADD  DEFAULT (now(3)) FOR `Hora`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NCPOS` ADD  DEFAULT ((0)) FOR `montoVenta`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NCPOS` ADD  DEFAULT ((0)) FOR `numeroNotaRelacionada`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NCPOS` ADD  DEFAULT ('') FOR `codigoCliente`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEE` ADD  DEFAULT ((0)) FOR `Numero`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEE` ADD  DEFAULT (now(3)) FOR `FechaRegistro`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEE` ADD  DEFAULT (now(3)) FOR `FechaTransaccion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEE` ADD  DEFAULT ('') FOR `Operador`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEE` ADD  DEFAULT ('') FOR `CodigoCliente`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEE` ADD  DEFAULT ('') FOR `NombreCliente`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEE` ADD  DEFAULT ('') FOR `CodigoVendedor`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEE` ADD  DEFAULT ((0)) FOR `Estado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEE` ADD  DEFAULT ((0)) FOR `PrecioLista`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEE` ADD  DEFAULT ((0)) FOR `PrecioVenta`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEE` ADD  DEFAULT ((0)) FOR `PrecioEfectivo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEE` ADD  DEFAULT ((0)) FOR `Impuesto1`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEE` ADD  DEFAULT ((0)) FOR `Impuesto2`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEE` ADD  DEFAULT ((0)) FOR `IndiceReferencia`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEE` ADD  DEFAULT ((0)) FOR `IndiceVenta`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEE` ADD  DEFAULT ((0)) FOR `Descuento1`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEE` ADD  DEFAULT ((0)) FOR `Descuento2`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEE` ADD  DEFAULT ('') FOR `Condicion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEE` ADD  DEFAULT ('') FOR `DireccionEntrega`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEE` ADD  DEFAULT ('') FOR `Notas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEE` ADD  DEFAULT ((0)) FOR `ComprobanteAlmacen`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEE` ADD  DEFAULT ((0)) FOR `NumeroFacturaOrigen`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEE` ADD  DEFAULT ((0)) FOR `SaldoActual`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEE` ADD  DEFAULT ((1)) FOR `TipoCambio`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEEDetalles` ADD  DEFAULT ((0)) FOR `NumeroDocumento`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEEDetalles` ADD  DEFAULT ((0)) FOR `Renglon`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEEDetalles` ADD  DEFAULT ('') FOR `CodigoItem`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEEDetalles` ADD  DEFAULT ('') FOR `Descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEEDetalles` ADD  DEFAULT ('') FOR `Presentacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEEDetalles` ADD  DEFAULT ((0)) FOR `FactorEmpaque`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEEDetalles` ADD  DEFAULT ((0)) FOR `Cantidad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEEDetalles` ADD  DEFAULT ((0)) FOR `PrecioLista`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEEDetalles` ADD  DEFAULT ((0)) FOR `PrecioVenta`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEEDetalles` ADD  DEFAULT ((0)) FOR `PrecioEfectivo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEEDetalles` ADD  DEFAULT ((0)) FOR `Impuesto1`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEEDetalles` ADD  DEFAULT ((0)) FOR `Impuesto2`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEEDetalles` ADD  DEFAULT ((0)) FOR `CostoUnitario`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEEDetalles` ADD  DEFAULT ((0)) FOR `SaldoCantidad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEEDetalles` ADD  DEFAULT ('') FOR `Descuentos`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEEDetalles` ADD  DEFAULT ((0)) FOR `Piezas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEEDetalleSuplemento` ADD  DEFAULT ((0)) FOR `NumeroDocumento`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEEDetalleSuplemento` ADD  DEFAULT ((0)) FOR `Renglon`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEEDetalleSuplemento` ADD  DEFAULT ((0)) FOR `NumeroRenglonOrigen`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEEDetalleSuplemento` ADD  DEFAULT ('') FOR `CodigoItem`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEEDetalleSuplemento` ADD  DEFAULT ((0)) FOR `Cantidad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEEDetalleSuplemento` ADD  DEFAULT ('') FOR `Presentacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEEDetalleSuplemento` ADD  DEFAULT ((0)) FOR `FactorPresentacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEEDetalleSuplemento` ADD  DEFAULT ((0)) FOR `PrecioNeto`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEEDetalleSuplemento` ADD  DEFAULT ((0)) FOR `Impuesto1`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEEDetalleSuplemento` ADD  DEFAULT ((0)) FOR `Impuesto2`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEEDetalleSuplemento` ADD  DEFAULT ((0)) FOR `Piezas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEEDevDetalles` ADD  DEFAULT ((0)) FOR `Renglon`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEEDevDetalles` ADD  DEFAULT ((0)) FOR `Piezas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEEDevoluciones` ADD  DEFAULT (now(3)) FOR `FechaRegistro`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEESuplemento` ADD  DEFAULT ((0)) FOR `NumeroNota`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEESuplemento` ADD  DEFAULT (now(3)) FOR `FechaRegistro`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEESuplemento` ADD  DEFAULT ('') FOR `Operador`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEESuplemento` ADD  DEFAULT (now(3)) FOR `FechaTransaccion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEESuplemento` ADD  DEFAULT ('') FOR `CodigoCliente`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEESuplemento` ADD  DEFAULT ('') FOR `Descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEESuplemento` ADD  DEFAULT ((0)) FOR `Impuesto1`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEESuplemento` ADD  DEFAULT ((0)) FOR `Impuesto2`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEESuplemento` ADD  DEFAULT ((0)) FOR `Valor`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEESuplemento` ADD  DEFAULT ('') FOR `TipoDocRel`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NNEESuplemento` ADD  DEFAULT ((0)) FOR `NumeroDocRel`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `nomAsigDedScript` ADD  DEFAULT ('') FOR `CodigoScript`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `nomAsigDedScript` ADD  DEFAULT ('') FOR `codigoAsigDed`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `nomAsigDedScript` ADD  DEFAULT ((0)) FOR `Orden`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `nomAtribTrabajador` ADD  DEFAULT ('') FOR `CodTrab`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `nomAtribTrabajador` ADD  DEFAULT ('') FOR `CodAttrib`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `nomAtribTrabajador` ADD  DEFAULT ((0)) FOR `ValAttrib`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `nomDetallesProceso` ADD  DEFAULT ('') FOR `CodigoCuenta`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `nomDetallesProceso` ADD  DEFAULT ('') FOR `CodigoContrapartida`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `nomDetallesProceso` ADD  DEFAULT ('') FOR `CodigoRecibo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `nomDetallesProceso` ADD  DEFAULT ('') FOR `CodigoAsigDed`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `nomDetallesProceso` ADD  DEFAULT ((0)) FOR `Valor`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `nomDetallesProceso` ADD  DEFAULT ((0)) FOR `Cantidad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `nomExcepcionesProceso` ADD  DEFAULT ((0)) FOR `Valor`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `nomExcepcionesProceso` ADD  DEFAULT ((0)) FOR `TipoRecurrencia`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `nomExcepcionesProceso` ADD  DEFAULT ((0)) FOR `Recurrencia`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `nomExcepcionesProceso` ADD  DEFAULT ('') FOR `Operador`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `nomExcepcionesProceso` ADD  DEFAULT (now(3)) FOR `FechaRegistro`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `nomHabilidadesTrabajador` ADD  DEFAULT ('') FOR `Notas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `nomParametrosGenerales` ADD  DEFAULT ((0)) FOR `sueldoMinimo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `nomPrestamos` ADD  DEFAULT (now(3)) FOR `fechaRegistro`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `nomProcesos` ADD  DEFAULT ((0)) FOR `Operador`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `nomSalarioMinimo` ADD  DEFAULT ('18000101') FOR `Fecha`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `nomSalarioMinimo` ADD  DEFAULT ((0)) FOR `NetoVEF`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `nomSalarioMinimo` ADD  DEFAULT ((0)) FOR `BonoVEF`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `nomSalarioMinimo` ADD  DEFAULT ((0)) FOR `AJUSTE`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `nomTasas6PB` ADD  DEFAULT ((0)) FOR `tasa`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `nomTMPListaExcepciones` ADD  DEFAULT ('') FOR `Notas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `nomTMPListaExcepciones` ADD  DEFAULT ((0)) FOR `TipoRecurrencia`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `nomTMPListaExcepciones` ADD  DEFAULT ((0)) FOR `Recurrencia`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `nomTMPListaExcepciones` ADD  DEFAULT ('') FOR `Operador`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `nomTrabajadores` ADD  DEFAULT ((0)) FOR `Activo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `nomTrabajadores` ADD  DEFAULT ('') FOR `ImageFile`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `nomTrabajadores` ADD  DEFAULT ((0)) FOR `EstadoAcceso`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `nomTrabajadores` ADD  DEFAULT ((0)) FOR `ganaSueldoMinimo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `nomTrabajadores` ADD  DEFAULT ('') FOR `cuentaBancaria`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `notas` ADD  DEFAULT ('') FOR `tipoEntidad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `notas` ADD  DEFAULT ('') FOR `codigoEntidad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `notas` ADD  DEFAULT (now(3)) FOR `fecha`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `notas` ADD  DEFAULT ('') FOR `contenido`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `notas` ADD  DEFAULT ('') FOR `codigoOperador`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NotasDCCP` ADD  DEFAULT ((0)) FOR `Numero`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NotasDCCP` ADD  DEFAULT ((0)) FOR `Correlativo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NotasDCCP` ADD  DEFAULT ('') FOR `Serie`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NotasDCCP` ADD  DEFAULT ((0)) FOR `correlativoSerie`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NotasDCCP` ADD  DEFAULT ('') FOR `TipoEntidad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NotasDCCP` ADD  DEFAULT ('') FOR `CodigoEntidad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NotasDCCP` ADD  DEFAULT (now(3)) FOR `FechaDoc`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NotasDCCP` ADD  DEFAULT ('') FOR `Descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NotasDCCP` ADD  DEFAULT ((0)) FOR `Monto`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NotasDCCP` ADD  DEFAULT ((0)) FOR `Saldo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NotasDCCP` ADD  DEFAULT ('') FOR `Operador`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NotasDCCP` ADD  DEFAULT ((0)) FOR `TipoOperacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NotasDCCP` ADD  DEFAULT ((0)) FOR `DocumentoOrigen`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `NotasDCCP` ADD  DEFAULT ('') FOR `Clasificacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ocDetalles` ADD  DEFAULT ((0)) FOR `NumeroDocumento`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ocDetalles` ADD  DEFAULT ((0)) FOR `Renglon`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ocDetalles` ADD  DEFAULT ('') FOR `CodigoItem`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ocDetalles` ADD  DEFAULT ('') FOR `Descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ocDetalles` ADD  DEFAULT ('UND.') FOR `Presentacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ocDetalles` ADD  DEFAULT ((1)) FOR `FactorEmpaque`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ocDetalles` ADD  DEFAULT ((0)) FOR `Cantidad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ocDetalles` ADD  DEFAULT ((0)) FOR `PrecioRequerido`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ocDetalles` ADD  DEFAULT ((0)) FOR `Recibidas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ocDetalles` ADD  DEFAULT ((0)) FOR `PrecioMedio`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ocDetalles` ADD  DEFAULT ((0)) FOR `CantPaga`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ocDetalles` ADD  DEFAULT ((0)) FOR `CantPromo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ocDetalles` ADD  DEFAULT ((0)) FOR `PVP`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ocDetalles` ADD  DEFAULT ('') FOR `Descuentos`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ocOrdenes` ADD  DEFAULT ((1)) FOR `TipoCambio`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Opciones` ADD  DEFAULT ('') FOR `TipoOpcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Opciones` ADD  DEFAULT ('') FOR `CodigoItem`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Opciones` ADD  DEFAULT ('') FOR `Descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Opciones` ADD  DEFAULT ('') FOR `Pedido`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `RIF`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `NIT`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `Direccion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `Telefono`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `MascaraPrecios`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `MascaraMonetarios`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `MascaraInventario`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `MascaraCantidades`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `FormatoSaldos`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ((0)) FOR `FactorRedondeoPrecios`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `DefaultImpuesto1`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `DefaultImpuesto2`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ((0)) FOR `PrecioIncluyeImpuesto1`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ((0)) FOR `PrecioIncluyeImpuesto2`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `CodigoClienteMostrador`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ((0)) FOR `MesInicioAnho`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ((0)) FOR `AnhoActual`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ((0)) FOR `PeriodoActual`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `FormatoCodigos`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `CuentaGanPer`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `Separador`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ((0)) FOR `AcreditarComision`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ((0)) FOR `PComisVenta1`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ((0)) FOR `PComisVenta2`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ((0)) FOR `PComisVenta3`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ((0)) FOR `PComisCobranza1`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ((0)) FOR `PComisCobranza2`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ((0)) FOR `PComisCobranza3`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ((0)) FOR `indexarPrecios`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ((0)) FOR `valoracionInventario`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `TituloPrecio1`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `TituloPrecio2`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `TituloPrecio3`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `TituloPrecio4`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `NombreImpuesto1`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `NombreImpuesto2`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `CuentaGeneralVentas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `CuentaGeneralInventario`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `CuentaGeneralDeudas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `CuentaGeneralAcreencias`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `CuentaGeneralBancos`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `CuentaGeneralCosto`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `CuentaGeneralDevoluciones`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `CuentaPasivoComisiones`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `CuentaGastosComisiones`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `CuentaImpuesto1`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `CuentaImpuesto2`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `CuentaCaja`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ((0)) FOR `ProximaMaquina`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('20000101') FOR `InicioVigenciaIDB`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('20000101') FOR `FinVigenciaIDB`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ((0)) FOR `PorcentajeIDB`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `CuentaGastosIDB`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `CuentaISLRAnticipado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `CuentaEgresosComisionTC`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ((0)) FOR `TipoInventarioEnCurso`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `AlmacenInventarioFisico`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `CuentaDescuentosCobranza`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `CuentaDescuentosPagos`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `CuentaMercanciaDanhada`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `CuentaISLRRetenido`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `Ciudad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `CuentaServicio`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ((0)) FOR `ClaveActivacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ((1)) FOR `TipoCambio`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `CuentaMercanciaTransito`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ((0)) FOR `Contribuyente`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ((0)) FOR `PorcentajeRetencionIVACE`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ((0)) FOR `ValorActualUT`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `CuentaDiferencias`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `CuentaDeudoraConsignaciones`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `CuentaAcreedoraConsignaciones`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `CuentaIVACompras`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `CuentaRetIVACompras`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `CuentaRetIVAVentas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ((0)) FOR `ClaveActivacionV7`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ((0)) FOR `ClaveActivacionV8`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ((8005)) FOR `Version`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `cuentaResultadosAEF`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('RIF') FOR `nombreRIF`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `cuentaGastosTransferencia`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `cuentaAjustesCambiarios`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ((1)) FOR `TipoCambio2`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ((0)) FOR `claveActivacionV9`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('linea') FOR `clasificador1`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('grupo') FOR `clasificador2`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('marca') FOR `clasificador3`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ((0)) FOR `generoClasif1`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ((1)) FOR `generoClasif2`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ((0)) FOR `generoClasif3`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('$ #,##0.00') FOR `FormatoMEX`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ((0)) FOR `ControlarPiezas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ((0)) FOR `PorcentajeIGTF456`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ((0)) FOR `claveActivacionV10`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `cuentaIGTFRetenido`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ('') FOR `cuentaIGTFPagado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ParametrosEmpresa` ADD  DEFAULT ((0)) FOR `idEmpresa`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `perfilesPrecios` ADD  DEFAULT ((0)) FOR `isStrict`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Prefijos` ADD  DEFAULT ((0)) FOR `Uso`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Proveedores` ADD  DEFAULT ('') FOR `Nombre`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Proveedores` ADD  DEFAULT ('') FOR `RIF`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Proveedores` ADD  DEFAULT ('') FOR `CGCuenta`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Proveedores` ADD  DEFAULT ('') FOR `Condiciones`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Proveedores` ADD  DEFAULT ('') FOR `Direccion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Proveedores` ADD  DEFAULT ('') FOR `Telefono`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Proveedores` ADD  DEFAULT ((0)) FOR `SaldoActual`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Proveedores` ADD  DEFAULT ((0)) FOR `LimiteCredito`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Proveedores` ADD  DEFAULT ('19000101') FOR `FechaUltimaCompra`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Proveedores` ADD  DEFAULT ('') FOR `Notas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Proveedores` ADD  DEFAULT (now(3)) FOR `FechaCreacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Proveedores` ADD  DEFAULT ((0)) FOR `Importacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Proveedores` ADD  DEFAULT ((1)) FOR `TipoRetencion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Proveedores` ADD  DEFAULT ((2)) FOR `TipoPersona`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Proveedores` ADD  DEFAULT ((1)) FOR `tipoCambio`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Proveedores` ADD  DEFAULT ((0)) FOR `TiempoEntrega`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Proveedores` ADD  DEFAULT ((0)) FOR `contribuyenteEspecial`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ProveedorProducto` ADD  DEFAULT ('') FOR `CodigoProveedor`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ProveedorProducto` ADD  DEFAULT ('') FOR `CodigoItem`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ProveedorProducto` ADD  DEFAULT ('') FOR `RefProductoProveedor`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ProveedorProducto` ADD  DEFAULT ((0)) FOR `PrecioReferencia`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ProveedorProducto` ADD  DEFAULT (now(3)) FOR `FechaOferta`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ProveedorProducto` ADD  DEFAULT ((0)) FOR `PrecioUltimaCompra`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ProveedorProducto` ADD  DEFAULT (now(3)) FOR `FechaUltimaCompra`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `ProveedorProducto` ADD  DEFAULT ('') FOR `Notas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RelacionesIVARetenido` ADD  DEFAULT ((0)) FOR `Reporte`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `renglonesComanda` ADD  DEFAULT ('') FOR `codigoItem`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `renglonesComanda` ADD  DEFAULT ((0)) FOR `porcentajeIVA`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `renglonesComanda` ADD  DEFAULT ((0)) FOR `precio`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `renglonesComanda` ADD  DEFAULT ((0)) FOR `cantidad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `renglonesComanda` ADD  DEFAULT ('') FOR `descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `renglonesComanda` ADD  DEFAULT ('') FOR `usuario`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RenglonesConsumoSesion` ADD  DEFAULT ((0)) FOR `OwnerID`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RenglonesConsumoSesion` ADD  DEFAULT ((0)) FOR `Renglon`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RenglonesConsumoSesion` ADD  DEFAULT ('') FOR `Descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RenglonesCuentaPOS` ADD  DEFAULT ((0)) FOR `IDCuenta`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RenglonesCuentaPOS` ADD  DEFAULT ('') FOR `CodigoItem`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RenglonesCuentaPOS` ADD  DEFAULT ((0)) FOR `PrecioUnitario`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RenglonesCuentaPOS` ADD  DEFAULT ((0)) FOR `Cantidad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RenglonesCuentaPOS` ADD  DEFAULT ((0)) FOR `NumeroRenglon`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RenglonesCuentaPOS` ADD  DEFAULT ('') FOR `Usuario`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RenglonesCuentaPOS` ADD  DEFAULT ((0)) FOR `Precio`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RenglonesCuentaPOS` ADD  DEFAULT ((0)) FOR `idCombo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RenglonesFacturaPOS` ADD  DEFAULT ((0)) FOR `idMaquina`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RenglonesFacturaPOS` ADD  DEFAULT ((0)) FOR `numeroTicket`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RenglonesFacturaPOS` ADD  DEFAULT ((0)) FOR `numeroLinea`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RenglonesFacturaPOS` ADD  DEFAULT ('') FOR `Producto`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RenglonesFacturaPOS` ADD  DEFAULT ((0)) FOR `Cantidad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RenglonesFacturaPOS` ADD  DEFAULT ((0)) FOR `PrecioUnitario`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RenglonesFacturaPOS` ADD  DEFAULT ((0)) FOR `PorcentajeImpuesto`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RenglonesFacturaPOS` ADD  DEFAULT ('') FOR `Usuario`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RenglonesFacturaPOS` ADD  DEFAULT ((0)) FOR `NumeroFactura`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RenglonesFacturaPOS` ADD  DEFAULT ((0)) FOR `idCombo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RenglonesSesion` ADD  DEFAULT ((0)) FOR `SessionID`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RenglonesSesion` ADD  DEFAULT ((0)) FOR `NumeroRenglon`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RenglonesSesion` ADD  DEFAULT ('') FOR `CodigoItem`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RenglonesSesion` ADD  DEFAULT ((0)) FOR `PrecioUnitario`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RenglonesSesion` ADD  DEFAULT ((0)) FOR `Cantidad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RenglonesSesion` ADD  DEFAULT ((0)) FOR `PorcentajeImpuesto`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RenglonesSesion` ADD  DEFAULT ('') FOR `TipoImpuesto`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RenglonesSesion` ADD  DEFAULT ((0)) FOR `PrecioLista`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RenglonesSesion` ADD  DEFAULT ('') FOR `Usuario`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RenglonesSesion` ADD  DEFAULT ((0)) FOR `idCombo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RenglonesSesion` ADD  DEFAULT ((0)) FOR `precioOriginal`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RenglonesTransferencia` ADD  DEFAULT ((0)) FOR `NumeroTransferencia`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RenglonesTransferencia` ADD  DEFAULT ((0)) FOR `Renglon`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RenglonesTransferencia` ADD  DEFAULT ('') FOR `CodigoProducto`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RenglonesTransferencia` ADD  DEFAULT ((0)) FOR `Cantidad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RenglonesTransferencia` ADD  DEFAULT ((0)) FOR `CostoUnitario`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RenglonesTransferencia` ADD  DEFAULT ((0)) FOR `piezas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RetencionesISLR` ADD  DEFAULT ('') FOR `codigoEntidad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RetencionesISLR` ADD  DEFAULT (now(3)) FOR `fecha`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RetencionesISLR` ADD  DEFAULT ('') FOR `refDocumento`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RetencionesISLR` ADD  DEFAULT ((0)) FOR `totalPagado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RetencionesISLR` ADD  DEFAULT ((0)) FOR `baseImponible`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RetencionesISLR` ADD  DEFAULT ((0)) FOR `porcentajeRetencion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RetencionesISLR` ADD  DEFAULT ((0)) FOR `montoRetenido`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RetencionesISLR` ADD  DEFAULT ((0)) FOR `numRef`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RetencionesISLR` ADD  DEFAULT ('') FOR `TipoDoc`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RetencionesISLR` ADD  DEFAULT ((0)) FOR `NumDoc`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RetencionesISLR` ADD  DEFAULT ('') FOR `RIFSujeto`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RetencionesISLR` ADD  DEFAULT ('') FOR `NombreSujeto`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RetencionesISLR` ADD  DEFAULT ('') FOR `DireccionSujeto`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RetencionesISLR` ADD  DEFAULT ((0)) FOR `ConceptoRetencion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RetencionesISLR` ADD  DEFAULT ((0)) FOR `TipoPersona`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RetencionesIVA` ADD  DEFAULT ('') FOR `CodigoCliente`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RetencionesIVA` ADD  DEFAULT ((0)) FOR `NumFactura`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RetencionesIVA` ADD  DEFAULT (now(3)) FOR `FechaCobro`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RetencionesIVA` ADD  DEFAULT ((0)) FOR `MontoRetencion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RetencionesIVA` ADD  DEFAULT ((0)) FOR `NumeroComprobante`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RetencionesIVA` ADD  DEFAULT ((0)) FOR `RefReporte`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RetencionesIVA` ADD  DEFAULT ('FCT') FOR `tipoDoc`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RetencionesIVA` ADD  DEFAULT (now(3)) FOR `Fecha`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RetencionesIVA` ADD  DEFAULT ('FCT') FOR `TipoDocFiscal`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RetencionesIVA` ADD  DEFAULT ('') FOR `Referencia`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RetencionesIVA` ADD  DEFAULT ('') FOR `NumeroControlInicial`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RetencionesIVA` ADD  DEFAULT ((0)) FOR `Exento`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RetencionesIVA` ADD  DEFAULT ((0)) FOR `Gravable1`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RetencionesIVA` ADD  DEFAULT ((0)) FOR `Gravable2`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RetencionesIVA` ADD  DEFAULT ((0)) FOR `Impuesto1`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RetencionesIVA` ADD  DEFAULT ((0)) FOR `Impuesto2`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RetencionesIVA` ADD  DEFAULT ('') FOR `RifEntidad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RetencionesIVA` ADD  DEFAULT ('') FOR `NombreEntidad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RetirosPOS` ADD  DEFAULT ((0)) FOR `idSesion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RetirosPOS` ADD  DEFAULT (now(3)) FOR `Hora`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RetirosPOS` ADD  DEFAULT ((0)) FOR `Tipo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RetirosPOS` ADD  DEFAULT ('') FOR `Descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `RetirosPOS` ADD  DEFAULT ((0)) FOR `Monto`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `rislrMetodos` ADD  DEFAULT ((0)) FOR `Codigo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `saldoEfectivoSesion` ADD  DEFAULT ((0)) FOR `idSesion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SaldosEntidadPeriodo` ADD  DEFAULT ('') FOR `TipoEntidad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SaldosEntidadPeriodo` ADD  DEFAULT ('') FOR `CodigoEntidad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SaldosEntidadPeriodo` ADD  DEFAULT ((0)) FOR `NumeroPeriodo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SaldosEntidadPeriodo` ADD  DEFAULT ((0)) FOR `SaldoInicial`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SaldosEntidadPeriodo` ADD  DEFAULT ((0)) FOR `Debitos`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SaldosEntidadPeriodo` ADD  DEFAULT ((0)) FOR `Creditos`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SaldosPeriodo` ADD  DEFAULT ('') FOR `CodigoCuenta`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SaldosPeriodo` ADD  DEFAULT ((0)) FOR `NumeroPeriodo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SaldosPeriodo` ADD  DEFAULT ((0)) FOR `SaldoInicial`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SaldosPeriodo` ADD  DEFAULT ((0)) FOR `Debitos`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SaldosPeriodo` ADD  DEFAULT ((0)) FOR `Creditos`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Seriales` ADD  DEFAULT ('') FOR `CodigoItem`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Seriales` ADD  DEFAULT ('') FOR `Serial`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Seriales` ADD  DEFAULT ((0)) FOR `EnStock`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Seriales` ADD  DEFAULT ((0)) FOR `Locked`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SerialesDetalles` ADD  DEFAULT ((0)) FOR `NumeroDetalle`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SerialesDetalles` ADD  DEFAULT ('') FOR `CodigoItem`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SerialesDetalles` ADD  DEFAULT ('') FOR `Serial`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SerialesDetalles` ADD  DEFAULT ('') FOR `TipoDocumento`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SerialesDetalles` ADD  DEFAULT ((0)) FOR `NumeroDocumento`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SerialesDetalles` ADD  DEFAULT ((0)) FOR `Renglon`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SerialesDetalles` ADD  DEFAULT ((0)) FOR `Tipo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SerialesDetalles` ADD  DEFAULT (now(3)) FOR `FechaTransaccion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SerialesDetalles` ADD  DEFAULT ((0)) FOR `isTemporal`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SerialesDetalles` ADD  DEFAULT ((0)) FOR `prevStatus`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Series` ADD  DEFAULT ('') FOR `CodigoSerie`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Series` ADD  DEFAULT ('') FOR `Descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Series` ADD  DEFAULT ('') FOR `CuentaIngreso`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Series` ADD  DEFAULT ((0)) FOR `ProximaFactura`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Series` ADD  DEFAULT ((1)) FOR `ProximaNota`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Series` ADD  DEFAULT ('') FOR `CuentaImpuesto1`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Series` ADD  DEFAULT ('') FOR `CuentaImpuesto2`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Series` ADD  DEFAULT ('') FOR `CuentaCosto`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Series` ADD  DEFAULT ((0)) FOR `Nivel`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `MachineID`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `Cerrada`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ('') FOR `usrID`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT (now(3)) FOR `Fecha`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT (now(3)) FOR `StartTime`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `ComprobanteAlmacen`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `CurrentAccount`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `CurrentAmount`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `FacturasRealizadas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `MontoFacturado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `ImpuestoCobrado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `EfectivoEnCaja`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `TTCVisa`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `TTCMaster`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `TTCOtras`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `TDebito`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `ChequesEnCaja`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `Anulaciones`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `MontoAnulaciones`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `ImpuestoAnulado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `Retiros`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `MontoRetirado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `CobrosRealizados`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `MontoCobrado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `ServicioCobrado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `ServicioAnulado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `VentasACredito`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `MontoEnCaja`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `TTCAmex`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `OtrosMedios`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `Propinas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `PrimeraFactura`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `UltimaFactura`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `primeraNC`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `ultimaNC`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `montoNC`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `impuestoNC`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `adelantosEfectivo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `ingresoAdelantos`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `efectivoAdelantado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `EfectivoMonedaExtranjera`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `MontoNominalMonedaExtranjera`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `NotasAcreditadas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `NCEmitidas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesCerradas` ADD  DEFAULT ((0)) FOR `IGTFRetenido`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `MachineID`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `Cerrada`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ('') FOR `usrID`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT (now(3)) FOR `Fecha`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT (now(3)) FOR `StartTime`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `ComprobanteAlmacen`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `CurrentAccount`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `CurrentAmount`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `FacturasRealizadas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `MontoFacturado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `ImpuestoCobrado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `EfectivoEnCaja`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `TTCVisa`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `TTCMaster`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `TTCOtras`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `TDebito`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `ChequesEnCaja`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `Anulaciones`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `MontoAnulaciones`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `ImpuestoAnulado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `Retiros`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `MontoRetirado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `CobrosRealizados`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `MontoCobrado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `ServicioCobrado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `ServicioAnulado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `VentasACredito`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `MontoEnCaja`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `TTCAmex`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `OtrosMedios`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `Propinas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `PrimeraFactura`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `UltimaFactura`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `primeraNC`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `ultimaNC`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `montoNC`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `impuestoNC`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `adelantosEfectivo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `ingresoAdelantos`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `efectivoAdelantado`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `EfectivoMonedaExtranjera`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `MontoNominalMonedaExtranjera`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `NotasAcreditadas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `NCEmitidas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesPOS` ADD  DEFAULT ((0)) FOR `IGTFRetenido`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SesionesRemotas` ADD  DEFAULT ('') FOR `Almacen`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `solicitudesAutorizacion` ADD  DEFAULT ('') FOR `autorizadaPor`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `solicitudesAutorizacion` ADD  DEFAULT (now(3)) FOR `hora`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `SubLineas` ADD  DEFAULT ('') FOR `Descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `TarjetasCredito` ADD  DEFAULT ('') FOR `Nombre`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `TarjetasCredito` ADD  DEFAULT ('') FOR `Banco`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `TarjetasCredito` ADD  DEFAULT ((0)) FOR `PorcentajeComision`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `TarjetasCredito` ADD  DEFAULT ((0)) FOR `PorcentajeISLR`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `TarjetasCredito` ADD  DEFAULT ('') FOR `CuentaComision`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `TarjetasCredito` ADD  DEFAULT ('') FOR `CuentaISLR`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `TempAjustes` ADD  DEFAULT (now(3)) FOR `Fecha`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `TempAjustes` ADD  DEFAULT ('') FOR `refAjuste`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `TempAjustes` ADD  DEFAULT ((0)) FOR `Tipo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `TempAjustes` ADD  DEFAULT ('') FOR `Descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `TempAjustes` ADD  DEFAULT ('') FOR `Notas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `TempAjustes` ADD  DEFAULT ('') FOR `Contrapartida`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `TempAjustes` ADD  DEFAULT ('') FOR `Almacen`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `TiposCliente` ADD  DEFAULT ('') FOR `Descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `TiposCuentaPOS` ADD  DEFAULT ('') FOR `Prefijo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `TiposCuentaPOS` ADD  DEFAULT ((0)) FOR `Base`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `TiposCuentaPOS` ADD  DEFAULT ((0)) FOR `Porcentaje`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `TiposCuentaPOS` ADD  DEFAULT ((0)) FOR `IndicePrecio`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `TiposImpuesto` ADD  DEFAULT ('') FOR `Descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `TiposImpuesto` ADD  DEFAULT ((0)) FOR `Porcentaje`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `TiposImpuesto` ADD  DEFAULT ('19000101') FOR `VigenteDesde`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `TiposImpuesto` ADD  DEFAULT ('18991231') FOR `VigenteHasta`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `TiposImpuesto` ADD  DEFAULT ('') FOR `Cuenta`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `tmpTransferencias` ADD  DEFAULT ('') FOR `Descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `tmpTransferencias` ADD  DEFAULT ('') FOR `Notas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `tmpTransferencias` ADD  DEFAULT (now(3)) FOR `FechaRegistro`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `tmpTransferencias` ADD  DEFAULT ('') FOR `Operador`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `tmpTransferencias` ADD  DEFAULT ('') FOR `AlmacenOrigen`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `tmpTransferencias` ADD  DEFAULT ('') FOR `AlmacenDestino`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `tmpTransferencias` ADD  DEFAULT ('') FOR `extRef`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `tmpTransferencias` ADD  DEFAULT ('') FOR `Clasificacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `tmpTransferenciasDetalles` ADD  DEFAULT ((0)) FOR `transID`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `tmpTransferenciasDetalles` ADD  DEFAULT ('') FOR `CodigoItem`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `tmpTransferenciasDetalles` ADD  DEFAULT ((0)) FOR `Cantidad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `tmpTransferenciasDetalles` ADD  DEFAULT ((0)) FOR `piezas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `transaccionEfectivoDetalles` ADD  DEFAULT ((0)) FOR `transId`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `transaccionEfectivoDetalles` ADD  DEFAULT ('') FOR `codigoMedio`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `transaccionEfectivoDetalles` ADD  DEFAULT ((0)) FOR `valorMN`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `transaccionEfectivoDetalles` ADD  DEFAULT ((0)) FOR `valorNominal`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Transferencias` ADD  DEFAULT (now(3)) FOR `FechaRegistro`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Transferencias` ADD  DEFAULT (now(3)) FOR `FechaTransferencia`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Transferencias` ADD  DEFAULT ('') FOR `Operador`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Transferencias` ADD  DEFAULT ('') FOR `AlmacenOrigen`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Transferencias` ADD  DEFAULT ('') FOR `AlmacenDestino`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Transferencias` ADD  DEFAULT ('') FOR `Descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Transferencias` ADD  DEFAULT ('') FOR `Notas`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Transferencias` ADD  DEFAULT ('') FOR `extRef`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Transferencias` ADD  DEFAULT ('') FOR `Clasificacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `transferenciasCajas` ADD  DEFAULT (now(3)) FOR `fecha`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Unidades` ADD  DEFAULT ('') FOR `Codigo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Unidades` ADD  DEFAULT ('') FOR `Unidad`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Unidades` ADD  DEFAULT ('') FOR `Equivalencia`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Unidades` ADD  DEFAULT ((0)) FOR `Factor`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Usuarios` ADD  DEFAULT ((0)) FOR `Clave`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Usuarios` ADD  DEFAULT ((0)) FOR `Nivel`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Usuarios` ADD  DEFAULT ('') FOR `Nombre`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Usuarios` ADD  DEFAULT ('') FOR `Perfil`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Usuarios` ADD  DEFAULT ('') FOR `uniqid`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Usuarios` ADD  DEFAULT ('Default') FOR `tema`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `VencimientosISPC` ADD  DEFAULT ((0)) FOR `NumeroDocumento`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `VencimientosISPC` ADD  DEFAULT (now(3)) FOR `FechaVencimiento`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `VencimientosISPC` ADD  DEFAULT ((0)) FOR `Monto`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Vendedores` ADD  DEFAULT ('') FOR `Nombre`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Vendedores` ADD  DEFAULT ('') FOR `CI`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Vendedores` ADD  DEFAULT ('') FOR `Direccion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Vendedores` ADD  DEFAULT ('') FOR `Telefono`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Vendedores` ADD  DEFAULT ((0)) FOR `NoCobraComision`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Vendedores` ADD  DEFAULT ((0)) FOR `TipoComisionVenta`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Vendedores` ADD  DEFAULT ((0)) FOR `TipoComisionCobranza`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Vendedores` ADD  DEFAULT ((0)) FOR `SaldoActual`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Vendedores` ADD  DEFAULT ('') FOR `CuentaPasivo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Vendedores` ADD  DEFAULT (now(3)) FOR `FechaCreacion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Zonas` ADD  DEFAULT ('') FOR `Codigo`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Zonas` ADD  DEFAULT ('') FOR `Descripcion`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Zonas` ADD  DEFAULT ((0)) FOR `latitud`
GO */
/* Moved to CREATE TABLE
ALTER TABLE `Zonas` ADD  DEFAULT ((0)) FOR `longitud`
GO */
ALTER TABLE `AcumuladoresTipoIVAZ` ADD  CONSTRAINT `FK_AcumuladoresTipoIVAZ_CierresZ` FOREIGN KEY(`numeroZ`)
REFERENCES `CierresZ` (`NumeroUnico`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `AcumuladoresTipoIVAZ` CHECK CONSTRAINT `FK_AcumuladoresTipoIVAZ_CierresZ`; */
 
ALTER TABLE `AlternosItemVenta` ADD  CONSTRAINT `FK_AlternosItemVenta_ItemsVenta` FOREIGN KEY(`CodigoItemVenta`)
REFERENCES `ItemsVenta` (`Codigo`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `AlternosItemVenta` CHECK CONSTRAINT `FK_AlternosItemVenta_ItemsVenta`; */
 
ALTER TABLE `BarraItemsPagina` ADD  CONSTRAINT `FK_BarraItemsPagina_BarraPaginas` FOREIGN KEY(`Pagina`)
REFERENCES `BarraPaginas` (`Numero`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `BarraItemsPagina` CHECK CONSTRAINT `FK_BarraItemsPagina_BarraPaginas`; */
 
ALTER TABLE `BarraItemsPagina` ADD  CONSTRAINT `FK_BarraItemsPagina_ItemsVenta` FOREIGN KEY(`Codigo`)
REFERENCES `ItemsVenta` (`Codigo`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `BarraItemsPagina` CHECK CONSTRAINT `FK_BarraItemsPagina_ItemsVenta`; */
 
ALTER TABLE `chequeDevueltoComis` ADD  CONSTRAINT `FK_chequeDevueltoComis_ChequesDevueltos` FOREIGN KEY(`idCheque`)
REFERENCES `ChequesDevueltos` (`id`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `chequeDevueltoComis` CHECK CONSTRAINT `FK_chequeDevueltoComis_ChequesDevueltos`; */
 
ALTER TABLE `chequeDevueltoComis` ADD  CONSTRAINT `FK_chequeDevueltoComis_Vendedores` FOREIGN KEY(`codigoVendedor`)
REFERENCES `Vendedores` (`Codigo`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `chequeDevueltoComis` CHECK CONSTRAINT `FK_chequeDevueltoComis_Vendedores`; */
 
ALTER TABLE `CobrosPostdatados` ADD  CONSTRAINT `FK_CobrosPostdatados_Clientes` FOREIGN KEY(`CodigoCliente`)
REFERENCES `Clientes` (`Codigo`)
ON UPDATE CASCADE;
 
/* ALTER TABLE `CobrosPostdatados` CHECK CONSTRAINT `FK_CobrosPostdatados_Clientes`; */
 
ALTER TABLE `CobrosPostdatados` ADD  CONSTRAINT `FK_CobrosPostdatados_Vendedores` FOREIGN KEY(`CodigoVendedor`)
REFERENCES `Vendedores` (`Codigo`)
ON UPDATE CASCADE;
 
/* ALTER TABLE `CobrosPostdatados` CHECK CONSTRAINT `FK_CobrosPostdatados_Vendedores`; */
 
ALTER TABLE `CobrosPostdatadosDetalles` ADD  CONSTRAINT `FK_CobrosPostdatadosDetalles_CobrosPostdatados` FOREIGN KEY(`idCobro`)
REFERENCES `CobrosPostdatados` (`Numero`)
ON DELETE CASCADE;
 
/* ALTER TABLE `CobrosPostdatadosDetalles` CHECK CONSTRAINT `FK_CobrosPostdatadosDetalles_CobrosPostdatados`; */
 
ALTER TABLE `CobrosPostdatadosMedios` ADD  CONSTRAINT `FK_CobrosPostdatadosMedios_CobrosPostdatados` FOREIGN KEY(`idCobro`)
REFERENCES `CobrosPostdatados` (`Numero`)
ON DELETE CASCADE;
 
/* ALTER TABLE `CobrosPostdatadosMedios` CHECK CONSTRAINT `FK_CobrosPostdatadosMedios_CobrosPostdatados`; */
 
ALTER TABLE `ComposicionItemsVenta` ADD  CONSTRAINT `FK_ComposicionItemsVenta_itemsInventario` FOREIGN KEY(`CodigoItemInventario`)
REFERENCES `itemsInventario` (`Codigo`)
ON UPDATE CASCADE;
 
/* ALTER TABLE `ComposicionItemsVenta` CHECK CONSTRAINT `FK_ComposicionItemsVenta_itemsInventario`; */
 
ALTER TABLE `ComposicionItemsVenta` ADD  CONSTRAINT `FK_ComposicionItemsVenta_ItemsVenta` FOREIGN KEY(`CodigoItemVenta`)
REFERENCES `ItemsVenta` (`Codigo`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `ComposicionItemsVenta` CHECK CONSTRAINT `FK_ComposicionItemsVenta_ItemsVenta`; */
 
ALTER TABLE `Compras` ADD  CONSTRAINT `FK_Compras_Proveedores` FOREIGN KEY(`CodigoProveedor`)
REFERENCES `Proveedores` (`Codigo`)
ON UPDATE CASCADE;
 
/* ALTER TABLE `Compras` CHECK CONSTRAINT `FK_Compras_Proveedores`; */
 
ALTER TABLE `ComprobantesAlmacen` ADD  CONSTRAINT `FK_ComprobantesAlmacen_Almacenes` FOREIGN KEY(`Almacen`)
REFERENCES `Almacenes` (`Codigo`)
ON UPDATE CASCADE;
 
/* ALTER TABLE `ComprobantesAlmacen` CHECK CONSTRAINT `FK_ComprobantesAlmacen_Almacenes`; */
 
ALTER TABLE `Conciliaciones` ADD  CONSTRAINT `FK_Conciliaciones_Bancos` FOREIGN KEY(`CodigoBanco`)
REFERENCES `Bancos` (`Codigo`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `Conciliaciones` CHECK CONSTRAINT `FK_Conciliaciones_Bancos`; */
 
ALTER TABLE `ConsignacionesDetalles` ADD  CONSTRAINT `FK_ConsignacionesDetalles_ConsignacionesCompra` FOREIGN KEY(`NumeroConsignacion`)
REFERENCES `ConsignacionesCompra` (`Numero`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `ConsignacionesDetalles` CHECK CONSTRAINT `FK_ConsignacionesDetalles_ConsignacionesCompra`; */
 
ALTER TABLE `Cotizaciones` ADD  CONSTRAINT `FK_Cotizaciones_Clientes` FOREIGN KEY(`CodigoCliente`)
REFERENCES `Clientes` (`Codigo`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `Cotizaciones` CHECK CONSTRAINT `FK_Cotizaciones_Clientes`; */
 
ALTER TABLE `CotizacionesDetalles` ADD  CONSTRAINT `FK_CotizacionesDetalles_Cotizaciones` FOREIGN KEY(`NumeroDocumento`)
REFERENCES `Cotizaciones` (`Numero`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `CotizacionesDetalles` CHECK CONSTRAINT `FK_CotizacionesDetalles_Cotizaciones`; */
 
ALTER TABLE `cvCaja` ADD  CONSTRAINT `FK_cvCaja_CorrelativosMaquina` FOREIGN KEY(`machineID`)
REFERENCES `CorrelativosMaquina` (`Maquina`);
 
/* ALTER TABLE `cvCaja` CHECK CONSTRAINT `FK_cvCaja_CorrelativosMaquina`; */
 
ALTER TABLE `CVcajaDetalles` ADD  CONSTRAINT `FK_detallesCVcaja_ControlValoresCaja` FOREIGN KEY(`idCEC`)
REFERENCES `cvCaja` (`id`);
 
/* ALTER TABLE `CVcajaDetalles` CHECK CONSTRAINT `FK_detallesCVcaja_ControlValoresCaja`; */
 
ALTER TABLE `descripcionRCP` ADD  CONSTRAINT `FK_descripcionRCP_RenglonesCuentaPOS` FOREIGN KEY(`idRenglon`)
REFERENCES `RenglonesCuentaPOS` (`id`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `descripcionRCP` CHECK CONSTRAINT `FK_descripcionRCP_RenglonesCuentaPOS`; */
 
ALTER TABLE `descripcionRFP` ADD  CONSTRAINT `FK_descripcionRFP_RenglonesFacturaPOS` FOREIGN KEY(`idMaquina`, `numeroTicket`, `numeroLinea`)
REFERENCES `RenglonesFacturaPOS` (`idMaquina`, `numeroTicket`, `numeroLinea`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `descripcionRFP` CHECK CONSTRAINT `FK_descripcionRFP_RenglonesFacturaPOS`; */
 
ALTER TABLE `descripcionRS` ADD  CONSTRAINT `FK_descripcionRS_RenglonesSesion` FOREIGN KEY(`SessionID`, `NumeroRenglon`)
REFERENCES `RenglonesSesion` (`SessionID`, `NumeroRenglon`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `descripcionRS` CHECK CONSTRAINT `FK_descripcionRS_RenglonesSesion`; */
 
ALTER TABLE `DescuentosSesion` ADD  CONSTRAINT `FK_DescuentosSesion_Motivo` FOREIGN KEY(`codigoMotivo`)
REFERENCES `MotivosDescuento` (`Codigo`)
ON UPDATE CASCADE;
 
/* ALTER TABLE `DescuentosSesion` CHECK CONSTRAINT `FK_DescuentosSesion_Motivo`; */
 
ALTER TABLE `Detalles` ADD  CONSTRAINT `FK_Detalles_Comprobantes` FOREIGN KEY(`NumeroComprobante`)
REFERENCES `Comprobantes` (`NumeroComprobante`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `Detalles` CHECK CONSTRAINT `FK_Detalles_Comprobantes`; */
 
ALTER TABLE `Detalles` ADD  CONSTRAINT `FK_Detalles_Cuentas` FOREIGN KEY(`Cuenta`)
REFERENCES `Cuentas` (`Codigo`)
ON UPDATE CASCADE;
 
/* ALTER TABLE `Detalles` CHECK CONSTRAINT `FK_Detalles_Cuentas`; */
 
ALTER TABLE `DetallesAnulacionPOS` ADD  CONSTRAINT `FK_DetallesAnulacionPOS_AnulacionesPOS` FOREIGN KEY(`numDevol`)
REFERENCES `AnulacionesPOS` (`ID`)
ON DELETE CASCADE;
 
/* ALTER TABLE `DetallesAnulacionPOS` CHECK CONSTRAINT `FK_DetallesAnulacionPOS_AnulacionesPOS`; */
 
ALTER TABLE `DetallesCobranza` ADD  CONSTRAINT `FK_DetallesCobranza_Cobranzas` FOREIGN KEY(`NumeroCobranza`)
REFERENCES `Cobranzas` (`id`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `DetallesCobranza` CHECK CONSTRAINT `FK_DetallesCobranza_Cobranzas`; */
 
ALTER TABLE `DetallesCompra` ADD  CONSTRAINT `FK_DetallesCompra_Compras` FOREIGN KEY(`NumeroDocumento`)
REFERENCES `Compras` (`Numero`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `DetallesCompra` CHECK CONSTRAINT `FK_DetallesCompra_Compras`; */
 
ALTER TABLE `DetallesDevolucionCompra` ADD  CONSTRAINT `FK_DetallesDevolucionCompra_DevolucionesCompra` FOREIGN KEY(`numeroDevolucion`)
REFERENCES `DevolucionesCompra` (`Numero`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `DetallesDevolucionCompra` CHECK CONSTRAINT `FK_DetallesDevolucionCompra_DevolucionesCompra`; */
 
ALTER TABLE `DetallesDevolucionVenta` ADD  CONSTRAINT `FK_DetallesDevolucionVenta_DevolucionesVenta` FOREIGN KEY(`NumeroDevolucion`)
REFERENCES `DevolucionesVenta` (`Numero`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `DetallesDevolucionVenta` CHECK CONSTRAINT `FK_DetallesDevolucionVenta_DevolucionesVenta`; */
 
ALTER TABLE `detallesDocFis` ADD  CONSTRAINT `FK_detallesDocFis_DocumentosFiscales` FOREIGN KEY(`docId`)
REFERENCES `DocumentosFiscales` (`Id`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `detallesDocFis` CHECK CONSTRAINT `FK_detallesDocFis_DocumentosFiscales`; */
 
ALTER TABLE `DetallesFactura` ADD  CONSTRAINT `FK_DetallesFactura_Facturas` FOREIGN KEY(`NumeroDocumento`)
REFERENCES `Facturas` (`Numero`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `DetallesFactura` CHECK CONSTRAINT `FK_DetallesFactura_Facturas`; */
 
ALTER TABLE `DetallesIngresoCaja` ADD  CONSTRAINT `FK_DetallesIngresoCaja_MovimientosCaja` FOREIGN KEY(`TransID`)
REFERENCES `MovimientosCaja` (`TransID`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `DetallesIngresoCaja` CHECK CONSTRAINT `FK_DetallesIngresoCaja_MovimientosCaja`; */
 
ALTER TABLE `DetallesItemVenta` ADD  CONSTRAINT `FK_DetallesItemVenta_ItemsVenta` FOREIGN KEY(`CodigoItem`)
REFERENCES `ItemsVenta` (`Codigo`)
ON UPDATE CASCADE;
 
/* ALTER TABLE `DetallesItemVenta` CHECK CONSTRAINT `FK_DetallesItemVenta_ItemsVenta`; */
 
ALTER TABLE `DetallesMINV` ADD  CONSTRAINT `FK_DetallesMINV_ComprobantesAlmacen` FOREIGN KEY(`NumeroDocumento`)
REFERENCES `ComprobantesAlmacen` (`Numero`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `DetallesMINV` CHECK CONSTRAINT `FK_DetallesMINV_ComprobantesAlmacen`; */
 
ALTER TABLE `DetallesMINV` ADD  CONSTRAINT `FK_DetallesMINV_itemsInventario` FOREIGN KEY(`CodigoItem`)
REFERENCES `itemsInventario` (`Codigo`)
ON UPDATE CASCADE;
 
/* ALTER TABLE `DetallesMINV` CHECK CONSTRAINT `FK_DetallesMINV_itemsInventario`; */
 
ALTER TABLE `detallesPerfilPrecio` ADD  CONSTRAINT `FK_detallesPerfilPrecio_perfilesPrecio` FOREIGN KEY(`codigoPerfil`)
REFERENCES `perfilesPrecios` (`codigoPerfil`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `detallesPerfilPrecio` CHECK CONSTRAINT `FK_detallesPerfilPrecio_perfilesPrecio`; */
 
ALTER TABLE `detallesSES` ADD  CONSTRAINT `FK_detallesSES_MediosPago` FOREIGN KEY(`codigoMedio`)
REFERENCES `MediosPago` (`Codigo`)
ON UPDATE CASCADE;
 
/* ALTER TABLE `detallesSES` CHECK CONSTRAINT `FK_detallesSES_MediosPago`; */
 
ALTER TABLE `detallesSES` ADD  CONSTRAINT `FK_detallesSES_saldoEfectivoSesion` FOREIGN KEY(`owner`)
REFERENCES `saldoEfectivoSesion` (`id`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `detallesSES` CHECK CONSTRAINT `FK_detallesSES_saldoEfectivoSesion`; */
 
ALTER TABLE `DevolucionesCompra` ADD  CONSTRAINT `FK_DevolucionesCompra_Proveedores` FOREIGN KEY(`CodigoProveedor`)
REFERENCES `Proveedores` (`Codigo`)
ON UPDATE CASCADE;
 
/* ALTER TABLE `DevolucionesCompra` CHECK CONSTRAINT `FK_DevolucionesCompra_Proveedores`; */
 
ALTER TABLE `DevolucionesVenta` ADD  CONSTRAINT `FK_DevolucionesVenta_Clientes` FOREIGN KEY(`CodigoCliente`)
REFERENCES `Clientes` (`Codigo`)
ON UPDATE CASCADE;
 
/* ALTER TABLE `DevolucionesVenta` CHECK CONSTRAINT `FK_DevolucionesVenta_Clientes`; */
 
ALTER TABLE `DiferidosBanco` ADD  CONSTRAINT `FK_DiferidosBanco_Bancos` FOREIGN KEY(`CodigoBanco`)
REFERENCES `Bancos` (`Codigo`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `DiferidosBanco` CHECK CONSTRAINT `FK_DiferidosBanco_Bancos`; */
 
ALTER TABLE `ExistenciaUbicacion` ADD  CONSTRAINT `FK_ExistenciaUbicacion_Almacenes` FOREIGN KEY(`Almacen`)
REFERENCES `Almacenes` (`Codigo`)
ON UPDATE CASCADE;
 
/* ALTER TABLE `ExistenciaUbicacion` CHECK CONSTRAINT `FK_ExistenciaUbicacion_Almacenes`; */
 
ALTER TABLE `ExistenciaUbicacion` ADD  CONSTRAINT `FK_ExistenciaUbicacion_itemsInventario` FOREIGN KEY(`CodigoItem`)
REFERENCES `itemsInventario` (`Codigo`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `ExistenciaUbicacion` CHECK CONSTRAINT `FK_ExistenciaUbicacion_itemsInventario`; */
 
ALTER TABLE `extDesc` ADD  CONSTRAINT `FK_ExtDesc_ItemsVenta` FOREIGN KEY(`codigoItem`)
REFERENCES `ItemsVenta` (`Codigo`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `extDesc` CHECK CONSTRAINT `FK_ExtDesc_ItemsVenta`; */
 
ALTER TABLE `Facturas` ADD  CONSTRAINT `FK_Facturas_Clientes` FOREIGN KEY(`CodigoCliente`)
REFERENCES `Clientes` (`Codigo`)
ON UPDATE CASCADE;
 
/* ALTER TABLE `Facturas` CHECK CONSTRAINT `FK_Facturas_Clientes`; */
 
ALTER TABLE `Facturas` ADD  CONSTRAINT `FK_Facturas_Vendedores` FOREIGN KEY(`CodigoVendedor`)
REFERENCES `Vendedores` (`Codigo`)
ON UPDATE CASCADE;
 
/* ALTER TABLE `Facturas` CHECK CONSTRAINT `FK_Facturas_Vendedores`; */
 
ALTER TABLE `IGTFFacturasPOS` ADD  CONSTRAINT `FK_FacturasPOS_IGTFFacturasPOS` FOREIGN KEY(`numeroFactura`)
REFERENCES `FacturasPOS` (`Numero`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `IGTFFacturasPOS` CHECK CONSTRAINT `FK_FacturasPOS_IGTFFacturasPOS`; */
 
ALTER TABLE `mensajesLeidos` ADD  CONSTRAINT `FK_mensajesLeidos_mensajesInternos` FOREIGN KEY(`id`)
REFERENCES `mensajesInternos` (`id`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `mensajesLeidos` CHECK CONSTRAINT `FK_mensajesLeidos_mensajesInternos`; */
 
ALTER TABLE `mensajesPendientes` ADD  CONSTRAINT `FK_mensajesPendientes_mensajesInternos` FOREIGN KEY(`id`)
REFERENCES `mensajesInternos` (`id`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `mensajesPendientes` CHECK CONSTRAINT `FK_mensajesPendientes_mensajesInternos`; */
 
ALTER TABLE `mensajesPendientes` ADD  CONSTRAINT `FK_mensajesPendientes_Usuarios` FOREIGN KEY(`destinatario`)
REFERENCES `Usuarios` (`Codigo`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `mensajesPendientes` CHECK CONSTRAINT `FK_mensajesPendientes_Usuarios`; */
 
ALTER TABLE `MovimientosBanco` ADD  CONSTRAINT `FK_MovimientosBanco_Bancos` FOREIGN KEY(`CodigoBanco`)
REFERENCES `Bancos` (`Codigo`)
ON UPDATE CASCADE;
 
/* ALTER TABLE `MovimientosBanco` CHECK CONSTRAINT `FK_MovimientosBanco_Bancos`; */
 
ALTER TABLE `NCPOSdetalles` ADD  CONSTRAINT `FK_NCPOSdetalles_NCPOSdetalles` FOREIGN KEY(`idNCPOS`)
REFERENCES `NCPOS` (`numero`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `NCPOSdetalles` CHECK CONSTRAINT `FK_NCPOSdetalles_NCPOSdetalles`; */
 
ALTER TABLE `NNEE` ADD  CONSTRAINT `FK_NNEE_Clientes` FOREIGN KEY(`CodigoCliente`)
REFERENCES `Clientes` (`Codigo`)
ON UPDATE CASCADE;
 
/* ALTER TABLE `NNEE` CHECK CONSTRAINT `FK_NNEE_Clientes`; */
 
ALTER TABLE `NNEEDetalles` ADD  CONSTRAINT `FK_NNEEDetalles_NNEE` FOREIGN KEY(`NumeroDocumento`)
REFERENCES `NNEE` (`Numero`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `NNEEDetalles` CHECK CONSTRAINT `FK_NNEEDetalles_NNEE`; */
 
ALTER TABLE `NNEEDetalleSuplemento` ADD  CONSTRAINT `FK_NNEEDetalleSuplemento_NNEESuplemento` FOREIGN KEY(`NumeroDocumento`)
REFERENCES `NNEESuplemento` (`Numero`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `NNEEDetalleSuplemento` CHECK CONSTRAINT `FK_NNEEDetalleSuplemento_NNEESuplemento`; */
 
ALTER TABLE `NNEEDevDetalles` ADD  CONSTRAINT `FK_NNEEDevDetalles_NNEEDevoluciones` FOREIGN KEY(`NumeroDevolucion`)
REFERENCES `NNEEDevoluciones` (`Numero`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `NNEEDevDetalles` CHECK CONSTRAINT `FK_NNEEDevDetalles_NNEEDevoluciones`; */
 
ALTER TABLE `NNEESuplemento` ADD  CONSTRAINT `FK_NNEESuplemento_NNEE` FOREIGN KEY(`NumeroNota`)
REFERENCES `NNEE` (`Numero`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `NNEESuplemento` CHECK CONSTRAINT `FK_NNEESuplemento_NNEE`; */
 
ALTER TABLE `nomAsigDedScript` ADD  CONSTRAINT `FK_nomAsigDedScript_nomDefAsigDed` FOREIGN KEY(`codigoAsigDed`)
REFERENCES `nomDefAsigDed` (`Codigo`)
ON UPDATE CASCADE;
 
/* ALTER TABLE `nomAsigDedScript` CHECK CONSTRAINT `FK_nomAsigDedScript_nomDefAsigDed`; */
 
ALTER TABLE `nomAsigDedScript` ADD  CONSTRAINT `FK_nomAsigDedScript_nomScripts` FOREIGN KEY(`CodigoScript`)
REFERENCES `nomScripts` (`Codigo`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `nomAsigDedScript` CHECK CONSTRAINT `FK_nomAsigDedScript_nomScripts`; */
 
ALTER TABLE `nomExcepcionesProceso` ADD  CONSTRAINT `FK_nomExcepcionesProceso_nomProcesos` FOREIGN KEY(`idProceso`)
REFERENCES `nomProcesos` (`Numero`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `nomExcepcionesProceso` CHECK CONSTRAINT `FK_nomExcepcionesProceso_nomProcesos`; */
 
ALTER TABLE `nomExcepcionesProceso` ADD  CONSTRAINT `FK_nomExcepcionesProceso_nomTrabajadores` FOREIGN KEY(`CodTrabajador`)
REFERENCES `nomTrabajadores` (`Codigo`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `nomExcepcionesProceso` CHECK CONSTRAINT `FK_nomExcepcionesProceso_nomTrabajadores`; */
 
ALTER TABLE `nomPagosPrestamo` ADD  CONSTRAINT `FK_nomPagosPrestamo_nomPrestamos` FOREIGN KEY(`idPrestamo`)
REFERENCES `nomPrestamos` (`numero`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `nomPagosPrestamo` CHECK CONSTRAINT `FK_nomPagosPrestamo_nomPrestamos`; */
 
ALTER TABLE `nomParametrosPrestamo` ADD  CONSTRAINT `FK_nomParametrosPrestamo_nomPrestamos` FOREIGN KEY(`idPrestamo`)
REFERENCES `nomPrestamos` (`numero`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `nomParametrosPrestamo` CHECK CONSTRAINT `FK_nomParametrosPrestamo_nomPrestamos`; */
 
ALTER TABLE `ocDetalles` ADD  CONSTRAINT `FK_ocDetalles` FOREIGN KEY(`NumeroDocumento`)
REFERENCES `ocOrdenes` (`Numero`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `ocDetalles` CHECK CONSTRAINT `FK_ocDetalles`; */
 
ALTER TABLE `PiezasMINV` ADD  CONSTRAINT `FK_PiezasMINV_DetallesMINV` FOREIGN KEY(`numComprobante`, `renglon`)
REFERENCES `DetallesMINV` (`NumeroDocumento`, `Renglon`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `PiezasMINV` CHECK CONSTRAINT `FK_PiezasMINV_DetallesMINV`; */
 
ALTER TABLE `ProveedorProducto` ADD  CONSTRAINT `FK_ProveedorProducto_itemsInventario` FOREIGN KEY(`CodigoItem`)
REFERENCES `itemsInventario` (`Codigo`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `ProveedorProducto` CHECK CONSTRAINT `FK_ProveedorProducto_itemsInventario`; */
 
ALTER TABLE `ProveedorProducto` ADD  CONSTRAINT `FK_ProveedorProducto_Proveedores` FOREIGN KEY(`CodigoProveedor`)
REFERENCES `Proveedores` (`Codigo`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `ProveedorProducto` CHECK CONSTRAINT `FK_ProveedorProducto_Proveedores`; */
 
ALTER TABLE `renglonesComanda` ADD  CONSTRAINT `FK_renglonesComanda_CuentasPOS` FOREIGN KEY(`cuenta`)
REFERENCES `CuentasPOS` (`IdCuenta`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `renglonesComanda` CHECK CONSTRAINT `FK_renglonesComanda_CuentasPOS`; */
 
ALTER TABLE `RenglonesCuentaPOS` ADD  CONSTRAINT `FK_RenglonesCuentaPOS_CuentasPOS` FOREIGN KEY(`IDCuenta`)
REFERENCES `CuentasPOS` (`IdCuenta`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `RenglonesCuentaPOS` CHECK CONSTRAINT `FK_RenglonesCuentaPOS_CuentasPOS`; */
 
ALTER TABLE `RenglonesFacturaPOS` ADD  CONSTRAINT `FK_FactPosRenglones` FOREIGN KEY(`NumeroFactura`)
REFERENCES `FacturasPOS` (`Numero`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `RenglonesFacturaPOS` CHECK CONSTRAINT `FK_FactPosRenglones`; */
 
ALTER TABLE `RenglonesTransferencia` ADD  CONSTRAINT `FK_RenglonesTransferencia_Transferencia` FOREIGN KEY(`NumeroTransferencia`)
REFERENCES `Transferencias` (`Numero`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `RenglonesTransferencia` CHECK CONSTRAINT `FK_RenglonesTransferencia_Transferencia`; */
 
ALTER TABLE `rislrMetodos` ADD  CONSTRAINT `FK_MetodoConcepto` FOREIGN KEY(`IdConcepto`)
REFERENCES `rislrConceptos` (`Id`)
ON DELETE CASCADE;
 
/* ALTER TABLE `rislrMetodos` CHECK CONSTRAINT `FK_MetodoConcepto`; */
 
ALTER TABLE `SaldosPeriodo` ADD  CONSTRAINT `FK_SaldosPeriodo_Cuentas` FOREIGN KEY(`CodigoCuenta`)
REFERENCES `Cuentas` (`Codigo`)
ON UPDATE CASCADE;
 
/* ALTER TABLE `SaldosPeriodo` CHECK CONSTRAINT `FK_SaldosPeriodo_Cuentas`; */
 
ALTER TABLE `saveDenominaciones` ADD  CONSTRAINT `FK_saveDenominaciones_saveDetallesCaja` FOREIGN KEY(`idDetalle`)
REFERENCES `saveDetallesCaja` (`id`)
ON DELETE CASCADE;
 
/* ALTER TABLE `saveDenominaciones` CHECK CONSTRAINT `FK_saveDenominaciones_saveDetallesCaja`; */
 
ALTER TABLE `saveDetallesCaja` ADD  CONSTRAINT `FK_saveDetallesCaja_saveMovCaja` FOREIGN KEY(`transID`)
REFERENCES `saveMovsCaja` (`id`)
ON DELETE CASCADE;
 
/* ALTER TABLE `saveDetallesCaja` CHECK CONSTRAINT `FK_saveDetallesCaja_saveMovCaja`; */
 
ALTER TABLE `serialesCuentaPOS` ADD  CONSTRAINT `FK_serialesCuentaPOS_CuentasPOS` FOREIGN KEY(`idCuenta`)
REFERENCES `CuentasPOS` (`IdCuenta`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `serialesCuentaPOS` CHECK CONSTRAINT `FK_serialesCuentaPOS_CuentasPOS`; */
 
ALTER TABLE `serialesCuentaPOS` ADD  CONSTRAINT `FK_serialesCuentaPOS_itemsInventario` FOREIGN KEY(`codigoArticulo`)
REFERENCES `itemsInventario` (`Codigo`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `serialesCuentaPOS` CHECK CONSTRAINT `FK_serialesCuentaPOS_itemsInventario`; */
 
ALTER TABLE `serialesSesion` ADD  CONSTRAINT `FK_serialesSesion_itemsInventario` FOREIGN KEY(`codigoArticulo`)
REFERENCES `itemsInventario` (`Codigo`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `serialesSesion` CHECK CONSTRAINT `FK_serialesSesion_itemsInventario`; */
 
ALTER TABLE `serialesSesion` ADD  CONSTRAINT `FK_serialesSesion_RenglonesSesion` FOREIGN KEY(`sesion`, `renglon`)
REFERENCES `RenglonesSesion` (`SessionID`, `NumeroRenglon`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `serialesSesion` CHECK CONSTRAINT `FK_serialesSesion_RenglonesSesion`; */
 
ALTER TABLE `subDocsMB` ADD  CONSTRAINT `FK_subDocsMB_MovimientosBanco` FOREIGN KEY(`TransID`)
REFERENCES `MovimientosBanco` (`Numero`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `subDocsMB` CHECK CONSTRAINT `FK_subDocsMB_MovimientosBanco`; */
 
ALTER TABLE `subDocsMC` ADD  CONSTRAINT `FK_subDocsMC_MovimientosCaja` FOREIGN KEY(`TransID`)
REFERENCES `MovimientosCaja` (`TransID`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `subDocsMC` CHECK CONSTRAINT `FK_subDocsMC_MovimientosCaja`; */
 
ALTER TABLE `tmpTransferenciasDetalles` ADD  CONSTRAINT `FK_tempTransDet_ItemsInv` FOREIGN KEY(`CodigoItem`)
REFERENCES `itemsInventario` (`Codigo`)
ON UPDATE CASCADE;
 
/* ALTER TABLE `tmpTransferenciasDetalles` CHECK CONSTRAINT `FK_tempTransDet_ItemsInv`; */
 
ALTER TABLE `tmpTransferenciasDetalles` ADD  CONSTRAINT `FK_tmpTransDet_tmpTrans` FOREIGN KEY(`transID`)
REFERENCES `tmpTransferencias` (`ID`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `tmpTransferenciasDetalles` CHECK CONSTRAINT `FK_tmpTransDet_tmpTrans`; */
 
ALTER TABLE `transaccionEfectivoDetalles` ADD  CONSTRAINT `FK_transaccionEfectivoDetalles_MediosPago` FOREIGN KEY(`codigoMedio`)
REFERENCES `MediosPago` (`Codigo`)
ON UPDATE CASCADE;
 
/* ALTER TABLE `transaccionEfectivoDetalles` CHECK CONSTRAINT `FK_transaccionEfectivoDetalles_MediosPago`; */
 
ALTER TABLE `transaccionEfectivoDetalles` ADD  CONSTRAINT `FK_transaccionEfectivoDetalles_TransaccionesEfectivo` FOREIGN KEY(`transId`)
REFERENCES `TransaccionesEfectivo` (`id`);
 
/* ALTER TABLE `transaccionEfectivoDetalles` CHECK CONSTRAINT `FK_transaccionEfectivoDetalles_TransaccionesEfectivo`; */
 
ALTER TABLE `VencimientosISPC` ADD  CONSTRAINT `FK_VencimientosISPC_DocumentosISPC` FOREIGN KEY(`NumeroDocumento`)
REFERENCES `DocumentosISPC` (`Numero`)
ON UPDATE CASCADE
ON DELETE CASCADE;
 
/* ALTER TABLE `VencimientosISPC` CHECK CONSTRAINT `FK_VencimientosISPC_DocumentosISPC`; */
 
/* SQLINES DEMO *** toredProcedure [dbo].[sp_addColumna]    Script Date: 28/3/2025 3:56:59 p. m. ******/
/* SET ANSI_NULLS ON */
 
/* SET QUOTED_IDENTIFIER ON */
 
DELIMITER //

CREATE Procedure `sp_addColumna`(p_tablename nvarchar(60), p_colname nvarchar(60), p_coltype nvarchar(60), p_defVal nvarchar(14), p_indexed tinyint unsigned, p_isUniqueNdx tinyint unsigned)
BEGIN
	DECLARE v_cmd NVARCHAR(512); DECLARE v_uniqueSpec NVARCHAR(8);
	if not exists(select * from information_schema.columns where table_Name = p_tablename AND column_name = p_colname)
	THEN
		SET v_cmd = CONCAT('ALTER TABLE ' , p_tablename , ' ADD ' , p_colname , ' ' , p_coltype , ' NOT NULL DEFAULT ' , p_defVal);
		Execute sp_ExecuteSQL v_cmd;
		IF p_indexed != 0 
		THEN
			IF p_isUniqueNdx = 0 THEN
				SET v_uniqueSpec = ' ';
			ELSE
				SET v_uniqueSpec = ' UNIQUE ';
			END IF;
				
			SET v_cmd = CONCAT('CREATE' , v_uniqueSpec , 'INDEX ndx_' , p_colname , ' ON ' , p_tablename , ' (' , p_colname , ')');
			Execute sp_ExecuteSQL v_cmd;
		END IF;
	END IF;
END;
//

DELIMITER ;


USE `master`;
 
/* ALTER DATABASE `SALTOANGEL` SET  READ_WRITE */ 
 
