USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_CompareChemicals_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************
  Created:	KPHAM (2017)
  Updated:	20190116- Change ORDERBY to xC_Chem.rNo; Added IDX for dbo.Comparison_Chemicals
*****************************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_CompareChemicals_Insert]	
AS
BEGIN
	
	INSERT INTO [dbo].[Comparison_Chemicals]
           ([ID_FracInfo]
           ,[StageNo]
           ,[ID_Chemical]
           ,[Chemical_Unit]
           ,[Chemical_Propose]
           ,[Chemical_Design]
           ,[Chemical_Actual])

	SELECT [ID_FracInfo]	= xC_Chem.[ID_FracInfo]
        , [StageNo]			= xC_Chem.[StageNo]
		, ID_Chemical		= xC_Chem.ID_Chemical
		, Chemical_Unit		= xC_Chem.[Chemical_Unit]
		, Chemical_Propose	= xC_Chem.[Chemical_Propose]
		, Chemical_Design	= xC_Chem.[Chemical_Design]
		, Chemical_Actual	= xC_Chem.[Chemical_Actual]

		--, xC_Chem.*
	
		FROM [SSIS_ENG].[fnRPT_xmlTS_ComparisonChemicals]() xC_Chem
			LEFT JOIN [dbo].[Comparison_Chemicals] eCC 
				ON (eCC.ID_FracInfo = xC_Chem.ID_FracInfo AND eCC.StageNo = xC_Chem.StageNo AND eCC.ID_Chemical=xC_Chem.ID_Chemical) 
		
		WHERE xC_Chem.ID_FracInfo IS NOT NULL
			AND eCC.ID_CompareChem IS NULL

		ORDER BY xC_Chem.rNo
	;

END 



GO
