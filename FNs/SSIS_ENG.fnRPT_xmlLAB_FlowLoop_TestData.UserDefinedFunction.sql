USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlLAB_FlowLoop_TestData]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** 
  CREATED:	20190417 (KPHAM)
******/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlLAB_FlowLoop_TestData]()
RETURNS TABLE
AS
RETURN 
	
	SELECT ID_LabInfo	= vI.ID_LabInfo
		, ID_TestInfo	= vI.ID_TestInfo

		, SequenceNo		= xFT.[FlowLoopOrder]
		, ElapsedTime_sec	= xFT.[ElapsedTimeSec]
		, Temperature_DegF	= xFT.[FLTemperatureDegF] 
		, ThreeQuarterInRed_Percent =	xFT.[ThreeQuarterInRedPercent]
		, HalfInRed_Percent = xFT.[HalfInRedPercent]
		, FlowRate_GPM		= xFT.[FlowRateGPM]
		, DPhalfIn_psi		= xFT.[DPhalfInPSI]
		, VelocityHalfIn_FtPerSec	= xFT.[VelocityHalfInFtPerSec]
		, Calc_DPhalfIn_psi			= xFT.[CalcDPhalfInPSI]
		, volFlowRate_GalPerMin		= xFT.[VolFlowRateGalPerMin]
		, DP_per1000	= xFT.[DPper1000]
		, Gamma			= xFT.[Gamma]

		,[ID_Record]	= xFT.ID_Record
		,[ID_Pad]		= vI.ID_Pad
		,[PadNumber]	= vI.PadNumber
		,[TestNumber]	= xFT.[FlowLoopTestNumber]
	 
	FROM [SSIS_ENG].[xmlImport_LAB_FlowLoop_TestData]	xFT
		INNER JOIN [SSIS_ENG].vw_LAB_TestInfos			vI ON vI.ID_Pad = xFT.ID_Pad AND vI.TestNumber = xFT.FlowLoopTestNumber
		--INNER JOIN [SSIS_ENG].fnrpt_xmlLAB_Info()		xI ON xI.ID_Pad = xFT.ID_Pad

	;
	
GO
