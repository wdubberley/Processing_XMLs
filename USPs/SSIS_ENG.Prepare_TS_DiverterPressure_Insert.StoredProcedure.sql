USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_DiverterPressure_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************
  Created:	KPHAM
  20201204(v002)- Added Diverter_Type_3/4, Lbs_of_Diverter_Type_3/4 per DK
***************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_DiverterPressure_Insert]	
AS
BEGIN
	INSERT INTO [dbo].[DiverterPressureAnalysis]
           ([ID_FracInfo]
           ,[ID_FracStage]
           ,[AnalysisNo]
           ,[Avg_PSI_Before_Diversion]
           ,[Avg_Rate_Before_Diversion]
           ,[Stable_BH_Pressure_Before_Diversion]
           ,[Diverter_Hit_PSI]
           ,[Diverter_Hit_Rate]
           ,[BH_Pressure_Before_Diverter]
           ,[Max_Pressure_at_Diverter_Landing]
           ,[BH_Max_Pressure_at_Diverter_Landing]
           ,[Delta_Pressure_After_Diverter]
           ,[Diverter_Type_1]
           ,[Lbs_of_Diverter_Type_1]
           ,[Diverter_Type_2]
           ,[Lbs_of_Diverter_Type_2]
           ,[Diverter_Type_3]
           ,[Lbs_of_Diverter_Type_3]
           ,[Diverter_Type_4]
           ,[Lbs_of_Diverter_Type_4]
           
		   ,[Total_Lbs_Diverter])

	SELECT xDPA.[ID_FracInfo]
		,xDPA.[ID_FracStage]
		,xDPA.[AnalysisNo]
		,xDPA.[Avg_PSI_Before_Diversion]
		,xDPA.[Avg_Rate_Before_Diversion]
		,xDPA.[Stable_BH_Pressure_Before_Diversion]
		,xDPA.[Diverter_Hit_PSI]
		,xDPA.[Diverter_Hit_Rate]
		,xDPA.[BH_Pressure_Before_Diverter]
		,xDPA.[Max_Pressure_at_Diverter_Landing]
		,xDPA.[BH_Max_Pressure_at_Diverter_Landing]
		,xDPA.[Delta_Pressure_After_Diverter]
		,xDPA.[Diverter_Type_1]
		,xDPA.[Lbs_of_Diverter_Type_1]
		,xDPA.[Diverter_Type_2]
		,xDPA.[Lbs_of_Diverter_Type_2]
		,xDPA.[Diverter_Type_3]
		,xDPA.[Lbs_of_Diverter_Type_3]
		,xDPA.[Diverter_Type_4]
		,xDPA.[Lbs_of_Diverter_Type_4]
		,xDPA.[Total_Lbs_Diverter]
	
		FROM [SSIS_ENG].[fnRPT_xmlTS_DiverterPressureAnalysis]() xDPA
			LEFT JOIN dbo.DiverterPressureAnalysis fDPA 
				ON (fDPA.ID_FracStage = xDPA.ID_FracStage AND fDPA.[AnalysisNo]=xDPA.[AnalysisNo]) 
		WHERE (xDPA.ID_FracStage IS NOT NULL AND xDPA.ID_FracInfo IS NOT NULL)
			AND fDPA.ID_DiverterPressure IS NULL
	;

END 

GO
