USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlLOS_Employees]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*********************************************************************************
 Created:	KPHAM (2019)
 Desc:		This lists all Employee records from XMLs data
 20220223(v002)- Added Pump_Operator 
**********************************************************************************/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlLOS_Employees]()
RETURNS TABLE
AS
RETURN 

	/* TimeTracker */
	SELECT DISTINCT			/*** Added 20220223 ****/
		FirstName	= CASE WHEN CHARINDEX(' ', LTRIM(RTRIM(x.Pump_Operator))) = 0 THEN LTRIM(RTRIM(x.Pump_Operator))
							ELSE SUBSTRING(LTRIM(x.Pump_Operator), 1, CHARINDEX(' ', LTRIM(x.Pump_Operator),1)-1) END
		, LastName	= CASE WHEN CHARINDEX(' ', LTRIM(RTRIM(x.Pump_Operator))) = 0 THEN LTRIM(RTRIM(x.Pump_Operator))
							ELSE RTRIM(SUBSTRING(LTRIM(Pump_Operator), CHARINDEX(' ', LTRIM(Pump_Operator))+1, LEN(LTRIM(Pump_Operator)))) END
						
		FROM [SSIS_ENG].xmlImport_TT_TimeLogs x
		WHERE x.Pump_Operator IS NOT NULL  AND LEN(x.Pump_Operator) > 2								
	UNION 
	SELECT DISTINCT 
		FirstName	= CASE WHEN CHARINDEX(' ', LTRIM(RTRIM(x.QAQC))) = 0 THEN LTRIM(RTRIM(x.QAQC))
							ELSE SUBSTRING(LTRIM(x.QAQC), 1, CHARINDEX(' ', LTRIM(x.QAQC),1)-1) END
		, LastName	= CASE WHEN CHARINDEX(' ', LTRIM(RTRIM(x.QAQC))) = 0 THEN LTRIM(RTRIM(x.QAQC))
							ELSE RTRIM(SUBSTRING(LTRIM(QAQC), CHARINDEX(' ', LTRIM(QAQC))+1, LEN(LTRIM(QAQC)))) END
						
		FROM [SSIS_ENG].xmlImport_TT_TimeLogs x
		WHERE x.QAQC IS NOT NULL  AND LEN(x.QAQC) > 2
	UNION 
	SELECT DISTINCT --Engineer
		FirstName	= CASE WHEN CHARINDEX(' ', LTRIM(RTRIM(x.Engineer))) = 0 THEN LTRIM(RTRIM(x.Engineer))
							ELSE SUBSTRING(LTRIM(x.Engineer), 1, CHARINDEX(' ', LTRIM(x.Engineer),1)-1) END
		, LastName	= CASE WHEN CHARINDEX(' ', LTRIM(RTRIM(x.Engineer))) = 0 THEN LTRIM(RTRIM(x.Engineer))
							ELSE RTRIM(SUBSTRING(LTRIM(Engineer), CHARINDEX(' ', LTRIM(Engineer))+1, LEN(LTRIM(Engineer)))) END
							
		FROM [SSIS_ENG].xmlImport_TT_TimeLogs x
		WHERE x.Engineer IS NOT NULL AND LEN(x.Engineer) > 2
	UNION 
	SELECT DISTINCT 
		FirstName	= CASE WHEN CHARINDEX(' ', LTRIM(RTRIM(x.Supervisor))) = 0 THEN LTRIM(RTRIM(x.Supervisor))
							ELSE SUBSTRING(LTRIM(x.Supervisor), 1, CHARINDEX(' ', LTRIM(x.Supervisor),1)-1) END
		, LastName	= CASE WHEN CHARINDEX(' ', LTRIM(RTRIM(x.Supervisor))) = 0 THEN LTRIM(RTRIM(x.Supervisor))
							ELSE RTRIM(SUBSTRING(LTRIM(Supervisor), CHARINDEX(' ', LTRIM(Supervisor))+1, LEN(LTRIM(Supervisor)))) END
							
		FROM [SSIS_ENG].xmlImport_TT_TimeLogs x
		WHERE x.Supervisor IS NOT NULL AND LEN(x.Supervisor) > 2

	/* TechSheets */
	UNION
	SELECT DISTINCT --Supervisor
		FirstName	= CASE WHEN CHARINDEX(' ', LTRIM(RTRIM(x.Supervisor))) = 0 THEN LTRIM(RTRIM(x.Supervisor))
							ELSE SUBSTRING(LTRIM(x.Supervisor), 1, CHARINDEX(' ', LTRIM(x.Supervisor),1)-1) END			
		, LastName	= CASE WHEN CHARINDEX(' ', LTRIM(RTRIM(x.Supervisor))) = 0 THEN LTRIM(RTRIM(x.Supervisor))
							ELSE RTRIM(SUBSTRING(LTRIM(Supervisor), CHARINDEX(' ', LTRIM(Supervisor))+1, LEN(LTRIM(Supervisor)))) END		
							
		FROM [SSIS_ENG].xmlImport_TS_FracStages x
		WHERE x.Supervisor IS NOT NULL AND LEN(x.Supervisor) > 2
	UNION 
	SELECT DISTINCT --Engineer
		FirstName	= CASE WHEN CHARINDEX(' ', LTRIM(RTRIM(x.Engineer))) = 0 THEN LTRIM(RTRIM(x.Engineer))
							ELSE SUBSTRING(LTRIM(x.Engineer), 1, CHARINDEX(' ', LTRIM(x.Engineer),1)-1) END		
		, LastName	= CASE WHEN CHARINDEX(' ', LTRIM(RTRIM(x.Engineer))) = 0 THEN LTRIM(RTRIM(x.Engineer))
							ELSE RTRIM(SUBSTRING(LTRIM(Engineer), CHARINDEX(' ', LTRIM(Engineer))+1, LEN(LTRIM(Engineer)))) END		
						
		FROM [SSIS_ENG].xmlImport_TS_FracStages x
		WHERE x.Engineer IS NOT NULL AND LEN(x.Engineer) > 2
	UNION
	SELECT DISTINCT --QAQC /*20180215*/
		FirstName	= CASE WHEN CHARINDEX(' ', LTRIM(RTRIM(x.QAQC))) = 0 THEN LTRIM(RTRIM(x.QAQC))
							ELSE SUBSTRING(LTRIM(x.QAQC), 1, CHARINDEX(' ', LTRIM(x.QAQC),1)-1) END		
		
		, LastName	= CASE WHEN CHARINDEX(' ', LTRIM(RTRIM(x.QAQC))) = 0 THEN LTRIM(RTRIM(x.QAQC))
							ELSE RTRIM(SUBSTRING(LTRIM(x.QAQC), CHARINDEX(' ', LTRIM(x.QAQC))+1, LEN(LTRIM(x.QAQC)))) END	
			
		FROM [SSIS_ENG].xmlImport_TS_FracStages x
		WHERE x.QAQC IS NOT NULL AND LEN(x.QAQC) > 2
		
	/* Sales & OPS */
	UNION
	SELECT DISTINCT --xC.Contact,
		FirstName	= CASE WHEN CHARINDEX(' ', LTRIM(RTRIM(xC.Contact))) = 0 THEN LTRIM(RTRIM(xC.Contact))
							ELSE SUBSTRING(LTRIM(xC.Contact), 1, CHARINDEX(' ', LTRIM(xC.Contact),1)-1) END
				
		, LastName	= CASE WHEN CHARINDEX(' ', LTRIM(RTRIM(xC.Contact))) = 0 THEN LTRIM(RTRIM(xC.Contact))
							ELSE RTRIM(SUBSTRING(LTRIM(xC.Contact), CHARINDEX(' ', LTRIM(xC.Contact))+1, LEN(LTRIM(xC.Contact)))) END
			
		FROM [SSIS_ENG].fnRPT_xmlTS_FracInfo_Contacts() xC
		WHERE xC.ID_ContactType IN (19,20) -- Ref to Engineering.ref_Category.ID_Parent = 18
		
	/* SupplyChain: Consignor_Name */
	--UNION
	--SELECT DISTINCT 
	--	FirstName	= CASE WHEN CHARINDEX(' ', LTRIM(RTRIM(xC.Consignor_Name))) = 0 THEN LTRIM(RTRIM(xC.Consignor_Name))
	--					ELSE SUBSTRING(LTRIM(xC.Consignor_Name), 1, CHARINDEX(' ', LTRIM(xC.Consignor_Name),1)-1) END
	--	, LastName	= CASE WHEN CHARINDEX(' ', LTRIM(RTRIM(xC.Consignor_Name))) = 0 THEN LTRIM(RTRIM(xC.Consignor_Name))
	--					ELSE RTRIM(SUBSTRING(LTRIM(xC.Consignor_Name), CHARINDEX(' ', LTRIM(xC.Consignor_Name))+1, LEN(LTRIM(xC.Consignor_Name)))) END
	--	FROM [SSIS_ENG].[xmlImport_CHEM_BOLs] xC
	--	WHERE xC.Consignor_Name IS NOT NULL	AND LEN(xC.Consignor_Name) > 2
				
	--UNION
	--SELECT DISTINCT 
	--	FirstName	= CASE WHEN CHARINDEX(' ', LTRIM(RTRIM(xC.Consignor_Name))) = 0 THEN LTRIM(RTRIM(xC.Consignor_Name))
	--					ELSE SUBSTRING(LTRIM(xC.Consignor_Name), 1, CHARINDEX(' ', LTRIM(xC.Consignor_Name),1)-1) END
	--	, LastName	= CASE WHEN CHARINDEX(' ', LTRIM(RTRIM(xC.Consignor_Name))) = 0 THEN LTRIM(RTRIM(xC.Consignor_Name))
	--					ELSE RTRIM(SUBSTRING(LTRIM(xC.Consignor_Name), CHARINDEX(' ', LTRIM(xC.Consignor_Name))+1, LEN(LTRIM(xC.Consignor_Name)))) END 
						
	--	FROM [SSIS_ENG].[xmlImport_CHEM_FuelBOLs] xC
	--	WHERE xC.Consignor_Name IS NOT NULL  AND LEN(xC.Consignor_Name) > 2
	;

GO
