USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlTS_DiverterPressureAnalysis]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlTS_DiverterPressureAnalysis]()
RETURNS TABLE
AS
RETURN 

	SELECT xDPA.*
		
		, sCTE.ID_FracStage
		, sCTE.ID_FracInfo
		--, lC.ID_Chemical

		FROM [SSIS_ENG].xmlImport_TS_DiverterPressureAnalysis xDPA 
			LEFT JOIN [SSIS_ENG].vw_FracStages_Header sCTE ON sCTE.WellName = xDPA.WellName AND sCTE.StageNo = xDPA.StageNo
	;


GO
