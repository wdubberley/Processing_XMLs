USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[PRE_REF_Fluids_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [SSIS_ENG].[PRE_REF_Fluids_Insert]	
AS
BEGIN

	DECLARE @rValue AS INT;

	INSERT INTO dbo.LOS_Fluids (FluidName)

	SELECT DISTINCT xF.FluidName

		FROM [SSIS_ENG].xmlImport_TS_FracFluids xF 
			LEFT JOIN dbo.LOS_Fluids lF ON lF.FluidName = xF.FluidName AND xF.FluidName IS NOT NULL
		WHERE lF.ID_Fluid IS NULL

	/***** RECORD INSERT HISTORY *****/
	SET @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.LOS_Fluids', 'Insert', @rValue

END 


GO
