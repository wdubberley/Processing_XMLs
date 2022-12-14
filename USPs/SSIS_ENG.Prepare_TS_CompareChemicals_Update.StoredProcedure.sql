USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_CompareChemicals_Update]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_CompareChemicals_Update]
AS
BEGIN
	
	UPDATE eCC
		SET eCC.Chemical_Unit		= xC_Chem.[Chemical_Unit]
		, eCC.Chemical_Propose	= xC_Chem.[Chemical_Propose]
		, eCC.Chemical_Design	= xC_Chem.[Chemical_Design]
		, eCC.Chemical_Actual	= xC_Chem.[Chemical_Actual]
		
		--SELECT xC_Chem.*

		FROM [SSIS_ENG].[fnRPT_xmlTS_ComparisonChemicals]()	xC_Chem
			INNER JOIN [dbo].[Comparison_Chemicals] eCC 
				ON (eCC.ID_FracInfo = xC_Chem.ID_FracInfo AND eCC.StageNo = xC_Chem.StageNo AND eCC.ID_Chemical = xC_Chem.ID_Chemical) 
	;

END 


GO
