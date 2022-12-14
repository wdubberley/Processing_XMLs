USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlLAB_ChandlerTest_TestSpecs]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** 
  CREATED:	20180815 (KPHAM)
  Modified:	20190416- Added new columsn; Changed join to map with ID_Pad
******/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlLAB_ChandlerTest_TestSpecs] ()
RETURNS TABLE
AS
RETURN 
		
	SELECT ID_LabInfo	= xI.ID_LabInfo

		, TestNumber		= ISNULL(xC.ChandlerTestNumber, xC.TestNumber)
		, HydrationTestNo	= xC.HydrationTestNumber
		, WASampleLocation	= xC.WASampleLocation
		
		, Temperature		= xC.Temperature
		, TemperatureRamp	= xC.TemperatureRamp
		, BobSize			= xC.BobSize
		, ShearRatePerSecond= xC.ShearRatePerSecond
		, APIShearScan		= xC.APIShearScan
		, TargetViscositycP	= xC.TargetViscositycP
		, InitialViscositycP= xC.InitalViscositycP
		, InitialHydrationTimeMin	= xC.InitialHydrationTimeMin
		, BaseFluidpH		= xC.BaseFluidpH
		, BufferedFluidpH	= xC.BufferedFluidpH
		, XLinkpH			= xC.XLinkpH
		
		, rowID		= ROW_NUMBER() OVER(ORDER BY xC.ID_RecordNo)
		, ID_Pad	= xI.ID_Pad
		, PadNumber	= xC.PadNumber
		
		/* Obsolete columns */
		, WaterSource	= xC.WaterSource
		, EndpH			= xC.EndpH
		
		FROM [SSIS_ENG].[xmlImport_LAB_ChandlerTest_TestSpecs]	xC
			INNER JOIN [SSIS_ENG].fnrpt_xmlLAB_Info()			xI ON xI.ID_Pad = xC.ID_Pad

	;

GO
