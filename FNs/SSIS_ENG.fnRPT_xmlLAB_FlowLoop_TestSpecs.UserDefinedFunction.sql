USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlLAB_FlowLoop_TestSpecs]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** 
  CREATED:	20190416 (KPHAM)
  Modified:	
******/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlLAB_FlowLoop_TestSpecs] ()
RETURNS TABLE
AS
RETURN 
		
	SELECT DISTINCT ID_LabInfo	= xI.ID_LabInfo

		, TestNumber	= xF.FlowLoopTestNumber
		, countData		= COUNT(xF.FlowLoopOrder)
				
		, ID_Pad	= xI.ID_Pad
		, PadNumber	= xF.PadNumber
		
		FROM [SSIS_ENG].[xmlImport_LAB_FlowLoop_TestData]	xF
			INNER JOIN [SSIS_ENG].fnrpt_xmlLAB_Info()		xI ON xI.ID_Pad = xF.ID_Pad
		GROUP BY xI.ID_LabInfo
			, xI.ID_Pad
			, xF.FlowLoopTestNumber
			, xF.PadNumber
	;


GO
