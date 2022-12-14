USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[XML_QC_DateCompletion]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***********************************************************************************
 Created:	KPHAM
 20220118(v002)- Added DateModified
************************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[XML_QC_DateCompletion]	
AS
BEGIN
	SET NOCOUNT ON;
	SET ANSI_WARNINGS OFF;

	WITH cte_Tickets AS (SELECT DISTINCT ID_FracInfo, cItems = COUNT(*) FROM dbo.FieldTicket_Items GROUP BY ID_FracInfo)
		, cte_sInfo AS 
		(SELECT DISTINCT PadName = p.PadName_From
			, maxEndDate	= max(s.EndFracDate)
			, cStages		= COUNT(DISTINCT s.StageNo)
			, iStages		= i.TotalIntervals
			, hasTicket		= CASE WHEN t.ID_FracInfo IS NOT NULL THEN 1 ELSE 0 END
			, iComp			= i.DateCompletion
			, TicketNo		= i.LOS_ProjectNo
		
			, ID_Pad		= p.ID_Pad
			, ID_FracInfo	= s.ID_FracInfo
		
			FROM dbo.FracStageSummary s
				INNER JOIN dbo.FracInfo i ON i.ID_FracInfo = s.ID_FracInfo AND s.IsDeleted=0
				INNER JOIN Engineering.vw_Time_BetweenPads p ON p.ID_Pad = i.ID_Pad AND p.CurrentJob=1
				LEFT JOIN cte_Tickets t ON t.ID_FracInfo = i.ID_FracInfo

			WHERE s.EndFracDate IS NOT NULL
		
			GROUP BY s.ID_FracInfo
				, i.TotalIntervals
				, i.DateCompletion
				, i.LOS_ProjectNo
				, p.ID_Pad, p.PadName_From
				, t.ID_FracInfo

		)

		UPDATE i SET DateCompletion = NULL
			, DateModified	= GETDATE()
		--SELECT *
			FROM cte_sInfo s
				INNER JOIN dbo.FracInfo i ON i.ID_FracInfo = s.ID_FracInfo
			WHERE (cStages < iStages AND hasTicket=0 AND iComp IS NOT NULL)
	
	SET ANSI_WARNINGS ON;
	SET NOCOUNT OFF;

END 

GO
