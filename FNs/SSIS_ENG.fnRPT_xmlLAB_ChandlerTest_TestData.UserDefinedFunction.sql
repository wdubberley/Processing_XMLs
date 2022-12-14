USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlLAB_ChandlerTest_TestData]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** 
 CREATED:	20180816 
 Modified:	20190421- Added HydrationTestNo
******/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlLAB_ChandlerTest_TestData]()
RETURNS TABLE
AS
RETURN 
	
	SELECT ID_LabInfo	= xT.ID_LabInfo
		, ID_TestInfo	= xT.ID_TestInfo
		
		, HydrationTestNo	= xD.HydrationTestNumber

		, SequenceNo		= xD.ChandlerTimeOrder
		, ElapsedTimeSec	= xD.ElapsedTimeSec
		, Viscosity			= xD.Viscosity
		, Temperature		= xD.Temperature
		
		, rowID		= ROW_NUMBER() OVER(ORDER BY xT.ID_LabInfo, xT.ID_TestInfo, xD.ID_RecordNo)
		, ID_Pad	= xT.ID_Pad
		, TestNumber= ISNULL(xD.ChandlerTestNumber, xD.TestNumber)
		
		, PadNumber	= xD.PadNumber
		
		FROM [SSIS_ENG].[xmlImport_LAB_ChandlerTest_TestData] xD
			INNER JOIN [SSIS_ENG].[vw_LAB_TestInfos] xT 
				ON xT.ID_TestType = 88 AND xT.ID_Pad = xD.ID_Pad AND xT.TestNumber = ISNULL(xD.ChandlerTestNumber, xD.TestNumber)

	;

GO
