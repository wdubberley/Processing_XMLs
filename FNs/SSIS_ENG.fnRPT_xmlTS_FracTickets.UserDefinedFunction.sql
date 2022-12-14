USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlTS_FracTickets]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***********************************************************************************************
  20220513(v005)- Added Bonus_Eligible
  20220525(v006)- Added LTRIM to ChargeDescription
************************************************************************************************/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlTS_FracTickets]()
RETURNS TABLE
AS
RETURN 

	WITH cte_Options AS (SELECT ItemName, ID_Record FROM dbo.ref_Categories WHERE ID_Parent=65)

	SELECT ID_FracInfo			= eI.ID_FracInfo
		, ID_Operator			= mO.ID_Operator
		, ID_Well				= rW.ID_Well
		, TicketNo				= xT.TicketNo
		, TicketDate			= xT.TicketDate

		, TotalWellsOnPad		= xT.TotalWellsOnPad
		, TotalStagesPlanned	= xT.TotalStagesPlanned
		, TotalStagesCompleted	= xT.TotalStagesCompleted

		, ChargeType			= xT.ChargeType
		, ChargeDescription		= LTRIM(xT.ChargeDescription)
		, ChargeCode			= xT.ChargeCode
		, ChargeQty				= xT.ChargeQty
		, ChargeUnitPrice		= xT.ChargeUnitPrice
		, ChargeUnit			= xT.ChargeUnit
		, Discount				= xT.Discount
		, WellTotal				= xT.WellTotal
		, SequenceNo			= RANK() OVER (PARTITION BY eI.ID_FracInfo ORDER BY eI.ID_FracInfo, xT.SequenceNo)

		, IsPassthrough			= cOpt.ID_Record
		, Bonus_Eligible		= CASE WHEN xT.Bonus_Eligible = 'Yes' THEN 1 ELSE 0 END		/* 20220513 */

		--, xT.* 
		, FilePath				= xT.FilePath
		, FileDate				= xT.FileDate

		FROM SSIS_ENG.xmlImport_TS_FracTickets xT
			INNER JOIN SSIS_ENG.mapping_Customer_Operator mO ON mO.Customer = xT.Operator
			INNER JOIN dbo.LOS_Wells rW ON rW.WellName = xT.Well AND rW.ID_Operator = mO.ID_Operator
			INNER JOIN dbo.FracInfo eI ON eI.ID_Well = rW.ID_Well AND eI.LOS_ProjectNo = xT.TicketNo AND eI.TotalIntervals > 0

			INNER JOIN cte_Options cOpt ON cOpt.ItemName = CASE WHEN xT.IsPassthrough IS NULL THEN '' ELSE xT.IsPassthrough END

		WHERE ChargeDescription IS NOT NULL AND ChargeDescription <> ''
		
GO
