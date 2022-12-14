USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[PRE_REF_DesignStageTypes]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [SSIS_ENG].[PRE_REF_DesignStageTypes]	
AS
BEGIN

	DECLARE @rValue AS INT 

	INSERT INTO dbo.ref_DesignStageTypes (StageType, OrderNo)
	SELECT DISTINCT Stage_Type, -1
		FROM SSIS_ENG.xmlImport_TS_Designs xD
			LEFT JOIN dbo.ref_DesignStageTypes eRef ON xD.Stage_Type = eRef.StageType
		WHERE xD.Stage_Type IS NOT NULL AND eRef.ID_StageType IS NULL
	
	/***** RECORD INSERT HISTORY *****/
	SELECT @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.ref_DesignStageTypes', 'Insert', @rValue;
	
END 

GO
