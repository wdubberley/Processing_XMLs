USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlTS_FracQuotes]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***********************************************************************************************
  20190305- Added AlternateName; Link data to fnTMP_WellInfo() to match only recent/current pads/wells
  20190510- Added ClientProvided
  20190625- Adjusted SequenceNo to use DENSE_RANK()
  20191219(v004)- SET quote date to default today's date if it is null
  20220513(v005)- Added Bonus_Eligible
************************************************************************************************/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlTS_FracQuotes]()
RETURNS TABLE
AS
RETURN 

	WITH cTypes		AS (SELECT ItemValue=ItemName, ID_Record FROM dbo.ref_Categories WHERE ID_Parent = 22)
		, cOptions	AS (SELECT ItemValue=ItemName, ID_Record FROM dbo.ref_Categories WHERE ID_Parent = 65)

	SELECT DISTINCT Well= xQ.Well
		, ID_ChargeType	= cT.ID_Record
		, ID_FracInfo	= eI.ID_FracInfo
		, ID_Operator	= mO.ID_Operator
		, ID_Well		= rW.ID_Well
		, TicketNo		= xQ.TicketNo
		, QuoteDate		= ISNULL(xQ.QuoteDate,CONVERT(DATE,GETDATE()))
		
		, SequenceNo	= DENSE_RANK() OVER (PARTITION BY eI.ID_FracInfo ORDER BY eI.ID_FracInfo, xQ.SequenceNo)
		
		, ChargeType		= xQ.ChargeType
		, ChargeDescription	= LTRIM(RTRIM(xQ.ChargeDescription))
		, ChargeCode		= LTRIM(RTRIM(xQ.ChargeCode))
		, ChargeQty			= xQ.ChargeQty
		, ChargeUnitPrice	= xQ.ChargeUnitPrice
		, ChargeUnit		= xQ.ChargeUnit
		, Discount			= xQ.Discount
		, WellTotal			= xQ.WellTotal
		
		, IsPassthrough		= cOpt.ID_Record
		, AlternateName		= REPLACE(ISNULL(xQ.AlternateName, xQ.ChargeDescription), 'NC_', '')
		, ClientProvided	= CASE WHEN xQ.ClientProvided = 'Yes' THEN 1 ELSE 0 END
		, Bonus_Eligible	= CASE WHEN xQ.Bonus_Eligible = 'Yes' THEN 1 ELSE 0 END				/* 20220513 */

		--, xQ.* 

		FROM [SSIS_ENG].xmlImport_TS_FracQuotes xQ
			INNER JOIN cTypes	cT		ON cT.ItemValue = xQ.ChargeType
			INNER JOIN cOptions	cOpt	ON cOpt.ItemValue = ISNULL(xQ.IsPassthrough, '')
			
			INNER JOIN [SSIS_ENG].mapping_Customer_Operator	mO ON mO.Customer = xQ.Operator
			INNER JOIN [SSIS_ENG].[fnTMP_WellInfo]()		rW ON rW.WellName = xQ.Well AND rW.ID_Operator = mO.ID_Operator
			INNER JOIN [dbo].FracInfo						eI ON eI.ID_Well = rW.ID_Well AND eI.LOS_ProjectNo = xQ.TicketNo AND eI.TotalIntervals > 0
			
		WHERE xQ.ChargeDescription IS NOT NULL AND xQ.ChargeDescription <> ''


GO
