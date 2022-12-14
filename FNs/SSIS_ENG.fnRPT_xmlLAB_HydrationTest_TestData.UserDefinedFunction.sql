USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlLAB_HydrationTest_TestData]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******
  CREATED:	20180816 (KPHAM)
  Modified:	20190416- Add new columns; Modified join match by ID_Pad and TestNumber
******/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlLAB_HydrationTest_TestData]()
RETURNS TABLE
AS
RETURN 
	
	SELECT ID_LabInfo	= xT.ID_LabInfo
		, ID_TestInfo	= xT.ID_TestInfo
		
		, ChandlerTestNo= xD.ChandlerTestNumber
		, TestName		= xD.HydrationTestName

		, HydrationTimeMin			= xD.HydrationTimeMin
		, HydrationViscositycP		= xD.[HydrationViscositycP]
		, HydrationTemperatureDegF	= xD.HydrationTemperatureDegF
		, HydrationDegFann			= xD.HydrationDegFann
		
		, rowID			= ROW_NUMBER() OVER(ORDER BY xT.ID_LabInfo, xT.ID_TestInfo, xD.ID_RecordNo)
		, ID_Pad		= xT.ID_Pad
		, PadNumber		= xD.PadNumber
		, TestNumber	= xD.TestNumber
		
		FROM [SSIS_ENG].[xmlImport_LAB_HydrationTest_TestData] xD
			INNER JOIN [SSIS_ENG].[vw_LAB_TestInfos] xT 
				ON xT.ID_TestType = 87 AND xT.ID_Pad = xD.ID_Pad AND xT.TestNumber = xD.TestNumber

	;

GO
