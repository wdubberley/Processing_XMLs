USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TQ_TicketItem]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/************************************************************
  Created:	KPHAM (2018)
  20200212(v002)- Added call to Adjust additional lines in tickets
*************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TQ_TicketItem]	
AS
BEGIN

	EXEC [SSIS_ENG].[Prepare_TQ_TicketItem_Update]	
	EXEC [SSIS_ENG].[Prepare_TQ_TicketItem_Insert]

	EXEC [SSIS_ENG].[Prepare_TQ_TicketItem_Adjust]		/* 20200212 */
		
END 

GO
