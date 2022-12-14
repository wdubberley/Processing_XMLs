USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlTS_FracStages_TECHStudy]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***********************************************************************************
  Created:	20200326 (KPHAM)
  Desc:		Section to pull only TECHStudy data out of xmlTS_FracStage
  20200413(v002)- Added TotalPumpTime, DT_LOS, DT_3rd, Chems, Proppants
  20200616(v003)- Added ORP, Treated_pH, Untreated_pH
************************************************************************************/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlTS_FracStages_TECHStudy]()
RETURNS TABLE
AS
RETURN 

	SELECT ID_FracInfo	= sCTE.ID_FracInfo
		, ID_FracStage	= sCTE.ID_FracStage
		
		, Acid_Relief
		, AcidDisplaceRate
		, AveInj
		, AveN2Rate
		, BHN2Factor
		, FSD_1st_Rate
		, FSD_1st_PSI
		, FSD_1st_BHP
		, FSD_2nd_Rate
		, FSD_2nd_PSI
		, FSD_2nd_BHP
		, FSD_3rd_Rate
		, FSD_3rd_PSI
		, FSD_3rd_BHP
		, FSD_MaxRate
		, FSD_WB_Fric
		, FSD_NWB_Fric
		, FSD_Perf_Fric
		, FSD_T_Fric
		, FSD_Perfs_Open
		, FSD_StartRate
		, FSD_Start_PSI
		, FSD_Start_BHP
		, ISD_1st_Rate
		, ISD_1st_PSI
		, ISD_1st_BHP
		, ISD_2nd_Rate
		, ISD_2nd_PSI
		, ISD_2nd_BHP
		, ISD_3rd_Rate
		, ISD_3rd_PSI
		, ISD_3rd_BHP
		, ISD_MaxRate
		, ISD_WB_Fric
		, ISD_NWB_Fric
		, ISD_Perf_Fric
		, ISD_T_Fric
		, ISD_Perfs_Open
		, ISD_Start_Rate
		, ISD_Start_PSI
		, ISD_Start_BHP
		, MaxN2Rate
		, Nitrogen_Vol
		, Pad_Injectivity
		, Pad_Inj_Start_BHP
		, Pad_Inj_End_BHP
		, Pad_Inj_Start_Rate
		, Pad_Inj_End_Rate
		, Pad_Inj_Start_Time
		, Pad_Inj_End_Time
		, Pad_Inj_Value
		, Sync_Offset
		, Sync_Wells
		, TotalBtmHoleFluid_Vol

		/****** 20200413 *******/
		, TotalPumpTime
		, DT_LOS	= LOSDT
		, DT_3rd	= [3rdDT]
		, Chems		= Chems
		, Proppants = Proppants

		/****** 20200616 *******/
		, ORP			= [ORP]
		, Treated_pH	= [Treated_pH]
		, Untreated_pH	= [Untreated_pH]
		
		, WellName	= xS.WellName
		, StageNo	= xS.Stage
		, FileDate	= xS.FileDate
		, FilePath	= xS.FilePath

		FROM [SSIS_ENG].xmlImport_TS_FracStages xS 
			INNER JOIN [SSIS_ENG].vw_FracStages_Header	sCTE ON sCTE.WellName = xS.WellName
															AND sCTE.StageNo = xS.Stage 
															AND sCTE.FilePath= xS.FilePath

	;

GO
