USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlTS_FracStages_Designs_ChemSP]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******************************************************
  Created:	KPHAM (2017)
  20190913(v002)- List all columns; Set DENSE_RANK() for [STAGE_No] if it is null and CMTV_StageNo and Inteval_No exist
  20220303(v003)- Adjusted join parameter to compare Formation on NULL as ''
  20220630(v004)- Adjusted Interval_No,STAGE_No if structure changed to use STEP_No
*******************************************************/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlTS_FracStages_Designs_ChemSP]()
RETURNS TABLE
AS
RETURN 

	SELECT xSP.[Operator]
		, xSP.[Well]
		, xSP.[API]
		, [INTERVAL_No]	= CASE WHEN xSP.[INTERVAL_No] IS NULL AND xSP.STEP_No IS NOT NULL THEN xSP.STAGE_No ELSE xSP.[INTERVAL_No] END
		, STAGE_No		= CASE WHEN xSP.[INTERVAL_No] IS NULL AND xSP.STEP_No IS NOT NULL THEN xSP.STEP_No 
							ELSE --xD.[STAGE_No] 
								CASE WHEN xSP.[STAGE_No] IS NULL AND xSP.[INTERVAL_No] IS NOT NULL AND xSP.CMTV_STAGE_No IS NOT NULL
										THEN DENSE_RANK() OVER(PARTITION BY Operator, Well, Interval_No ORDER BY Operator, Well, Interval_No, CMTV_Stage_No) 
									ELSE xSP.[STAGE_No] END
							END
		--, STAGE_No				= CASE WHEN xSP.[STAGE_No] IS NULL AND xSP.[INTERVAL_No] IS NOT NULL AND xSP.CMTV_STAGE_No IS NOT NULL
		--								THEN DENSE_RANK() OVER(PARTITION BY Operator, Well, Interval_No ORDER BY Operator, Well, Interval_No, CMTV_Stage_No) 
		--							ELSE xSP.[STAGE_No] END, xSP.[CMTV_STAGE_No]
		, xSP.[CMTV_STAGE_No]
		, xSP.[ChemicalName]
		, xSP.[ChemSP_Value]
		, xSP.[Formation]

		, spCTE.ID_FracStage
		, spCTE.ID_FracInfo
		, lC.ID_Chemical

		FROM [SSIS_ENG].xmlImport_TS_Designs_ChemSP		xSP
			INNER JOIN dbo.LOS_Chemicals				lC ON lC.ChemicalName = xSP.ChemicalName
			LEFT JOIN [SSIS_ENG].vw_FracStages_Header	spCTE ON spCTE.WellName = xSP.Well 
																AND (ISNULL(spCTE.Formation,'') = ISNULL(xSP.Formation,''))
																--AND spCTE.StageNo = xSP.INTERVAL_No
																AND spCTE.StageNo = CASE WHEN xSP.[INTERVAL_No] IS NULL AND xSP.STEP_No IS NOT NULL THEN xSP.STAGE_No ELSE xSP.[INTERVAL_No] END
		--where spCTE.ID_FracInfo IS NOT NULL
	;

GO
