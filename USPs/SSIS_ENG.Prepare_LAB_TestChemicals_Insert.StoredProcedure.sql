USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_LAB_TestChemicals_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******
  Created:	KPHAM
  Modified:	20190417- Added new columns; Add JOIN mapping to ID_TestInfo NOT NULL
******/
CREATE PROCEDURE [SSIS_ENG].[Prepare_LAB_TestChemicals_Insert]	
AS
BEGIN
	
	INSERT INTO [dbo].[LAB_TestChemicals]
		([ID_TestType],[ID_TestInfo],[ID_Chemical]
		,[AdditiveType],[SPUnit],[ChemicalSP],[Temperature]
		,[ID_LabInfo],[ID_RelatedTest],RelatedTestNo)

	SELECT [ID_TestType]= xTC.[ID_TestType]
		, [ID_TestInfo]	= xTC.[ID_TestInfo]
		, [ID_Chemical]	= xTC.[ID_Chemical]

		, [AdditiveType]= xTC.[AdditiveType]
		, [SPUnit]		= xTC.[SPUnit]
		, [ChemicalSP]	= xTC.[ChemicalSP]
		, [Temperature] = xTC.[Temperature]

		, [ID_LabInfo]	= xTC.[ID_LabInfo]
		, ID_RelatedTest= xTC.[ID_RelatedTest]
		, RelatedTestNo	= xTC.[RelatedTestNo]
			
		--, sTC.*
		FROM [SSIS_ENG].[fnRPT_xmlLAB_TestChemicals]()	xTC
			LEFT JOIN [dbo].[LAB_TestChemicals]		sTC 
				ON sTC.ID_TestInfo = xTC.ID_TestInfo 
					AND sTC.ID_TestType = xTC.ID_TestType AND sTC.ID_Chemical = xTC.ID_Chemical
		
		WHERE xTC.ID_LabInfo IS NOT NULL AND xTC.ID_TestInfo IS NOT NULL
			AND sTC.ID_TestChemical IS NULL

		ORDER BY xTC.rowID
	;

END 


GO
