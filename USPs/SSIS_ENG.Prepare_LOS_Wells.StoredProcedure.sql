USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_LOS_Wells]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [SSIS_ENG].[Prepare_LOS_Wells]	
AS
BEGIN

	EXEC [SSIS_ENG].[Prepare_LOS_Wells_Update]

	EXEC [SSIS_ENG].[Prepare_LOS_Wells_Insert]	
	
END 


GO
