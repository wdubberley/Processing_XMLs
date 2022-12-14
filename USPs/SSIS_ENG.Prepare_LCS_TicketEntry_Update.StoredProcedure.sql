USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_LCS_TicketEntry_Update]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [SSIS_ENG].[Prepare_LCS_TicketEntry_Update]	
AS
BEGIN

	UPDATE sT
		SET sT.[ChemicalValue]	= xT.[ChemicalValue]
		, sT.[ID_WellInfo]		= xT.[ID_WellInfo]

	--SELECT xT.*

		FROM [SSIS_ENG].[fnRPT_xmlLCS_LocationTickets]() xT
			INNER JOIN dbo.Location_TicketEntries sT 
				ON sT.ID_LocStrapInfo = xT.ID_LocStrapInfo 
					AND sT.ID_Chemical = xT.ID_Chemical 
					AND sT.[WellRecord] = xT.[WellRecord] 

	;

END 



GO
