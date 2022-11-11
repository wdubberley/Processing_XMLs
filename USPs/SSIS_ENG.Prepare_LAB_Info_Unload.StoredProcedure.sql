USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_LAB_Info_Unload]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [SSIS_ENG].[Prepare_LAB_Info_Unload]	
AS
BEGIN
	
	UPDATE iL 
		SET iL.IsDeleted		= 1
			, iL.DateModified	= GETDATE()

	--SELECT *

		FROM [SSIS_ENG].[fnRPT_xmlLAB_Info]()	xL
			INNER JOIN dbo.LAB_Info			iL ON iL.ID_LabInfo = xL.ID_LabInfo

	;

END 


GO
