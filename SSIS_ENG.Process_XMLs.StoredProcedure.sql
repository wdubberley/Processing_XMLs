USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Process_XMLs]    Script Date: 8/24/2022 11:08:32 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*************************************************************************************
  Created:	KPHAM
  20201022(v005)- Added call to [SSIS_ENG].[Prepare_UPT_Terminations]
  20201026(v006)- Added [Prepare_XLS]
  20201030(v008)- Added MAT_FuelBOLs
  20210104(v009)- Changed call to [SSIS_ENG].[Prepare_MAT_BOLDetail]
  20210422(v010)- Added MAT_FuelSubstitution
  20210429(v011)- Added TS_FracInvoice
  20211219(v012)- Disabled LABs
**************************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Process_XMLs]	
AS
BEGIN
	SET NOCOUNT ON;
	
	/******* ONLY USE THIS TO Start Manual processing ********************/
	--EXECUTE [SSIS_ENG].[uspREF_History_Insert] 'SSIS_ENG.ref_UserHistory','Processing XMLs','START - SSIS'	

	EXEC [History].[usp_History_XMLLogs_Start]

	EXEC [SSIS_ENG].[PRE_Process_XMLs] 						

	/******* CREATE REFs records ********************/
	EXEC [SSIS_ENG].[PRE_REF_Operator]
	EXEC [SSIS_ENG].[PRE_REF_Categories]
	EXEC [SSIS_ENG].[PRE_REF_Employees]
	EXEC [SSIS_ENG].[PRE_REF_Representatives]

	EXEC [SSIS_ENG].[PRE_REF_TimeEventsTypes]

	EXEC [SSIS_ENG].[PRE_REF_Units]		
	EXEC [SSIS_ENG].[PRE_REF_Chemicals]		
	EXEC [SSIS_ENG].[PRE_REF_Proppants]
	EXEC [SSIS_ENG].[PRE_REF_Fluids]
	EXEC [SSIS_ENG].[PRE_REF_ChargeServices]
	EXEC [SSIS_ENG].[PRE_REF_DesignStageTypes]
	
	EXEC [SSIS_ENG].[SFX_Projects_Distribution]	/* temporarily turning off 20220301 */
	
	/******* START FRAC data ********************/
	EXEC [SSIS_ENG].[Prepare_Pads]
	EXEC [SSIS_ENG].[Prepare_LOS_Wells]

	EXEC [SSIS_ENG].[PRE_Process_SSIS_Cleanup]

	EXEC [SSIS_ENG].[Prepare_TT_FracTime]
	EXEC [SSIS_ENG].[XML_QC_TT_OffPad]

	IF (SELECT COUNT(*) FROM SSIS_ENG.xmlImport_TS_FracInfo) > 0
	BEGIN
		EXEC [SSIS_ENG].[Prepare_TS_FracInfo]
		EXEC [SSIS_ENG].[Prepare_TS_FracContact_Insert]

		EXEC [SSIS_ENG].[Prepare_TS_QuoteItem]

		EXEC [SSIS_ENG].[Prepare_TS_FracStage]

		EXEC [SSIS_ENG].[Prepare_TS_FracChem]
		EXEC [SSIS_ENG].[Prepare_TS_FracProppant]
		EXEC [SSIS_ENG].[Prepare_TS_FracFluid]

		EXEC [SSIS_ENG].[Prepare_TS_ChargeService]
		EXEC [SSIS_ENG].[Prepare_TS_ChargeChemical]
		EXEC [SSIS_ENG].[Prepare_TS_ChargeProppant]

		EXEC [SSIS_ENG].[Prepare_TS_CompareChemicals]
		EXEC [SSIS_ENG].[Prepare_TS_DiverterPressure]
		
		EXEC [SSIS_ENG].[Prepare_TS_FracChem3rdParty]
		EXEC [SSIS_ENG].[Prepare_TS_Pressure]				/*20200331*/	
		EXEC [SSIS_ENG].[Prepare_TS_PumpDown]				/*20200331*/	
		EXEC [SSIS_ENG].[Prepare_TS_TECHStudy]				/*20200331*/

		EXEC [SSIS_ENG].[Prepare_TS_FracDesign]
		EXEC [SSIS_ENG].[Prepare_TS_FracChemSP]
		EXEC [SSIS_ENG].[Prepare_TS_FracChemTotal]

		EXEC [SSIS_ENG].[Prepare_TS_FracInvoice]			/* 20210429 */
	END

	IF (SELECT COUNT(*) FROM SSIS_ENG.xmlImport_TS_FracTickets) > 0
	BEGIN
		EXEC [SSIS_ENG].[Prepare_TQ_TicketItem]				/* 20200213 */

		/**** ADDITIONAL STUFFS *****/
		EXEC [SSIS_ENG].[usp_Prepare_FracColumns_Merge]
	END

	EXEC [SSIS_ENG].[XML_QC_DateCompletion]
		
	EXEC [SSIS_ENG].Prepare_CustomerSurveys							

	IF (SELECT COUNT(*) FROM SSIS_ENG.xmlImport_MAT_Info) > 0
	BEGIN
		EXEC [SSIS_ENG].[Prepare_MATInfo]
		EXEC [SSIS_ENG].[Prepare_MATSandInfo]
		EXEC [SSIS_ENG].[Prepare_MATWellInfo]
		EXEC [SSIS_ENG].[Prepare_MAT_BOLDetail]					/* 20210104 */
		EXEC [SSIS_ENG].[Prepare_MATSandTrend]	
		EXEC [SSIS_ENG].[Prepare_MAT_FuelBOLs]					/* 20201030 */
		EXEC [SSIS_ENG].[Prepare_MAT_FuelSubstitution]			/* 20210422 */
	END
	
	IF (SELECT COUNT(*) FROM SSIS_ENG.xmlImport_LCS_Info) > 0
	BEGIN
		EXEC [SSIS_ENG].[Prepare_LCS_Info]
		EXEC [SSIS_ENG].[Prepare_LCS_StrapEntry]
		EXEC [SSIS_ENG].[Prepare_LCS_TicketEntry]

		EXEC [SSIS_ENG].[XML_QC_LCSs]
	END
	
	--/********************************************* Disabled 20211219
	IF (SELECT COUNT(*) FROM SSIS_ENG.xmlImport_LAB_Info) > 0
	BEGIN
		EXEC [SSIS_ENG].[Prepare_LAB_Info]	
		
		EXEC [SSIS_ENG].[Prepare_LAB_MicrobeTestingSample]	
		EXEC [SSIS_ENG].[Prepare_LAB_WaterAnalysisSamples]	

		EXEC [SSIS_ENG].[Prepare_LAB_TestSpecs]	
		EXEC [SSIS_ENG].[Prepare_LAB_TestChemicals]	
		EXEC [SSIS_ENG].[Prepare_LAB_TestData]	
		
		EXEC [SSIS_ENG].[Prepare_LAB_WellInfo]	
		EXEC [SSIS_ENG].[Prepare_LAB_HydrationTest_TestSpecs]	
		EXEC [SSIS_ENG].[Prepare_LAB_ChandlerTest_TestSpecs]	
		EXEC [SSIS_ENG].[Prepare_LAB_FlowLoop_TestSpecs_Insert]	
		EXEC [SSIS_ENG].[Prepare_LAB_ShearStress_TestSpecs_Insert]	
		EXEC [SSIS_ENG].[Prepare_LAB_HydrationTest_Data]	
		EXEC [SSIS_ENG].[Prepare_LAB_ChandlerTest_Data]	
		EXEC [SSIS_ENG].[Prepare_LAB_FlowLoop_Data_Insert]	
		EXEC [SSIS_ENG].[Prepare_LAB_ShearStress_ViscData_Insert]	
		EXEC [SSIS_ENG].[Prepare_LAB_OscillatingRheometer_Data_Insert]	
	END
	--******************************************************************************************/

	/****** 20201022 :: DISABLED on 20210326 (no longer needed. should reside in UTP_Data) 
	IF (SELECT COUNT(*) FROM [LOSSQL01\TEST].[HR].[dbo].[vw_UTP_Terminations] WHERE [Term_Date] >= dateadd(dd,-30, GETDATE())) > 0
	BEGIN
		EXEC [SSIS_ENG].[Prepare_UPT_Terminations]	
	END
	*********************************************************************************************/

	EXEC [SSIS_ENG].[POST_Process_XMLs]								

	EXECUTE [SSIS_ENG].[uspREF_History_Insert] 'SSIS_ENG.ref_UserHistory','Processing XMLs','END - SSIS'

	SET NOCOUNT OFF;

END 

GO
