USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_FracChem_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******
  20190510- Added ClientProvided
******/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_FracChem_Insert]	
AS
BEGIN
	INSERT INTO dbo.FracChemicals
		(ID_FracStage, ID_Chemical
		, Chem_Frac, Chem_PD, Chem_FracPD, Chem_NC, Chem_Micro, Chem_Design
		, ClientProvided
		, ID_FracInfo)

	SELECT xC.ID_FracStage
		, xC.ID_Chemical
		, xC.Chem_Frac
		, xC.Chem_PD
		, xC.Chem_FracPD
		, xC.Chem_NC
		, xC.Chem_Micro
		, xC.Chem_Design
		, ClientProvided= xC.ClientProvided
		
		, ID_FracInfo	= xC.ID_FracInfo
		
		FROM [SSIS_ENG].[fnRPT_xmlTS_FracStages_Chemicals]() xC
			LEFT JOIN dbo.FracChemicals eC 
				ON (eC.ID_FracStage = xC.ID_FracStage AND eC.ID_Chemical=xC.ID_Chemical) 
		WHERE (xC.ID_FracStage IS NOT NULL AND xC.ID_FracInfo IS NOT NULL)
			AND eC.ID_FracChem IS NULL
	;

END 




GO
