USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_LAB_WellInfo]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******
  Created:	20190415 (KPHAM)
  Modified:	
******/
CREATE PROCEDURE [SSIS_ENG].[Prepare_LAB_WellInfo]	
AS
BEGIN

	INSERT INTO [dbo].[LAB_WellInfo]
		([ID_LabInfo],[WellName])

	SELECT ID_LabInfo
		, WellName

		FROM [SSIS_ENG].[fnRPT_xmlLAB_WellInfo] () xW
		WHERE xW.ID_LabInfo IS NOT NULL
	;

END 


GO
