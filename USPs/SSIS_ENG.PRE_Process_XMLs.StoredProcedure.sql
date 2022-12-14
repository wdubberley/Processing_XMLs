USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[PRE_Process_XMLs]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***************************************************************************
  Created:	KPHAM
  20201030(v003)- Added MAT_FuelBOLs; Removed ALL CHEMs
  20201210(v004)- Changed call for SFX data to SSIS_ENG.fnSFX_Projects()
  20210228(v005)- Disable call to [SSIS_ENG].[PRE_Process_XMLs_PadNames]
  20210422(v006)- Added MAT_FuelSubstitution
***************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[PRE_Process_XMLs]	
	--@pID_Process	INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @vUserAction	AS VARCHAR(255) = 'Load XML data records'
		, @pID_Process		AS INT

	SELECT @pID_Process = [SSIS_ENG].[fnSSIS_GetProcess_START]()
	;

	WITH cteHistory (tNo, TableName, rCount) AS
		(/******************** TIMETRACKER *******************************************************************************/
		SELECT tNo=1, tName = 'SSIS_ENG.xmlImport_TT_TimeLogs', c = count(*) from SSIS_ENG.xmlImport_TT_TimeLogs

		/******************** TECHSHEETS *******************************************************************************/
		UNION 
		SELECT tNo=2, tName = 'SSIS_ENG.xmlImport_TS_FracInfo', c = count(*) from SSIS_ENG.xmlImport_TS_FracInfo
		UNION 
		SELECT tNo=3, tName = 'SSIS_ENG.xmlImport_TS_FracStages', c = count(*) from SSIS_ENG.xmlImport_TS_FracStages
		
		UNION 
		SELECT tNo=4, tName = 'SSIS_ENG.xmlImport_TS_FracChemicals', c = count(*) from SSIS_ENG.xmlImport_TS_FracChemicals
		UNION 
		SELECT tNo=5, tName = 'SSIS_ENG.xmlImport_TS_FracFluids', c = count(*) from SSIS_ENG.xmlImport_TS_FracFluids
		UNION 
		SELECT tNo=6, tName = 'SSIS_ENG.xmlImport_TS_FracProppants', c = count(*) from SSIS_ENG.xmlImport_TS_FracProppants

		/** ADDED 2016.11.29 **/
		UNION 
		SELECT tNo=7, tName = 'SSIS_ENG.xmlImport_TS_ChargesChems', c = count(*) from SSIS_ENG.xmlImport_TS_ChargesChems
		UNION 
		SELECT tNo=8, tName = 'SSIS_ENG.xmlImport_TS_ChargesProppants', c = count(*) from SSIS_ENG.xmlImport_TS_ChargesProppants
		UNION 
		SELECT tNo=9, tName = 'SSIS_ENG.xmlImport_TS_ChargesServices', c = count(*) from SSIS_ENG.xmlImport_TS_ChargesServices
		/** ADDED 2017.08.22 **/
		UNION 
		SELECT tNo=10, tName = 'SSIS_ENG.xmlImport_TS_ComparisonChemicals', c = count(*) FROM SSIS_ENG.xmlImport_TS_ComparisonChemicals
		UNION 
		SELECT tNo=11, tName = 'SSIS_ENG.xmlImport_TS_DiverterPressureAnalysis', c = count(*) FROM SSIS_ENG.xmlImport_TS_DiverterPressureAnalysis
		UNION 
		SELECT tNo=12, tName = 'SSIS_ENG.xmlImport_TS_FracStages_Columns', c = count(*) FROM SSIS_ENG.xmlImport_TS_FracStages_Columns

		/******************** FINAL TS *******************************************************************************/
		UNION 
		SELECT tNo=13, tName = 'SSIS_ENG.xmlImport_TS_Designs', c = count(*) from SSIS_ENG.xmlImport_TS_Designs
		UNION 
		SELECT tNo=14, tName = 'SSIS_ENG.xmlImport_TS_Designs_ChemSP', c = count(*) from SSIS_ENG.xmlImport_TS_Designs_ChemSP
		UNION 
		SELECT tNo=15, tName = 'SSIS_ENG.xmlImport_TS_ChemTotals', c = count(*) from SSIS_ENG.xmlImport_TS_ChemTotals

		/******************** FINAL TICKETs/QUOTEs/SURVEYs ***************************************************************************/
		UNION 
		SELECT tNo=16, tName = 'SSIS_ENG.xmlImport_TS_FracTickets', c = count(*) from SSIS_ENG.xmlImport_TS_FracTickets
		UNION 
		SELECT tNo=17, tName = 'SSIS_ENG.xmlImport_TS_FracQuotes', c = count(*) from SSIS_ENG.xmlImport_TS_FracQuotes
		UNION 
		SELECT tNo=18, tName = 'SSIS_ENG.xmlImport_CustomerSurveys', c = count(*) from SSIS_ENG.xmlImport_CustomerSurveys

		/******************** MATERIAL TRACKER *******************************************************************************/
		UNION 
		SELECT tNo=19, tName = 'SSIS_ENG.xmlImport_MAT_Info', c = count(*) from SSIS_ENG.xmlImport_MAT_Info
		UNION 
		SELECT tNo=20, tName = 'SSIS_ENG.xmlImport_MAT_SandInfo', c = count(*) from SSIS_ENG.xmlImport_MAT_SandInfo
		UNION 
		SELECT tNo=21, tName = 'SSIS_ENG.xmlImport_MAT_BOLDetails', c = count(*) from SSIS_ENG.xmlImport_MAT_BOLDetails
		UNION 
		SELECT tNo=22, tName = 'SSIS_ENG.xmlImport_MAT_SandTrends', c = count(*) from SSIS_ENG.xmlImport_MAT_SandTrends
		UNION 
		SELECT tNo=23, tName = 'SSIS_ENG.xmlImport_MAT_FuelBOLs', c = count(*) from SSIS_ENG.xmlImport_MAT_FuelBOLs
		/** ADDED 20210422 **/
		UNION 
		SELECT tNo=24, tName = 'SSIS_ENG.xmlImport_MAT_FuelSubstitution', c = count(*) from SSIS_ENG.xmlImport_MAT_FuelSubstitution
		
		/******************** CHEMICAL INVENTORY REMOVED 20201031 ********************************************************************
		UNION 
		SELECT tNo=23, tName = 'SSIS_ENG.xmlImport_CHEM_InventoryInfo', c = count(*) from SSIS_ENG.xmlImport_CHEM_Info
		UNION 
		SELECT tNo=24, tName = 'SSIS_ENG.xmlImport_CHEM_BOLs', c = count(*) from SSIS_ENG.xmlImport_CHEM_BOLs
		UNION 
		SELECT tNo=25, tName = 'SSIS_ENG.xmlImport_CHEM_Entries', c = count(*) from SSIS_ENG.xmlImport_CHEM_ChemEntries
		UNION 
		SELECT tNo=26, tName = 'SSIS_ENG.xmlImport_CHEM_AcidTickets', c = count(*) from SSIS_ENG.xmlImport_CHEM_AcidTickets
		UNION 
		SELECT tNo=27, tName = 'SSIS_ENG.xmlImport_CHEM_TicketLocations', c = count(*) from SSIS_ENG.xmlImport_CHEM_TicketLocation
		UNION 
		SELECT tNo=28, tName = 'SSIS_ENG.xmlImport_CHEM_TicketEntries', c = count(*) from SSIS_ENG.xmlImport_CHEM_TicketEntries
		UNION 
		SELECT tNo=29, tName = 'SSIS_ENG.xmlImport_CHEM_FuelBOLs', c = count(*) from SSIS_ENG.xmlImport_CHEM_FuelBOLs
		UNION 
		SELECT tNo=30, tName = 'SSIS_ENG.xmlImport_CHEM_LocationStraps', c = count(*) from SSIS_ENG.xmlImport_CHEM_LocationStraps
		***********************************************************************************************************************/
		
		/******************** LOCATION Strap (LCS) (20180906) *************************************************************************/
		UNION 
		SELECT tNo=31, tName = 'SSIS_ENG.xmlImport_LCS_Info', c = count(*) from SSIS_ENG.xmlImport_LCS_Info
		UNION 
		SELECT tNo=32, tName = 'SSIS_ENG.xmlImport_LCS_ChemicalStraps', c = count(*) from SSIS_ENG.xmlImport_LCS_ChemicalStraps
		UNION 
		SELECT tNo=33, tName = 'SSIS_ENG.xmlImport_LCS_TicketChemEntries', c = count(*) from SSIS_ENG.xmlImport_LCS_TicketChemEntries
		
		/******************** LabTests (LAB) (20180913) *******************************************************************************/
		UNION 
		SELECT tNo=34, tName = 'SSIS_ENG.xmlImport_LAB_Info', c = count(*) from SSIS_ENG.xmlImport_LAB_Info
		UNION 
		SELECT tNo=35, tName = 'SSIS_ENG.xmlImport_LAB_WellInfo', c = count(*) from SSIS_ENG.xmlImport_LAB_WellInfo
		UNION 
		SELECT tNo=36, tName = 'SSIS_ENG.xmlImport_LAB_MicrobeTesting_SampleCollection', c = count(*) from SSIS_ENG.xmlImport_LAB_MicrobeTesting_SampleCollection
		UNION 
		SELECT tNo=37, tName = 'SSIS_ENG.xmlImport_LAB_WaterAnalysis_SampleData', c = count(*) from SSIS_ENG.xmlImport_LAB_WaterAnalysis_SampleData
		UNION 
		SELECT tNo=38, tName = 'SSIS_ENG.xmlImport_LAB_HydrationTest_TestSpecs', c = count(*) from SSIS_ENG.xmlImport_LAB_HydrationTest_TestSpecs
		UNION 
		SELECT tNo=39, tName = 'SSIS_ENG.xmlImport_LAB_HydrationTest_ChemInfo', c = count(*) from SSIS_ENG.xmlImport_LAB_HydrationTest_ChemInfo
		UNION 
		SELECT tNo=40, tName = 'SSIS_ENG.xmlImport_LAB_HydrationTest_TestData', c = count(*) from SSIS_ENG.xmlImport_LAB_HydrationTest_TestData
		UNION 
		SELECT tNo=41, tName = 'SSIS_ENG.xmlImport_LAB_ChandlerTest_TestSpecs', c = count(*) from SSIS_ENG.xmlImport_LAB_ChandlerTest_TestSpecs
		UNION 
		SELECT tNo=42, tName = 'SSIS_ENG.xmlImport_LAB_ChandlerTest_ChemInfo', c = count(*) from SSIS_ENG.xmlImport_LAB_ChandlerTest_ChemInfo
		UNION 
		SELECT tNo=43, tName = 'SSIS_ENG.xmlImport_LAB_ChandlerTest_TestData', c = count(*) from SSIS_ENG.xmlImport_LAB_ChandlerTest_TestData
		UNION 
		SELECT tNo=44, tName = 'SSIS_ENG.xmlImport_LAB_FlowLoop_ChemInfo', c = count(*) from SSIS_ENG.xmlImport_LAB_FlowLoop_ChemInfo
		UNION 
		SELECT tNo=45, tName = 'SSIS_ENG.xmlImport_LAB_FlowLoop_TestData', c = count(*) from SSIS_ENG.xmlImport_LAB_FlowLoop_TestData
		UNION 
		SELECT tNo=46, tName = 'SSIS_ENG.xmlImport_LAB_ShearStress_TestSpecs', c = count(*) from SSIS_ENG.xmlImport_LAB_ShearStress_TestSpecs
		UNION 
		SELECT tNo=47, tName = 'SSIS_ENG.xmlImport_LAB_ShearStress_ChemInfo', c = count(*) from SSIS_ENG.xmlImport_LAB_ShearStress_ChemInfo
		UNION 
		SELECT tNo=48, tName = 'SSIS_ENG.xmlImport_LAB_ShearStress_ViscData', c = count(*) from SSIS_ENG.xmlImport_LAB_ShearStress_ViscData
		UNION 
		SELECT tNo=49, tName = 'SSIS_ENG.xmlImport_LAB_OscillatingRheometer_TestData', c = count(*) from SSIS_ENG.xmlImport_LAB_OscillatingRheometer_TestData
		
		/******************** Salesforce Data dump (SFX) (20201210) *******************************************************************************/
		UNION 
		SELECT tNo=50, tName = 'SSIS_ENG.fnSFX_Projects()', c = count(*) FROM [SSIS_ENG].[fnSFX_Projects]()
		--UNION 
		--SELECT tNo=51, tName = 'SSIS_ENG.importXLS_BOC', c = count(*) from SSIS_ENG.importXLS_BOC
		
		)

	INSERT INTO [SSIS_ENG].[ref_UserHistory]
		(TableName, UserAction, RecordDetail, UserID, ID_Parent)
	SELECT TableName, @vUserAction, rCount, ORIGINAL_LOGIN(), @pID_Process
		FROM cteHistory
		WHERE rCount > 0
		ORDER BY tNo

	/*************** QUICK CLEAN UP OF DATA BEFORE PROCESSING 
		*** NOT tracked in History log ***
	**********************************/
	--EXEC [Liberty].[SSIS].[Prepare_XMLs_Formations]			-- UPDATE Formations for OLD XMLs /ONLY OLD XMLs/
	
	--EXEC [SSIS_ENG].[PRE_Process_XMLs_PadNames]	
	----EXEC [SSIS_ENG].[PRE_Process_XMLs_PadNames_2016]			/*20180806-ONLY For reupload of 2016 */

	EXEC [SSIS_ENG].[PRE_Process_XMLs_Dates]	

	EXEC [SSIS_ENG].[PRE_Process_XMLs_MAT_Misc]					/*20180212*/

	--EXEC [SSIS_ENG].[PRE_Process_XMLs_CHEM_Corrections]			/*20180510*/

	SET NOCOUNT OFF;

END 


GO
