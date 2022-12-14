USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_LCS_TicketEntry_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [SSIS_ENG].[Prepare_LCS_TicketEntry_Insert]	
AS
BEGIN

	INSERT INTO [dbo].[Location_TicketEntries]
        ([ID_LocStrapInfo]
        , [ID_Chemical]
		, [WellRecord]
        , [ChemicalValue]
        , [ID_WellInfo])

	SELECT [ID_LocStrapInfo]	= xT.[ID_LocStrapInfo]
	    , [ID_Chemical]			= xT.[ID_Chemical]
		, [WellRecord]			= xT.[WellRecord]
        , [ChemicalValue]		= xT.[ChemicalValue]
        
		, [ID_WellInfo]			= xT.[ID_WellInfo]

		FROM [SSIS_ENG].[fnRPT_xmlLCS_LocationTickets]() xT
			LEFT JOIN dbo.Location_TicketEntries sT 
				ON sT.ID_LocStrapInfo = xT.ID_LocStrapInfo 
					AND sT.ID_Chemical = xT.ID_Chemical 
					AND sT.[WellRecord] = xT.[WellRecord] 
					
		WHERE sT.ID_LocationTicket IS NULL

	;

END 



GO
