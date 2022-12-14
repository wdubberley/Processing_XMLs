USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlTS_FracStages_Fluids]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************************************
 Created:	KPHAM
 20220303(v002)- Adjusted join parameter to compare Formation on NULL as ''
******************************************************************************/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlTS_FracStages_Fluids]()
RETURNS TABLE
AS
RETURN 
	
	SELECT xF.*
		, fCTE.ID_FracStage
		, fCTE.ID_FracInfo
		, mF.ID_Fluid
		--, lF.ID_FLuid
		FROM [SSIS_ENG].xmlImport_TS_FracFluids xF
			INNER JOIN [SSIS_ENG].mapping_Fluids mF ON mF.Fluid = xF.FluidName
			LEFT JOIN [SSIS_ENG].vw_FracStages_Header fCTE ON fCTE.WellName = xF.Well AND fCTE.StageNo = xF.Stage 
						AND (ISNULL(fCTE.Formation,'') = ISNULL(xF.Formation,''))
	;


GO
