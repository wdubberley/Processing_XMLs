USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlTS_FracInfo_Contacts]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlTS_FracInfo_Contacts]()
RETURNS TABLE
AS
RETURN 
	
	WITH contactSales AS
		(SELECT t1.ID_Pad
			, t1.ID_Well
			, t1.ID_FracInfo
			, t1.WellName
			, t1.ID_District
			, Contact	= RTRIM(LTRIM(i.items))
			, ID_ContactType	= 19
			
			FROM [SSIS_ENG].fnRPT_xmlTS_FracInfo() t1
				outer apply dbo.Split(t1.LOS_Sales_Contact, '/') i
		)

	, contactOps AS
		(SELECT t1.ID_Pad
			, t1.ID_Well
			, t1.ID_FracInfo
			, t1.WellName
			, t1.ID_District
			, Contact	= RTRIM(LTRIM(i.items))
			, ID_ContactType	= 20

			FROM [SSIS_ENG].fnRPT_xmlTS_FracInfo() t1
				outer apply dbo.Split(t1.LOS_Ops_Contact, '/') i
		)
	, contactCust AS
		(SELECT t1.ID_Pad
			, t1.ID_Well
			, t1.ID_FracInfo
			, t1.WellName
			, t1.ID_District
			, Contact	= RTRIM(LTRIM(i.items))
			, ID_ContactType	= 21

			FROM [SSIS_ENG].fnRPT_xmlTS_FracInfo() t1
				outer apply dbo.Split(t1.Cust_Contact, '/') i
		)
	, contactGroup AS
		(SELECT * FROM contactSales
		UNION 
		SELECT * FROM contactOps
		UNION 
		SELECT * FROM contactCust
		)

	SELECT * 
		FROM ContactGroup
		WHERE Contact IS NOT NULL

GO
