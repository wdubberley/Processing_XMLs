USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_LAB_FlowLoop_Data_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******
  CREATED:	20190417 (KPHAM)
  MOdified:	
******/
CREATE PROCEDURE [SSIS_ENG].[Prepare_LAB_FlowLoop_Data_Insert]	
AS
BEGIN

	INSERT INTO [dbo].[LAB_FlowLoop_TestData]
		([ID_LabInfo],[ID_TestInfo],[SequenceNo]
		,[ElapsedTime_sec]
		,[Temperature_DegF]
		,[ThreeQuarterInRed_Percent]
		,[HalfInRed_Percent]
		,[FlowRate_GPM]
		,[DPhalfIn_PSI]
		,[VelocityHalfIn_FtPerSec]
		,[Calc_DPhalfIn_psi]
		,[VolFlowRate_GalPerMin]
		,[DP_per1000]
		,[Gamma])

	SELECT ID_LabInfo	= xFL.ID_LabInfo
		, ID_TestInfo	= xFL.ID_TestInfo
		, SequenceNo	= xFL.SequenceNo

		, ElapsedTime_sec	= xFL.ElapsedTime_sec
		, Temperature_DegF	= xFL.Temperature_DegF 
		, ThreeQuarterInRed_Percent = xFL.ThreeQuarterInRed_Percent
		, HalfInRed_Percent = xFL.HalfInRed_Percent
		, FlowRate_GPM		= xFL.FlowRate_GPM
		, DPhalfIn_psi		= xFL.DPhalfIn_psi
		, VelocityHalfIn_FtPerSec	= xFL.VelocityHalfIn_FtPerSec
		, Calc_DPhalfIn_psi			= xFL.Calc_DPhalfIn_psi
		, volFlowRate_GalPerMin		= xFL.volFlowRate_GalPerMin
		, DP_per1000	= xFL.DP_per1000
		, Gamma			= xFL.Gamma

		FROM [SSIS_ENG].[fnRPT_xmlLAB_FlowLoop_TestData] () xFL
			LEFT JOIN dbo.LAB_FlowLoop_TestData			dFL ON dFL.ID_TestInfo = xFL.ID_TestInfo AND dFL.SequenceNo = xFL.SequenceNo
		WHERE xFL.ID_TestInfo IS NOT NULL
			AND dFL.ID_TestData IS NULL
					
	;

END 


GO
