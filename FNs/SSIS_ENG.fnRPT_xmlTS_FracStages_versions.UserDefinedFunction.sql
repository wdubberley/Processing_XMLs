USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlTS_FracStages_versions]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************
  Created:	KPHAM (20181212)
*****************************************************************/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlTS_FracStages_versions]()
RETURNS TABLE
AS
RETURN 

	SELECT fS.ID_FracInfo 
		, fS.ID_FracStage
		, fS.StageNo
		, fS.VersionNo
		, fS.IsDeleted
		, fS.ID_Status 

		, cID_FracStage	= cS.ID_FracStage
		, cVersionNo	= cS.VersionNo
		, cIsDeleted	= 0--cS.IsDeleted
		, cID_Status	= cS.ID_Status
	
		FROM [SSIS_ENG].vw_FracStages_Header cS
			INNER JOIN dbo.FracStageSummary fS 
				ON fS.ID_FracInfo = cS.ID_FracInfo AND fS.StageNo = cS.StageNo AND fS.VersionNo = cS.VersionNo - 1 AND cS.VersionNo > 1



GO
