USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_TECHStudy_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******************************************************************
  Created:	KPHAM (20200326)
  20200616(v003)- Added ORP, Treated_pH, Untreated_pH
******************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_TECHStudy_Insert]	
AS
BEGIN

	INSERT INTO [dbo].[TechSheet_TECHStudy]
		([ID_FracInfo]
		,[ID_FracStage]

		,[Acid_Relief]
		,[AcidDisplaceRate]
		,[AveInj]
		,[AveN2Rate]
		,[BHN2Factor]
		,[FSD_1st_Rate]
		,[FSD_1st_PSI]
		,[FSD_1st_BHP]
		,[FSD_2nd_Rate]
		,[FSD_2nd_PSI]
		,[FSD_2nd_BHP]
		,[FSD_3rd_Rate]
		,[FSD_3rd_PSI]
		,[FSD_3rd_BHP]
		,[FSD_MaxRate]
		,[FSD_WB_Fric]
		,[FSD_NWB_Fric]
		,[FSD_Perf_Fric]
		,[FSD_T_Fric]
		,[FSD_Perfs_Open]
		,[FSD_StartRate]
		,[FSD_Start_PSI]
		,[FSD_Start_BHP]
		,[ISD_1st_Rate]
		,[ISD_1st_PSI]
		,[ISD_1st_BHP]
		,[ISD_2nd_Rate]
		,[ISD_2nd_PSI]
		,[ISD_2nd_BHP]
		,[ISD_3rd_Rate]
		,[ISD_3rd_PSI]
		,[ISD_3rd_BHP]
		,[ISD_MaxRate]
		,[ISD_WB_Fric]
		,[ISD_NWB_Fric]
		,[ISD_Perf_Fric]
		,[ISD_T_Fric]
		,[ISD_Perfs_Open]
		,[ISD_Start_Rate]
		,[ISD_Start_PSI]
		,[ISD_Start_BHP]
		,[MaxN2Rate]
		,[Nitrogen_Vol]
		,[Pad_Injectivity]
		,[Pad_Inj_Start_BHP]
		,[Pad_Inj_End_BHP]
		,[Pad_Inj_Start_Rate]
		,[Pad_Inj_End_Rate]
		,[Pad_Inj_Start_Time]
		,[Pad_Inj_End_Time]
		,[Pad_Inj_Value]
		,[Sync_Offset]
		,[Sync_Wells]
		,[TotalBtmHoleFluid_Vol]
		
		/***** 20200413 ******/
		,[TotalPumpTime]
		,[DT_LOS]
		,[DT_3rd]
		,[Chems]
		,[Proppants]
		
		/***** 20200616 ******/
		,[ORP]
		,[Treated_pH]
		,[Untreated_pH]
		)

	SELECT xTS.[ID_FracInfo]
		, xTS.[ID_FracStage]

		, xTS.[Acid_Relief]
		, xTS.[AcidDisplaceRate]
		, xTS.[AveInj]
		, xTS.[AveN2Rate]
		, xTS.[BHN2Factor]
		, xTS.[FSD_1st_Rate]
		, xTS.[FSD_1st_PSI]
		, xTS.[FSD_1st_BHP]
		, xTS.[FSD_2nd_Rate]
		, xTS.[FSD_2nd_PSI]
		, xTS.[FSD_2nd_BHP]
		, xTS.[FSD_3rd_Rate]
		, xTS.[FSD_3rd_PSI]
		, xTS.[FSD_3rd_BHP]
		, xTS.[FSD_MaxRate]
		, xTS.[FSD_WB_Fric]
		, xTS.[FSD_NWB_Fric]
		, xTS.[FSD_Perf_Fric]
		, xTS.[FSD_T_Fric]
		, xTS.[FSD_Perfs_Open]
		, xTS.[FSD_StartRate]
		, xTS.[FSD_Start_PSI]
		, xTS.[FSD_Start_BHP]
		, xTS.[ISD_1st_Rate]
		, xTS.[ISD_1st_PSI]
		, xTS.[ISD_1st_BHP]
		, xTS.[ISD_2nd_Rate]
		, xTS.[ISD_2nd_PSI]
		, xTS.[ISD_2nd_BHP]
		, xTS.[ISD_3rd_Rate]
		, xTS.[ISD_3rd_PSI]
		, xTS.[ISD_3rd_BHP]
		, xTS.[ISD_MaxRate]
		, xTS.[ISD_WB_Fric]
		, xTS.[ISD_NWB_Fric]
		, xTS.[ISD_Perf_Fric]
		, xTS.[ISD_T_Fric]
		, xTS.[ISD_Perfs_Open]
		, xTS.[ISD_Start_Rate]
		, xTS.[ISD_Start_PSI]
		, xTS.[ISD_Start_BHP]
		, xTS.[MaxN2Rate]
		, xTS.[Nitrogen_Vol]
		, xTS.[Pad_Injectivity]
		, xTS.[Pad_Inj_Start_BHP]
		, xTS.[Pad_Inj_End_BHP]
		, xTS.[Pad_Inj_Start_Rate]
		, xTS.[Pad_Inj_End_Rate]
		, xTS.[Pad_Inj_Start_Time]
		, xTS.[Pad_Inj_End_Time]
		, xTS.[Pad_Inj_Value]
		, xTS.[Sync_Offset]
		, xTS.[Sync_Wells]
		, xTS.[TotalBtmHoleFluid_Vol]
		
		/***** 20200413 ******/
		, xTS.[TotalPumpTime]
		, xTS.[DT_LOS]
		, xTS.[DT_3rd]
		, xTS.[Chems]
		, xTS.[Proppants]
		
		/***** 20200616 ******/
		, xTS.[ORP]
		, xTS.[Treated_pH]
		, xTS.[Untreated_pH]
		
		FROM [SSIS_ENG].fnRPT_xmlTS_FracStages_TECHStudy()	xTS
			LEFT JOIN dbo.TechSheet_TECHStudy			eP ON (eP.ID_FracInfo = xTS.ID_FracInfo AND eP.ID_FracStage = xTS.ID_FracStage) 
		WHERE (xTS.ID_FracStage IS NOT NULL AND xTS.ID_FracInfo IS NOT NULL)
			AND eP.ID_Record IS NULL
	;

END 

GO
