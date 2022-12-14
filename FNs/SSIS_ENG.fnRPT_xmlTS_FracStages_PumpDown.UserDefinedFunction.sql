USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlTS_FracStages_PumpDown]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***********************************************************************************
  Created:	20200326 (KPHAM)
  Desc:		Section to pull only PumpDown data out of xmlTS_FracStage
************************************************************************************/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlTS_FracStages_PumpDown]()
RETURNS TABLE
AS
RETURN 

	SELECT ID_FracInfo	= sCTE.ID_FracInfo
		, ID_FracStage	= sCTE.ID_FracStage
		
		, Ball_Final
		, Ball_Initial
		, Ball_Max
		, Ball_Rate
		, BallAction
		, BallDropVol
		, BallHit_Diff
		, BallHitTime
		, BallHitVol
		, BallSize
		, Bottom_Shot_Flush_Vol_bbl
		, Bottom_Shot_Flush_Vol_Gal
		, BottomShot
		, Communication_DeltaPSI
		, Communication_Duration
		, Communication_End_Time
		, Communication_Start_Time
		, Delta_psi
		, DeltaBS
		, DeltaPD
		, DeltaTS
		, Design_BS
		, Design_PD
		, Design_TS
		, EndWLTime
		, NumPerfsPorts
		, PD_Brinebbls
		, PD_CloseWHPSI
		, PD_CloseWHTime
		, PD_Company
		, PD_EndTime
		, PD_Equipment
		, PD_Freshbbls
		, PD_MeterType
		, PD_NumHP
		, PD_OpenWHPSI
		, PD_OpenWHTime
		, PD_PressureMax
		, PD_RateMax
		, PD_StartTime
		, PERF_BottomShot
		, PERF_ClusterLength
		, PERF_Company
		, PERF_NumPerfClusters
		, PERF_PerfDiam
		, PERF_Phasing
		, PERF_PlugDepth
		, PERF_ShotPerFoot
		, PERF_TopShot
		, PERF_TotalNumShots
		, PERF_Type
		, PerfDiam
		, Plug
		, Plug_Flush_Vol_bbl
		, Plug_Flush_Vol_Gal
		, PlugBall_Early_Late
		, PortPerf
		, PumpDownVol
		, Sleeve_Depth1
		, Sleeve1_Early_Late
		, Sleeve1_Flush_Vol_bbl
		, Sleeve1_Flush_Vol_Gal
		, SleeveDepth1
		, StartWLTime
		, Top_Shot_Flush_Vol_bbl
		, Top_Shot_Flush_Vol_Gal
		, TopShot
		, Tot_Clean_PD
		, TotalnumPerfs
		, WL_Communication
		, WL_Well
		, WLDate
		, WLPumpTime
		, WLWAHHPAveRatePSIMethod

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
