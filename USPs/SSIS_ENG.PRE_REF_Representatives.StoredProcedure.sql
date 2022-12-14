USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[PRE_REF_Representatives]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*************************************************************************************
  Created:	KPHAM
  20210329(v002)- Adjusted First/Last Name for Cust.REP
**************************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[PRE_REF_Representatives]	
AS
BEGIN

	DECLARE @rValue AS INT;

	WITH eCTE (FirstName, LastName) AS 
		(SELECT DISTINCT --CustomerRep
			FirstName		= CASE WHEN CHARINDEX(' ', LTRIM(CustomerRep),1) = 0 THEN LTRIM(RTRIM(CustomerRep) )
									ELSE SUBSTRING(LTRIM(CustomerRep), 1, CHARINDEX(' ', LTRIM(CustomerRep),1)-1) END
			, LastName		= CASE WHEN CHARINDEX(' ', LTRIM(CustomerRep),1) = 0 THEN '' 
									ELSE RTRIM(SUBSTRING(LTRIM(CustomerRep), CHARINDEX(' ', LTRIM(CustomerRep))+1, LEN(LTRIM(CustomerRep)))) END
			--FirstName		= SUBSTRING(LTRIM(CustomerRep), 1, CHARINDEX(' ', LTRIM(CustomerRep),1)-1)
			--, LastName		= RTRIM(SUBSTRING(LTRIM(CustomerRep), CHARINDEX(' ', LTRIM(CustomerRep))+1, LEN(LTRIM(CustomerRep))))
			FROM [SSIS_ENG].xmlImport_TS_FracStages x
			WHERE CustomerRep IS NOT NULL AND LEN(x.CustomerRep) > 2
		UNION
		SELECT DISTINCT 
			FirstName		= CASE WHEN CHARINDEX(' ', LTRIM(CustomerRep),1) = 0 THEN LTRIM(RTRIM(CustomerRep) )
									ELSE SUBSTRING(LTRIM(CustomerRep), 1, CHARINDEX(' ', LTRIM(CustomerRep),1)-1) END
			, LastName		= CASE WHEN CHARINDEX(' ', LTRIM(CustomerRep),1) = 0 THEN '' 
									ELSE RTRIM(SUBSTRING(LTRIM(CustomerRep), CHARINDEX(' ', LTRIM(CustomerRep))+1, LEN(LTRIM(CustomerRep)))) END
			FROM [SSIS_ENG].xmlImport_TT_TimeLogs x
			WHERE LEN(x.CustomerRep) > 1 --AND CHARINDEX(' ', LTRIM(CustomerRep),1) > 0

		/* Sales Contacts */
		UNION 
		SELECT  DISTINCT 
			FirstName	= CASE WHEN CHARINDEX(' ', LTRIM(xC.Contact),1) = 0 THEN LTRIM(RTRIM(xC.Contact) )
							ELSE SUBSTRING(LTRIM(xC.Contact), 1, CHARINDEX(' ', LTRIM(xC.Contact),1)-1) END
						--SUBSTRING(LTRIM(xC.Contact), 1, CHARINDEX(' ', LTRIM(xC.Contact),1)-1)
			, LastName	= CASE WHEN CHARINDEX(' ', LTRIM(xC.Contact),1) = 0 THEN '' 
							ELSE RTRIM(SUBSTRING(LTRIM(xC.Contact), CHARINDEX(' ', LTRIM(xC.Contact))+1, LEN(LTRIM(xC.Contact)))) END
						--RTRIM(SUBSTRING(LTRIM(xC.Contact), CHARINDEX(' ', LTRIM(xC.Contact))+1, LEN(LTRIM(xC.Contact))))
			FROM [SSIS_ENG].fnRPT_xmlTS_FracInfo_Contacts() xC 
			WHERE LEN(xC.Contact) > 1
				AND ID_ContactType IN (21)		-- Ref to Engineering.ref_Category.ID_Parent = 18
				AND xC.Contact IS NOT NULL
		)

	INSERT INTO dbo.ref_Representatives (FirstName, LastName)
	SELECT FirstName	= eCTE.FirstName
		, LastName		= eCTE.LastName
		FROM eCTE
			LEFT JOIN dbo.ref_Representatives rR ON rR.FirstName = eCTE.FirstName AND rR.LastName=eCTE.LastName
		WHERE rR.ID_Record IS NULL

	/***** RECORD INSERT HISTORY *****/
	SET @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.ref_Representatives', 'Insert', @rValue

END 




GO
