USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlLAB_HydrationTest_TestSpecs]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** 
  CREATED:	20180815 (KPHAM)
  Modified:	20190415- Added new columns; Changed join to xInfo by ID_Pad
******/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlLAB_HydrationTest_TestSpecs]()
RETURNS TABLE
AS
RETURN 
		
	SELECT ID_LabInfo	= xI.ID_LabInfo
		, TestNumber	= xH.TestNumber

		, ChandlerTestNo	= xH.ChandlerTestNumber
		, WASampleLocation	= xH.WASampleLocation

		, BobType		= xH.BobType
		, RotorType		= xH.RotorType
		, SpringFactor	= xH.SpringFactor
		, SpeedFactor	= xH.SpeedFactor
		, RotorBobFactor= xH.RotorBobFactor

		, TargetViscosity_cP	= xH.TargetViscosity_cP
		, InitialViscosity_cP	= xH.InitialViscosity_cP
		, InitialHydrationTime_min	= xH.InitialHydrationTime_min

		--, xWA.*
		, rowID		= ROW_NUMBER() OVER(ORDER BY xH.ID_RecordNo)
		, ID_Pad	= xI.ID_Pad
		, PadNumber	= xH.PadNumber
		
		FROM [SSIS_ENG].[xmlImport_LAB_HydrationTest_TestSpecs] xH
			INNER JOIN [SSIS_ENG].fnrpt_xmlLAB_Info() xI ON xI.ID_Pad = xH.ID_Pad 
	;
	
GO
