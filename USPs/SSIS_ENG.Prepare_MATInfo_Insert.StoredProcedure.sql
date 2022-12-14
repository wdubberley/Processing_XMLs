USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_MATInfo_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
  20190521(v002)- Added xmlVersion
******************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_MATInfo_Insert]	
AS
BEGIN
	INSERT INTO dbo.Material_Info
		(ID_Pad, xmlFileName, xmlDate, xmlVersion)

	SELECT ID_Pad		= fX.ID_Pad
		, xmlFileName	= fX.xmlFileName
		, xmlDate		= fX.xmlDate
		, xmlVersion	= fX.xmlVersion

		FROM [SSIS_ENG].fnRPT_xmlMAT_Info() fX
			
		WHERE ID_MaterialInfo IS NULL
			AND fX.ID_Pad IS NOT NULL
	;

END 

GO
