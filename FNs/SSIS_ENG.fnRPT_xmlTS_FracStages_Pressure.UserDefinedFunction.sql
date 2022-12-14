USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlTS_FracStages_Pressure]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***********************************************************************************
  Created:	20200325 (KPHAM)
  Desc:		Section to pull only Pressure data out of xmlTS_FracStage
************************************************************************************/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlTS_FracStages_Pressure]()
RETURNS TABLE
AS
RETURN 

	SELECT ID_FracInfo	= sCTE.ID_FracInfo
		, ID_FracStage	= sCTE.ID_FracStage
		
		, AveBacksidePSI
		, AveBHPSI
		, AveCoilPSI
		, AveSurfacePSI
		, BD_Psi
		, BD_Rate
		, F_10Min
		, F_15Min
		, F_1Min
		, F_2Min
		, F_5Min
		, F_BHISIP
		, F_FG
		, F_ISIP
		, FSD_1st_WB_Fric
		, FSD_2nd_WB_Fric
		, FSD_3rd_WB_Fric
		, GlobalTrips
		, I_10Min
		, I_15Min
		, I_1Min
		, I_2Min
		, I_5Min
		, I_BHISIP
		, I_FG
		, I_ISIP
		, ISD_1st_WB_Fric
		, ISD_2nd_WB_Fric
		, ISD_3rd_WB_Fric
		, MaxBacksidePSI
		, MaxBHPSI
		, MaxCoilPSI
		, MaxFlushPSI
		, MaxSurfacePSI
		, MaxWorkingPSI
		, MinBacksidePSI
		, MinCoilPSI
		, MinSurfacePSI
		, Open_WH_Backside_PSI
		, PopOffSet_H
		, PopOffSet_L
		, PressureTestPsi
		, TVD 

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
