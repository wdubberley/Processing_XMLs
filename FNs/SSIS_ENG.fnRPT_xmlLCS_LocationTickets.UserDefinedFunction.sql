USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlLCS_LocationTickets]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******
  CREATED:	20180809 (KPHAM)
  20190512(v002)- Added filter to only show WellRecord NOT NULL
******/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlLCS_LocationTickets]()
RETURNS TABLE
AS
RETURN 
		
	SELECT ID_LocStrapInfo	= xI.ID_LocStrapInfo
		, [ID_Chemical]		= rC.ID_Chemical
		, [WellRecord]		= xTC.[WellRecord]
		, [ChemicalName]	= xTC.[ChemicalName]
		, [ChemicalValue]	= xTC.[ChemicalValue]

		, [ID_WellInfo]	= ISNULL(mWi.ID_WellInfo, 0)

		, ID_Record		= xTC.[ID_Record]
		, ID_Pad		= xI.ID_Pad
		, xmlFileName	= xI.xmlFileName
		, PadName		= xI.[PadName]
		, ID_MaterialInfo	= mI.ID_MaterialInfo
		--, mWi.*
		--, xI.* 
		--, xTC.*
	
		FROM [SSIS_ENG].[xmlImport_LCS_TicketChemEntries]	xTC
			INNER JOIN [SSIS_ENG].fnrpt_xmlLCS_Info()		xI ON xI.PadName = xTC.PadName
			INNER JOIN [dbo].[LOS_Chemicals]				rC ON rC.ChemicalName = xTC.ChemicalName

			LEFT JOIN [dbo].Material_Info		mI ON mI.ID_Pad = xI.ID_Pad
			LEFT JOIN [dbo].Material_WellInfo	mWi On mWi.ID_MaterialInfo = mI.ID_MaterialInfo AND mWi.WellName = xTC.WellRecord
		
		WHERE xTC.WellRecord IS NOT NULL
	;
	
GO
