USE [FieldData]
GO
/****** Object:  View [SSIS_ENG].[vw_LAB_TestInfos]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******
  Created:	KPHAM
  Modified:	20190417- Added FlowLoop, ShearStress (OR)
******/
CREATE VIEW [SSIS_ENG].[vw_LAB_TestInfos] 
AS
		
	SELECT ID_LabInfo	= xH.ID_LabInfo
		, ID_TestInfo	= sH.ID_TestInfo		/* ID_TestSpecs */
		, ID_TestType	= 87
		, TestNumber	= xH.TestNumber
		, PadNumber		= xH.PadNumber
		, ID_Pad		= xH.ID_Pad

		FROM [SSIS_ENG].[fnRPT_xmlLAB_HydrationTest_TestSpecs]()xH
			INNER JOIN dbo.LAB_HydrationTest_TestSpecs		sH ON sH.ID_LabInfo = xH.ID_LabInfo AND sH.TestNumber = xH.TestNumber
			--INNER JOIN c_LabInfo							i ON i.ID_LabInfo = sH.ID_LabInfo
	UNION 
	SELECT ID_LabInfo	= xC.ID_LabInfo
		, ID_TestInfo	= sC.ID_TestInfo
		, ID_TestType	= 88
		, TestNumber	= xC.TestNumber
		, PadNumber		= xC.PadNumber
		, ID_Pad		= xC.ID_Pad

		FROM [SSIS_ENG].[fnRPT_xmlLAB_ChandlerTest_TestSpecs]()	xC
			INNER JOIN dbo.LAB_ChandlerTest_TestSpecs		sC ON sC.ID_LabInfo = xC.ID_LabInfo AND sC.TestNumber = xC.TestNumber
			--INNER JOIN c_LabInfo							i ON i.ID_LabInfo = sC.ID_LabInfo

	UNION 
	SELECT ID_LabInfo	= xFL.ID_LabInfo
		, ID_TestInfo	= sFL.ID_TestInfo
		, ID_TestType	= 98
		, TestNumber	= xFL.TestNumber
		, PadNumber		= xFL.PadNumber
		, ID_Pad		= xFL.ID_Pad

		FROM [SSIS_ENG].[fnRPT_xmlLAB_FlowLoop_TestSpecs]() xFL
			INNER JOIN dbo.LAB_FlowLoop_TestSpecs		sFL ON sFL.ID_LabInfo = xFL.ID_LabInfo AND sFL.TestNumber = xFL.TestNumber
			--INNER JOIN c_LabInfo						i ON i.ID_LabInfo = sFL.ID_LabInfo

	UNION 
	SELECT ID_LabInfo	= xSS.ID_LabInfo
		, ID_TestInfo	= dSS.ID_TestInfo
		, ID_TestType	= 99
		, TestNumber	= xSS.TestNumber
		, PadNumber		= xSS.PadNumber
		, ID_Pad		= xSS.ID_Pad

		FROM [SSIS_ENG].[fnRPT_xmlLAB_ShearStress_TestSpecs]() xSS
			INNER JOIN dbo.LAB_ShearStress_TestSpecs	dSS ON dSS.ID_LabInfo = xSS.ID_LabInfo AND dSS.TestNumber = xSS.TestNumber

GO
