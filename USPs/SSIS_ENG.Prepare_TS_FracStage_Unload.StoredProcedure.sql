USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_FracStage_Unload]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******************************************************************************************
 20181212(v002)- Add'l update when Unload; Change Status(5)/DateStatus if not Reject(3),Posted(4),or Voided(5); 
 20220117(v003)- Switch USP name; Added DateModified
******************************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_FracStage_Unload]
AS
BEGIN

	WITH cte_pVersion AS
		(SELECT eS.ID_FracInfo
			, eS.ID_FracStage
			, eS.StageNo
			, eS.StartFracTime
			, eS.EndFracTime
			, mVersionNo		= (SELECT MAX(m.VersionNo) + 1
									FROM dbo.FracStageSummary m 
									WHERE m.ID_FracInfo = eS.ID_FracInfo AND m.StageNo = eS.StageNo
									GROUP BY m.ID_FracInfo, m.StageNo)
			, cVersionNo		= eS.VersionNo
			, eS.IsDeleted
			, eS.ID_Status

			FROM [SSIS_ENG].fnRPT_xmlTS_FracStages() xS
				INNER JOIN dbo.FracStageSummary eS 
					ON eS.IsDeleted = 0
						AND eS.ID_FracInfo = xS.ID_FracInfo AND eS.StageNo = xS.StageNo
						--AND eS.Formation = xS.Formation 
						--AND eS.VersionNo = 2
		)

		UPDATE eS
			SET eS.IsDeleted	= 1
				, eS.ID_Status	= CASE WHEN eS.ID_Status NOT IN (3,4,5) THEN 5 ELSE eS.ID_Status END
				, eS.DateStatus	= CASE WHEN eS.ID_Status NOT IN (3,4,5) THEN GETDATE() ELSE eS.DateStatus END
				, eS.DateModified	= GETDATE() 	/* 20220117 */
		
			--select eP.* 
			
			FROM dbo.FracStageSummary	eS 
				INNER JOIN cte_pVersion eP ON eP.ID_FracStage = eS.ID_FracStage

END 

GO
