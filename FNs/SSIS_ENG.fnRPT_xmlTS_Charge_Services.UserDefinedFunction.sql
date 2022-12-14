USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlTS_Charge_Services]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************************************************************************************************************************
  20190226- Update code to map ServiceName to Quote.Well + Quote.ChargeDescription for PartNo then map back to dbo.LOS_ChargeServices
  20190303(v003)- Correct join to read ChargeCode from dbo.FracQuotes if exists
  20190827(v004)- Added ChargeUnit from dbo.FracQuotes if exists
  20191217(v005)- Have ChargeCode also pull from Proppants section (25) for Proppant handling items.
  20210427(v006)- Adjusted Discount_Percent to decimal (divide by 100) if ABS is out of range
  20210428(v007)- Adjusted Service_Discount to pull from Quote
  20220303(v008)- Adjusted join parameter to compare Formation on NULL as ''
  20220512(v009)- Added Bonus_Eligible for CAN jobs
************************************************************************************************************************************/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlTS_Charge_Services]()
RETURNS TABLE
AS
RETURN 

	WITH cOptions AS (SELECT ItemName, ID_Record FROM dbo.ref_Categories WHERE ID_Parent=65)

	/******* PREVIOUS VERSION OF DailyXML without Quote section *******/
	SELECT Stage	= xCS.Stage
		, Well		= xCS.Well
		, Formation = xCS.Formation

		, ServiceName	= xCS.ServiceName
		, ChargeCode	= ISNULL((SELECT Qi.ChargeCode 
									FROM dbo.FieldQuote_Items Qi
									WHERE Qi.ID_FracInfo = Stg.ID_FracInfo
										AND Qi.ID_ChargeType IN (23,25)
										AND ISNUMERIC(Qi.ChargeCode) = 1
										AND Qi.AlternateName = xCS.ServiceName)
								, lS.PartNo)
		, ChargeUnit	= ISNULL((SELECT Qi.ChargeUnit
									FROM dbo.FieldQuote_Items Qi
									WHERE Qi.ID_FracInfo = Stg.ID_FracInfo
										AND Qi.ID_ChargeType IN (23,25)
										AND ISNUMERIC(Qi.ChargeCode) = 1
										AND Qi.AlternateName = xCS.ServiceName)
								, '')
		
		, Service_Price		= xCS.Service_Price
		, ServiceQuantity	= xCS.ServiceQuantity
		, ServiceCost		= xCS.ServiceCost
		, IsPassthrough		= xCS.IsPassthrough
		, Service_Discount	= ISNULL((SELECT TOP 1 Qi.Discount
										FROM dbo.FieldQuote_Items Qi
										WHERE Qi.ID_FracInfo = Stg.ID_FracInfo
											AND Qi.ID_ChargeType IN (23,25) 
											AND ISNUMERIC(Qi.ChargeCode) = 1
											AND Qi.AlternateName = xCS.ServiceName)
									, CASE WHEN ABS(ISNULL(xCS.Discount_Percent, 0)) > 1 THEN ISNULL(xCS.Discount_Percent, 0) / 100.00000
										ELSE ISNULL(xCS.Discount_Percent, 0) END
								)
		, display_Discount	= CASE WHEN ABS(ISNULL(xCS.Discount_Percent, 0)) > 1 THEN ISNULL(xCS.Discount_Percent, 0) / 100.00000
								ELSE ISNULL(xCS.Discount_Percent, 0) END
		, Item_Passthrough	= cOpt.ID_Record
		, Bonus_Eligible	= CASE WHEN xCS.Bonus_Eligible LIKE 'y%' THEN 1 ELSE 0 END

		, ID_Record			= xCS.ID_Record
		, ID_FracInfo		= Stg.ID_FracInfo
		, ID_FracStage		= Stg.ID_FracStage
		, ID_ChargeService	= ls.ID_ChargeService		

		--, FilePath		= xCS.FilePath
		--, xCS.*

		FROM [SSIS_ENG].xmlImport_TS_ChargesServices	xCS 
			LEFT JOIN [SSIS_ENG].vw_FracStages_Header	Stg ON Stg.WellName = xCS.Well AND Stg.StageNo = xCS.Stage 
																AND (ISNULL(Stg.Formation,'') = ISNULL(xCS.Formation,''))

			INNER JOIN dbo.LOS_ChargeServices	lS ON lS.ServiceName = xCS.ServiceName
			INNER JOIN cOptions					cOpt ON cOpt.ItemName = ISNULL(xCS.IsPassthrough, '') 
	;
GO
