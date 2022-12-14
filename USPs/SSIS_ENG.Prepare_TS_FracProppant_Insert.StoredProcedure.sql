USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_FracProppant_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******
  20190510- Added ClientProvided
******/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_FracProppant_Insert]	
AS
BEGIN
	INSERT INTO dbo.FracProppants
		(ID_FracStage, ID_Proppant
		, [Prop_Total], [Prop_Actual], [Prop_NC], [Prop_Design], [Prop_SlurryPLF]
		, ClientProvided
		, ID_FracInfo)

	SELECT xP.ID_FracStage
		, xP.ID_Proppant

		, xP.[Prop_Total]
		, xP.[Prop_Actual]
		, xP.[Prop_NC]
		, xP.[Prop_Design]
		, Prop_SlurryPLF= xP.[Prop_SlurryPLF]
		, ClientProvided= xP.ClientProvided

		, ID_FracInfo	= xP.ID_FracInfo
		
		FROM [SSIS_ENG].[fnRPT_xmlTS_FracStages_Proppants]()	xP
			LEFT JOIN dbo.FracProppants							eP ON (eP.ID_FracStage = xP.ID_FracStage AND eP.ID_Proppant=xP.ID_Proppant) 
		
		WHERE (xP.ID_FracStage IS NOT NULL AND xP.ID_FracInfo IS NOT NULL)
			AND eP.ID_FracProppant IS NULL
	;

END 


GO
