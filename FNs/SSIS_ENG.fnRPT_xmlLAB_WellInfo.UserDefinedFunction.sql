USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlLAB_WellInfo]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/******
  Created:	KPHAM (20190415)
  Modified:	
******/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlLAB_WellInfo]()
RETURNS TABLE
AS
RETURN 

	SELECT ID_LabInfo	= xI.ID_LabInfo
		, WellName		= xW.[WellName]
	
		,xW.[ID_RecordNo]
		,xW.[xmlFileName]

		--,xW.[ID_Well]
		--,xW.[ID_Pad]
	
	FROM [SSIS_ENG].[xmlImport_LAB_WellInfo]	xW
		INNER JOIN [SSIS_ENG].fnRPT_xmlLAB_Info()	xI  ON xI.xmlFileName = xW.xmlFileName

	WHERE LTRIM(RTRIM(xW.WellName)) <> ''


GO
