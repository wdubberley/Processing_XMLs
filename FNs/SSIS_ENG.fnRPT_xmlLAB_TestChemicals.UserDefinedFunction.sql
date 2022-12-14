USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlLAB_TestChemicals]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************
  CREATED:	20180816 (KPHAM)
  Modified:	20190417- Added Temperature, ID_RelatedTest, RelatedTestNo;
					- Add FlowLoop section; Add ShearStress section
***************************************************************************/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlLAB_TestChemicals]()
RETURNS TABLE
AS
RETURN 
		
	WITH cte_ChemInfo AS
		(SELECT ID_Record	= xHC.[ID_RecordNo]
			,[ID_Pad]
			,[PadNumber]
			,[TestNumber]	= xHC.TestNumber
			,[AdditiveType]
			,[AdditiveName]
			,[SPUnit]
			,[ChemicalSP]
			,[Temperature]	= NULL

			,ID_TestType	= 87
			,ID_RelatedTest	= 88
			,RelatedTestNo	= ChandlerTestNumber

			FROM [SSIS_ENG].[xmlImport_LAB_HydrationTest_ChemInfo] xHC

		UNION ALL
		SELECT ID_Record	= xC.[ID_RecordNo]
			,[ID_Pad]
			,[PadNumber]
			,[TestNumber]	= ISNULL(xC.ChandlerTestNumber, CONVERT(NVARCHAR(100), xC.TestNumber))
			,[AdditiveType]
			,[AdditiveName]
			,[SPUnit]
			,[ChemicalSP]
			,[Temperature]	= NULL

			,ID_TestType = 88
			,ID_RelatedTest	= 87
			,RelatedTestNo	= HydrationTestNumber

			FROM [SSIS_ENG].[xmlImport_LAB_ChandlerTest_ChemInfo] xC

		/* 20190417 */
		UNION ALL
		SELECT ID_Record	= xFL.[ID_Record]
			,[ID_Pad]
			,[PadNumber]
			,[TestNumber]	= xFL.FlowLoopTestNumber
			,[AdditiveType]
			,[AdditiveName]
			,[SPUnit]
			,[ChemicalSP]
			
			,[Temperature]	= NULL
			,ID_TestType	= 98
			,ID_RelatedTest	= 96
			,RelatedTestNo	= WASampleLocation

			FROM [SSIS_ENG].[xmlImport_LAB_FlowLoop_ChemInfo] xFL

		--/* 20190417 */
		UNION ALL
		SELECT ID_Record	= xSS.[ID_Record]
			,[ID_Pad]
			,[PadNumber]
			,[TestNumber]	= CONVERT(NVARCHAR(100),xSS.OscillatingRheometerTestNumber)
			,[AdditiveType]
			,[AdditiveName]
			,[SPUnit]
			,[ChemicalSP]
			
			,[Temperature]	= [Temperature]
			,ID_TestType	= 99
			,ID_RelatedTest	= 101					/* Shear Stress Performance */
			,RelatedTestNo	= CONVERT(NVARCHAR(100),xSS.ID_Performance)

			FROM [SSIS_ENG].[xmlImport_LAB_ShearStress_ChemInfo] xSS
		)

	--select * from cte_ChemInfo x

	SELECT ID_LabInfo	= xT.ID_LabInfo
		, ID_TestType	= xT.ID_TestType
		, ID_TestInfo	= xT.ID_TestInfo
		, ID_Chemical	= rC.ID_Chemical

		, AdditiveType	= xC.AdditiveType
		, AdditiveName	= xC.AdditiveName
		, SPUnit		= xC.SPUnit
		, ChemicalSP	= xC.ChemicalSP
		, Temperature	= xC.Temperature

		, ID_RelatedTest	= xC.ID_RelatedTest
		, RelatedTestNo		= xC.RelatedTestNo

		, rowID			= ROW_NUMBER() OVER(ORDER BY xT.ID_LabInfo, xT.ID_TestType, xC.ID_Record)
		, ID_Pad		= xT.ID_Pad
		, PadNumber		= xC.PadNumber
		, TestNumber	= xC.TestNumber

		FROM cte_ChemInfo xC
			INNER JOIN [SSIS_ENG].[vw_LAB_TestInfos]	xT ON xT.ID_Pad = xC.ID_Pad AND xT.ID_TestType = xC.ID_TestType AND xT.TestNumber = xC.TestNumber --AND xT.
			INNER JOIN [dbo].[LOS_Chemicals]		rC ON rC.ChemicalName = xC.AdditiveName

	;
	
GO
