USE [FieldData]
GO
/****** Object:  View [SSIS_ENG].[vw_FracStages_Header]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************************
  20181212- Added VersionNo
  20210211(v003)- Added base UOM_Chem/UOM_Sand as default UOM indicator
********************************************************************************/
CREATE VIEW [SSIS_ENG].[vw_FracStages_Header] 
AS
	SELECT DISTINCT 
		ID_FracStage	= eS.ID_FracStage
		, ID_FracInfo	= xS.ID_FracInfo
		, WellName		= lW.WellName
		, StageNo		= eS.StageNo
		, Formation		= xS.Formation
		, FilePath		= xS.FilePath

		, VersionNo		= eS.VersionNo					/* 20181212 */
		, ID_Status		= eS.ID_Status
		
		--, ID_District	= eI.ID_District
		, UOM_Chem	= CASE WHEN eI.ID_District IN (11) THEN 'L' ELSE 'GAL' END
		, UOM_Sand	= CASE WHEN eI.ID_District IN (11) THEN 'KG' ELSE 'LBS' END
	
		FROM [SSIS_ENG].fnRPT_xmlTS_FracStages()	xS
			INNER JOIN dbo.FracStageSummary eS ON eS.ID_FracInfo=xS.ID_FracInfo AND eS.StageNo= xS.StageNo 
												AND (eS.Formation=xS.Formation)
												AND (eS.IsDeleted = 0)
			INNER JOIN dbo.FracInfo			eI ON xS.ID_FracInfo = eI.ID_FracInfo
			INNER JOIN dbo.LOS_Wells		lW ON eI.ID_Well = lW.ID_Well 

GO
