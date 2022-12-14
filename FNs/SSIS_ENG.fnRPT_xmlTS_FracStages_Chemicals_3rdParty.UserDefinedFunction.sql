USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlTS_FracStages_Chemicals_3rdParty]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlTS_FracStages_Chemicals_3rdParty]()
RETURNS TABLE
AS
RETURN 

	WITH CHEM_3rdParty AS
		(SELECT xC.WellName
			, xC.Stage
			, ChemNo			= 1
			, ChemicalPumper	= xC.ThirdPartyChemPumper_1
			, ChemicalName		= xC.ThirdPartyChemName_1
			, ChemicalSPorQTY	= xC.ThirdPartyChemSPorQTY_1
			, FilePath	= xC.FilePath
			FROM [SSIS_ENG].xmlImport_TS_FracStages xC
			WHERE (xC.ThirdPartyChemPumper_1 IS NOT NULL OR xC.ThirdPartyChemName_1 IS NOT NULL OR xC.ThirdPartyChemSPorQTY_1 IS NOT NULL)
		UNION
		SELECT xC.WellName
			, xC.Stage
			, ChemNo			= 2
			, ChemicalPumper	= xC.ThirdPartyChemPumper_2
			, ChemicalName		= xC.ThirdPartyChemName_2
			, ChemicalSPorQTY	= xC.ThirdPartyChemSPorQTY_2
			, FilePath	= xC.FilePath
			FROM [SSIS_ENG].xmlImport_TS_FracStages xC
			WHERE (xC.ThirdPartyChemPumper_2 IS NOT NULL OR xC.ThirdPartyChemName_2 IS NOT NULL OR xC.ThirdPartyChemSPorQTY_2 IS NOT NULL)
		UNION
		SELECT xC.WellName
			, xC.Stage
			, ChemNo			= 3
			, ChemicalPumper	= xC.ThirdPartyChemPumper_3
			, ChemicalName		= xC.ThirdPartyChemName_3
			, ChemicalSPorQTY	= xC.ThirdPartyChemSPorQTY_3
			, FilePath	= xC.FilePath
			FROM [SSIS_ENG].xmlImport_TS_FracStages xC
			WHERE (xC.ThirdPartyChemPumper_3 IS NOT NULL OR xC.ThirdPartyChemName_3 IS NOT NULL OR xC.ThirdPartyChemSPorQTY_3 IS NOT NULL)
		UNION
		SELECT xC.WellName
			, xC.Stage
			, ChemNo			= 4
			, ChemicalPumper	= xC.ThirdPartyChemPumper_4
			, ChemicalName		= xC.ThirdPartyChemName_4
			, ChemicalSPorQTY	= xC.ThirdPartyChemSPorQTY_4
			, FilePath	= xC.FilePath
			FROM [SSIS_ENG].xmlImport_TS_FracStages xC
			WHERE (xC.ThirdPartyChemPumper_4 IS NOT NULL OR xC.ThirdPartyChemName_4 IS NOT NULL OR xC.ThirdPartyChemSPorQTY_4 IS NOT NULL)
		UNION
		SELECT xC.WellName
			, xC.Stage
			, ChemNo			= 5
			, ChemicalPumper	= xC.ThirdPartyChemPumper_5
			, ChemicalName		= xC.ThirdPartyChemName_5
			, ChemicalSPorQTY	= xC.ThirdPartyChemSPorQTY_5
			, FilePath	= xC.FilePath
			FROM [SSIS_ENG].xmlImport_TS_FracStages xC
			WHERE (xC.ThirdPartyChemPumper_5 IS NOT NULL OR xC.ThirdPartyChemName_5 IS NOT NULL OR xC.ThirdPartyChemSPorQTY_5 IS NOT NULL)
		UNION
		SELECT xC.WellName
			, xC.Stage
			, ChemNo			= 6
			, ChemicalPumper	= xC.ThirdPartyChemPumper_6
			, ChemicalName		= xC.ThirdPartyChemName_6
			, ChemicalSPorQTY	= xC.ThirdPartyChemSPorQTY_6
			, FilePath	= xC.FilePath
			FROM [SSIS_ENG].xmlImport_TS_FracStages xC
			WHERE (xC.ThirdPartyChemPumper_6 IS NOT NULL OR xC.ThirdPartyChemName_6 IS NOT NULL OR xC.ThirdPartyChemSPorQTY_6 IS NOT NULL)
		UNION
		SELECT xC.WellName
			, xC.Stage
			, ChemNo			= 7
			, ChemicalPumper	= xC.ThirdPartyChemPumper_7
			, ChemicalName		= xC.ThirdPartyChemName_7
			, ChemicalSPorQTY	= xC.ThirdPartyChemSPorQTY_7
			, FilePath	= xC.FilePath
			FROM [SSIS_ENG].xmlImport_TS_FracStages xC
			WHERE (xC.ThirdPartyChemPumper_7 IS NOT NULL OR xC.ThirdPartyChemName_7 IS NOT NULL OR xC.ThirdPartyChemSPorQTY_7 IS NOT NULL)
		UNION
		SELECT xC.WellName
			, xC.Stage
			, ChemNo			= 8
			, ChemicalPumper	= xC.ThirdPartyChemPumper_8
			, ChemicalName		= xC.ThirdPartyChemName_8
			, ChemicalSPorQTY	= xC.ThirdPartyChemSPorQTY_8
			, FilePath	= xC.FilePath
			FROM [SSIS_ENG].xmlImport_TS_FracStages xC
			WHERE (xC.ThirdPartyChemPumper_8 IS NOT NULL OR xC.ThirdPartyChemName_8 IS NOT NULL OR xC.ThirdPartyChemSPorQTY_8 IS NOT NULL)
		UNION
		SELECT xC.WellName
			, xC.Stage
			, ChemNo			= 9
			, ChemicalPumper	= xC.ThirdPartyChemPumper_9
			, ChemicalName		= xC.ThirdPartyChemName_9
			, ChemicalSPorQTY	= xC.ThirdPartyChemSPorQTY_9
			, FilePath	= xC.FilePath
			FROM [SSIS_ENG].xmlImport_TS_FracStages xC
			WHERE (xC.ThirdPartyChemPumper_9 IS NOT NULL OR xC.ThirdPartyChemName_9 IS NOT NULL OR xC.ThirdPartyChemSPorQTY_9 IS NOT NULL)
		)
	
	SELECT sCTE.ID_FracInfo
		, sCTE.ID_FracStage
		, xC.ChemNo
		, xC.ChemicalPumper
		, xC.ChemicalName
		, xC.ChemicalSPorQTY
		FROM CHEM_3rdParty xC
			INNER JOIN [SSIS_ENG].vw_FracStages_Header	sCTE ON sCTE.WellName = xC.WellName
															AND sCTE.StageNo = xC.Stage 
															AND sCTE.FilePath=xC.FilePath

	;


GO
