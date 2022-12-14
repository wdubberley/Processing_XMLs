USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlTS_FracStages_Chemicals]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************************************************************************
  20190510- Added ClientProvided flag
  20220303(v003)- Adjusted join parameter to compare Formation on NULL as ''
************************************************************************************/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlTS_FracStages_Chemicals]()
RETURNS TABLE
AS
RETURN 

	SELECT [Stage]		= xC.Stage
		, [Well]		= xC.Well
		, [ChemicalName]= xC.ChemicalName
		, [Chem_Frac]	= ISNULL(xC.Chem_Frac, 0)
		, [Chem_PD]		= ISNULL(xC.Chem_PD, 0)
		, [Chem_FracPD]	= ISNULL(xC.Chem_FracPD, 0)
		, [Chem_NC]		= ISNULL(xC.Chem_NC, 0)
		, [Chem_Micro]	= ISNULL(xC.Chem_Micro, 0)
		, [Chem_Design]	= ISNULL(xC.Chem_Design, 0)
		, ClientProvided	= CASE WHEN xC.ClientProvided LIKE '%Yes%' OR LTRIM(RTRIM(xC.ClientProvided)) = 'Y' THEN 1 ELSE 0 END
		
		, [Formation]	= xC.Formation
		, [FilePath]	= xC.FilePath
		
		--, xC.*
		, ID_FracStage	= sCTE.ID_FracStage
		, ID_FracInfo	= sCTE.ID_FracInfo
		, ID_Chemical	= lC.ID_Chemical

		FROM [SSIS_ENG].xmlImport_TS_FracChemicals		xC 
			INNER JOIN dbo.LOS_Chemicals				lC ON lC.ChemicalName = xC.ChemicalName
			LEFT JOIN [SSIS_ENG].vw_FracStages_Header	sCTE 
				ON sCTE.WellName = xC.Well 
					AND sCTE.StageNo = xC.Stage 
					AND (ISNULL(sCTE.Formation,'') = ISNULL(xC.Formation,'') OR sCTE.FilePath=xC.FilePath)
					
	;




GO
