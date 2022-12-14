USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[PRE_REF_Units]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/************************************************************************
 Created:	KPHAM (20190830)
************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[PRE_REF_Units]	
AS
BEGIN

	DECLARE @rValue AS INT;
	
	WITH x_QuotedUnits AS
		(
		SELECT DISTINCT 
			ChargeUnit = ISNULL(ChargeUnit, '')			/* set default if null */
			, UnitBase = 'SERVICE'
			FROM [SSIS_ENG].xmlImport_TS_FracQuotes	qS
			WHERE ChargeType = 'Service'

		UNION ALL
		SELECT DISTINCT 
			ChargeUnit = ISNULL(ChargeUnit, 'GAL')		/* set default if null */
			, UnitBase = 'GAL'							
			FROM [SSIS_ENG].xmlImport_TS_FracQuotes	qS
			WHERE ChargeType = 'Chemical'
		
		UNION ALL
		SELECT DISTINCT 
			ChargeUnit	= ISNULL(ChargeUnit, 'LBS')		/* set default if null */
			, UnitBase	= 'LBS'
			FROM [SSIS_ENG].xmlImport_TS_FracQuotes	qS
			WHERE ChargeType = 'Proppant'
		
		)

	INSERT INTO dbo.ref_Units
		 (UnitName
		 , UnitDesc
		 , UnitBase
		 , Coefficient)

	SELECT UnitName	= UPPER(xU.ChargeUnit) 
		, UnitDesc	= UPPER(xU.ChargeUnit)
		, UnitBase	= UPPER(xU.UnitBase)
		, Coefficient = 1					/* By default everything is 1-to-1 */

		FROM x_QuotedUnits			xU
			LEFT JOIN dbo.ref_Units	rU ON rU.UnitBase = xU.UnitBase AND rU.UnitName = xU.ChargeUnit
		WHERE rU.ID_UNIT IS NULL;

	/***** RECORD INSERT HISTORY *****/
	SET @rValue = @@ROWCOUNT
	IF @rValue > 0 --select 'insert - dbo.ref_Units ' + Convert(varchar(10),@rValue)
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.ref_Units', 'Insert', @rValue;

END 


GO
