USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_FracDesign_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******************************************************
  Created:	KPHAM (2017)
  20200323(v002)- Added N2_Rate, N2_Vol
  20220207(v003)- Added Step_Time
*******************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_FracDesign_Insert]	
AS
BEGIN
	INSERT INTO [dbo].FracDesign
		([ID_FracInfo]
		,[ID_FracStage]
		,[StageNo]
		,[SubStage]
		,[CumStageNo]
		,[ResetVol]
		,[ResetSand]
		,[JobReDesign]
		,[Marker_CleanVol_bbl]
		,[Marker_SlurryVol_bbl]
		,[Marker_CumProppant_lbs]
		,[Step_Time]

		,[PerStage_AvgPressure_psi]
		,[PerStage_AvgRate_bpm]
		,[PerStage_AvgVisc_cp]
		,[PerStage_AvgTemp_F]
		,[PerStage_N2_Rate]			/* 20200323 */
		,[PerStage_N2_Vol]			/* 20200323 */
		,[PerStage_AvgPH_pH]
		
		,[ID_StageType]
		,[ID_FluidType]
		,[ID_ProppantType]
		,[PPA]
		,[Design_SlurryRate_bpm]
		,[Design_CleanVol_gal]
		,[Clean_DesignVol_bbl]
		,[Clean_DesignCumVol_bbl]
		,[Clean_ActualVol_bbl]
		,[Slurry_DesignVol_bbl]
		,[Slurry_AcualVol_bbl]
		,[Proppant_StageDesign_lbs]
		,[Proppant_StageDesignCum_lbs]
		,[Proppant_StageCalc_lbs]
		,[Proppant_StageScrew_lbs]
		,[Proppant_CumJobDesign_lbs]
		,[Proppant_CumCalc_lbs]
		,[Proppant_CumJobScrew_lbs])

	SELECT [ID_FracInfo]			= xD.ID_FracInfo
		, [ID_FracStage]			= xD.ID_FracStage
		, [StageNo]					= xD.[INTERVAL_No]
		, [SubStage]				= xD.[STAGE_No]
		, [CumStageNo]				= xD.[CMTV_STAGE_No]
		, [ResetVol]				= CASE WHEN xD.[Reset_Fluid_Vol_] LIKE 'Y%' THEN 1 ELSE 0 END
		, [ResetSand]				= CASE WHEN xD.[Reset_Sand_Count] LIKE 'Y%' THEN 1 ELSE 0 END
		, [JobReDesign]				= CASE WHEN xD.[Job_Re_Design] LIKE 'Y%' THEN 1 ELSE 0 END
		, [Marker_CleanVol_bbl]		= xD.[Clean_Vol_]
		, [Marker_SlurryVol_bbl]	= xD.[Slurry_Vol_]
		, [Marker_CumProppant_lbs]	= xD.[Proppant_Amount]
		, [Step_Time]				= xD.[Step_Time]

		, [PerStage_AvgPressure_psi]= xD.[Pressure]
		, [PerStage_AvgRate_bpm]	= CASE WHEN LTRIM(xD.[Rate])='' OR ISNUMERIC(xD.[Rate])=0 THEN NULL ELSE convert(float, xD.[Rate]) END
		, [PerStage_AvgVisc_cp]		= xD.[Visc]
		, [PerStage_AvgTemp_F]		= xD.[Temp]
		, [PerStage_N2_Rate]		= xD.[N2_Rate]	/* 20200323 */
		, [PerStage_N2_Vol]			= xD.[N2_Vol]	/* 20200323 */
		, [PerStage_AvgPH_pH]		= xD.[pH]

		, ID_StageType				= CASE WHEN rdS.ID_StageType IS NULL THEN 0 ELSE rdS.ID_StageType END 
		, ID_FluidType				= CASE WHEN rF.ID_Fluid IS NULL THEN 0 ELSE rF.ID_Fluid END 
		, ID_ProppantType			= CASE WHEN rPpt.ID_Proppant IS NULL THEN 0 ELSE rPpt.ID_Proppant END 
		, [PPA]						= xD.[PPA]

		, [Design_SlurryRate_bpm]	= xD.[Design_SlurryRate_bpm]
		, [Design_CleanVol_gal]		= xD.[Design_Clean_Volume_gal]
		, [Clean_DesignVol_bbl]		= xD.[CleanVol_Design_bbl]
		, [Clean_DesignCumVol_bbl]	= xD.[CleanVol_Design_Cumulative_bbl]
		, [Clean_ActualVol_bbl]		= xD.[CleanVol_Actual_bbl]
		, [Slurry_DesignVol_bbl]	= xD.[SlurryVol_DesignCalculated_bbl]
		, [Slurry_AcualVol_bbl]		= xD.[SlurryVol_Actual_bbl]

		, [Proppant_StageDesign_lbs]	= xD.[Proppant_Stage_Design_lbs]
		, [Proppant_StageDesignCum_lbs]	= xD.[Proppant_Cumulative_Stage_Design_lbs]
		, [Proppant_StageCalc_lbs]		= xD.[Proppant_Stage_Calculated_lbs]
		, [Proppant_StageScrew_lbs]		= xD.[Proppant_Stage_Screw_Counter_lbs]
		, [Proppant_CumJobDesign_lbs]	= xD.[Proppant_Cumulative_JobDesign_lbs]
		, [Proppant_CumCalc_lbs]		= xD.[Proppant_Cumulative_Calculated_lbs]
		, [Proppant_CumJobScrew_lbs]	= xD.[Job_Screw_Counter]

		FROM [SSIS_ENG].[fnRPT_xmlTS_FracStages_Designs]() xD
			LEFT JOIN  [dbo].[FracDesign] eD 
				ON (eD.ID_FracStage = xD.ID_FracStage AND eD.CumStageNo=xD.CMTV_Stage_No) 

			LEFT JOIN [SSIS_ENG].mapping_StageTypes rdS ON rdS.StageType = xD.Stage_Type
			LEFT JOIN [SSIS_ENG].mapping_Fluids rF ON rF.Fluid = xD.Fluid_Type
			LEFT JOIN [SSIS_ENG].mapping_Proppants rPpt ON rPpt.ProppantName = xD.Proppant_Type

		WHERE (xD.ID_FracStage IS NOT NULL AND xD.ID_FracInfo IS NOT NULL)
			AND eD.ID_FracDesign IS NULL
	;

END 

GO
