USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_FracFluid_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_FracFluid_Insert]	
AS
BEGIN
	INSERT INTO dbo.FracFluids
		(ID_FracStage, ID_Fluid
		, Fluid_Volume
		, ID_FracInfo)

	SELECT ID_FracStage		= xF.ID_FracStage
		, ID_Fluid			= xF.ID_Fluid
		, Fluid_Vol			= CONVERT(REAL, xF.Fluid_Vol)
		, ID_FracInfo		= xF.ID_FracInfo
	
		FROM [SSIS_ENG].[fnRPT_xmlTS_FracStages_Fluids]() xF
			LEFT JOIN  dbo.[FracFluids] eF 
				ON (eF.ID_FracStage = xF.ID_FracStage AND eF.ID_Fluid=xF.ID_Fluid) 
		WHERE (xF.ID_FracStage IS NOT NULL AND xF.ID_FracInfo IS NOT NULL)
			AND eF.ID_FracFluid IS NULL
	;

END 


GO
