USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlTS_FracStages_Designs]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******************************************************
  Created:	KPHAM (2017)
  20190913(v002)- List all columns; Set DENSE_RANK() for [STAGE_No] if it is null and CMTV_StageNo and Inteval_No exist
  20200323(v003)- Added N2_Rate, N2_Vol
  20220207(v004)- Added Step_Time
  20220303(v005)- Adjusted join parameter to compare Formation on NULL as ''
  20220630(v006)- Adjusted Interval_No,STAGE_No if structure changed to use STEP_No
*******************************************************/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlTS_FracStages_Designs]()
RETURNS TABLE
AS
RETURN 

	SELECT xD.[Operator]
		, xD.[Well]
		, xD.[API]
		, [INTERVAL_No]	= CASE WHEN xD.[INTERVAL_No] IS NULL AND xD.STEP_No IS NOT NULL THEN xD.STAGE_No ELSE xD.[INTERVAL_No] END
		, STAGE_No		= CASE WHEN xD.[INTERVAL_No] IS NULL AND xD.STEP_No IS NOT NULL THEN xD.STEP_No 
							ELSE --xD.[STAGE_No] 
								CASE WHEN xD.[STAGE_No] IS NULL AND xD.[INTERVAL_No] IS NOT NULL AND xD.CMTV_STAGE_No IS NOT NULL
										THEN DENSE_RANK() OVER(PARTITION BY Operator, Well, Interval_No ORDER BY Operator, Well, Interval_No, CMTV_Stage_No) 
									ELSE xD.[STAGE_No] END
							END
		--, STAGE_No				= CASE WHEN xD.[STAGE_No] IS NULL AND xD.[INTERVAL_No] IS NOT NULL AND xD.CMTV_STAGE_No IS NOT NULL
		--								THEN DENSE_RANK() OVER(PARTITION BY Operator, Well, Interval_No ORDER BY Operator, Well, Interval_No, CMTV_Stage_No) 
		--							ELSE xD.[STAGE_No] END
		, xD.[CMTV_STAGE_No]
		, xD.[Reset_Fluid_Vol_]
		, xD.[Reset_Sand_Count]
		, xD.[Job_Re_Design]
		, xD.[Clean_Vol_]
		, xD.[Slurry_Vol_]
		, xD.[Proppant_Amount]
		, xD.[Pressure]
		, xD.[Rate]
		, xD.[Visc]
		, xD.[Temp]
		, xD.[N2_Rate]			/* 20200323 */
		, xD.[N2_Vol]			/* 20200323 */
		, xD.[pH]
		, xD.[Stage_Type]
		, xD.[Fluid_Type]
		, xD.[Proppant_Type]
		, xD.[PPA]
		, xD.[Design_SlurryRate_bpm]
		, xD.[Design_Clean_Volume_gal]
		, xD.[CleanVol_Design_bbl]
		, xD.[CleanVol_Design_Cumulative_bbl]
		, xD.[CleanVol_Actual_bbl]
		, xD.[SlurryVol_DesignCalculated_bbl]
		, xD.[SlurryVol_Actual_bbl]
		, xD.[Proppant_Stage_Design_lbs]
		, xD.[Proppant_Cumulative_Stage_Design_lbs]
		, xD.[Proppant_Stage_Calculated_lbs]
		, xD.[Proppant_Stage_Screw_Counter_lbs]
		, xD.[Proppant_Cumulative_JobDesign_lbs]
		, xD.[Proppant_Cumulative_Calculated_lbs]
		, xD.[Job_Screw_Counter]
		, xD.[Formation]
		, xD.[Step_Time]

		, dCTE.ID_FracStage
		, dCTE.ID_FracInfo

		FROM [SSIS_ENG].xmlImport_TS_Designs			xD 
			LEFT JOIN [SSIS_ENG].vw_FracStages_Header	dCTE ON dCTE.WellName = xD.Well 
																AND (ISNULL(dCTE.Formation,'') = ISNULL(xD.Formation,''))
																--AND dCTE.StageNo = xD.INTERVAL_No
																AND dCTE.StageNo = CASE WHEN xD.[INTERVAL_No] IS NULL AND xD.STEP_No IS NOT NULL THEN xD.STAGE_No ELSE xD.[INTERVAL_No] END
																
		--where xD.[STAGE_No] is null AND xD.[INTERVAL_No] IS NOT NULL AND xD.CMTV_STAGE_No IS NOT NULL
	;

GO
