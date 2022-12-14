USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_Pads]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*************************************************
  Created:	KPHAM (2016)
  20201102(v003)- Added Update_CorrectPadNo as a separate call & logged xml
**************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_Pads]	
AS
BEGIN

	EXEC [SSIS_ENG].[Prepare_Pads_Update]
	
	EXEC [SSIS_ENG].[Prepare_Pads_Update_CorrectPadNo]			/* 20201102 */

	EXEC [SSIS_ENG].[Prepare_Pads_Insert]	
	
END 

GO
