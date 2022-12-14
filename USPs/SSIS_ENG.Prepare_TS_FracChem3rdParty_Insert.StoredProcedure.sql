USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_FracChem3rdParty_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_FracChem3rdParty_Insert]	
AS
BEGIN

	INSERT INTO dbo.FracChem_3rdParty
		(ID_FracInfo, ID_FracStage, ChemNo, ChemicalPumper, ChemicalName, ChemicalSPorQTY)

	SELECT xC.ID_FracInfo
		, xC.ID_FracStage
		, xC.ChemNo
		, xC.ChemicalPumper
		, xC.ChemicalName
		, xC.ChemicalSPorQTY
		
		FROM [SSIS_ENG].[fnRPT_xmlTS_FracStages_Chemicals_3rdParty]() xC
			LEFT JOIN dbo.FracChem_3rdParty eC 
				ON (eC.ID_FracStage = xC.ID_FracStage AND eC.ChemNo = xC.ChemNo) 
		WHERE (xC.ID_FracStage IS NOT NULL AND xC.ID_FracInfo IS NOT NULL)
			AND eC.ID_Record IS NULL
	;

END 


GO
