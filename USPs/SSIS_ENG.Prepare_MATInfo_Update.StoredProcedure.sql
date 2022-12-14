USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_MATInfo_Update]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/********************************************************
  20190521(v002)- Added xmlVersion
********************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_MATInfo_Update]	
AS
BEGIN
	
	UPDATE sI 
		SET sI.ID_Pad			= fX.ID_Pad
			, sI.xmlFileName	= fX.xmlFileName
			, sI.xmlDate		= fX.xmlDate
			, sI.xmlVersion		= fX.xmlVersion
			, sI.DateModified	= GETDATE()

		FROM [SSIS_ENG].fnRPT_xmlMAT_Info()	fX
			INNER JOIN dbo.Material_Info	sI ON sI.ID_MaterialInfo = fX.ID_MaterialInfo
			
		WHERE fX.ID_MaterialInfo IS NOT NULL
	;

END 

GO
