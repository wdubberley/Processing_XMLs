USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[PRE_REF_Chemicals]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [SSIS_ENG].[PRE_REF_Chemicals]	
AS
BEGIN

	DECLARE @rValue AS INT;
	
	WITH chemCTE AS
		(SELECT DISTINCT xC.ChemicalName
			FROM SSIS_ENG.xmlImport_TS_FracChemicals xC 
		UNION 
		SELECT DISTINCT xCC.ChemicalName
			FROM SSIS_ENG.xmlImport_TS_ChargesChems xCC
		UNION 
		SELECT DISTINCT xTS_C.Chemical_Name
			FROM [SSIS_ENG].xmlImport_TS_ComparisonChemicals xTS_C
		
		/***** Final TS **************************/
		UNION 
		SELECT DISTINCT xSP.ChemicalName
			FROM SSIS_ENG.xmlImport_TS_Designs_ChemSP xSP
		UNION 
		SELECT DISTINCT xCT.ChemicalName
			FROM SSIS_ENG.xmlImport_TS_ChemTotals xCT
		
		/***** CHEM ******************************/
		UNION 
		SELECT DISTINCT xCE.ChemicalName
			FROM [SSIS_ENG].xmlImport_CHEM_ChemEntries xCE
		UNION 
		SELECT DISTINCT xTE.ChemicalName
			FROM [SSIS_ENG].xmlImport_CHEM_TicketEntries xTE

		/***** LCS data (20180906) ************/
		UNION 
		SELECT DISTINCT xLCS.ChemicalName
			FROM [SSIS_ENG].xmlImport_LCS_ChemicalStraps xLCS
		UNION 
		SELECT DISTINCT xLTE.ChemicalName
			FROM [SSIS_ENG].xmlImport_LCS_TicketChemEntries xLTE

		/***** LAB data (20190422) ************/
		UNION 
		SELECT DISTINCT xL_Hyd.AdditiveName
			FROM [SSIS_ENG].xmlImport_LAB_HydrationTest_ChemInfo xL_Hyd
		UNION 
		SELECT DISTINCT xL_CT.AdditiveName
			FROM [SSIS_ENG].xmlImport_LAB_ChandlerTest_ChemInfo xL_CT
		UNION 
		SELECT DISTINCT xL_FL.AdditiveName
			FROM [SSIS_ENG].xmlImport_LAB_FlowLoop_ChemInfo xL_FL
		UNION 
		SELECT DISTINCT xL_SS.AdditiveName
			FROM [SSIS_ENG].xmlImport_LAB_ShearStress_ChemInfo xL_SS

		)

	INSERT INTO dbo.LOS_Chemicals (ChemicalName)

	SELECT UPPER(xC.ChemicalName) 
		FROM chemCTE xC
			LEFT JOIN dbo.LOS_Chemicals lC ON lC.ChemicalName = xC.ChemicalName AND xC.ChemicalName IS NOT NULL
		WHERE lC.ID_Chemical IS NULL AND xC.ChemicalName IS NOT NULL;

	/***** RECORD INSERT HISTORY *****/
	SET @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC SSIS_ENG.[uspREF_History_Insert] 'dbo.LOS_Chemicals', 'Insert', @rValue;

END 

GO
