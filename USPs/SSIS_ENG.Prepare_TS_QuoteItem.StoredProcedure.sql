USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_QuoteItem]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************
  Created:	KPHAM (20190305)
  20200211(v003)- Added USP to adjust extra FieldQuote items; clean up code
******************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_QuoteItem]	
AS
BEGIN

	EXEC [SSIS_ENG].[Prepare_TS_QuoteItem_Update]	
	
	EXEC [SSIS_ENG].[Prepare_TS_QuoteItem_Insert]

	EXEC [SSIS_ENG].[Prepare_TS_QuoteItem_Adjust]		/* 20200211 */
		
END 



GO
