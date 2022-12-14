USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlTS_FracStages_Proppants]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************************************
  20190510- Added ClientProvided flag
  20220303(v003)- Adjusted join parameter to compare Formation on NULL as ''
******************************************************************************/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlTS_FracStages_Proppants]()
RETURNS TABLE
AS
RETURN 
	
	SELECT Stage	= xP.Stage
		, Well		= xP.Well

		, ProppantName		= xP.ProppantName
		, Prop_Total		= xP.Prop_Total
		, Prop_Actual		= xP.Prop_Actual
		, Prop_NC			= xP.Prop_NC
		, Prop_Design		= xP.Prop_Design
		, Prop_SlurryPLF	= xP.Prop_SlurryPLF
		, Formation			= xP.Formation
		, ClientProvided	= CASE WHEN xP.ClientProvided LIKE '%Yes%' OR LTRIM(RTRIM(xP.ClientProvided)) = 'Y' THEN 1 ELSE 0 END
		
		, ID_Record		= xP.ID_Record 
		, ID_FracStage	= pCTE.ID_FracStage
		, ID_FracInfo	= pCTE.ID_FracInfo
		, ID_Proppant	= lP.ID_Proppant

		FROM [SSIS_ENG].xmlImport_TS_FracProppants		xP
			INNER JOIN [SSIS_ENG].mapping_Proppants		lP ON lP.ProppantName = xP.ProppantName
			LEFT JOIN [SSIS_ENG].vw_FracStages_Header	pCTE 
				ON pCTE.WellName = xP.Well 
					AND pCTE.StageNo = xP.Stage 
					AND (ISNULL(pCTE.Formation,'') = ISNULL(xP.Formation,''))
	;

GO
