USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_LAB_ChandlerTest_Data_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******
  CREATED:	KPHAM
  MOdified:	20190416- Added new column; Re-order columns to match new schema
******/
CREATE PROCEDURE [SSIS_ENG].[Prepare_LAB_ChandlerTest_Data_Insert]	
AS
BEGIN

	INSERT INTO [dbo].[LAB_ChandlerTest_TestData]
           ([ID_TestInfo],[ID_LabInfo]
		   ,[HydrationTestNo]
           ,[SequenceNo],[ElapsedTimeSec],[Viscosity],[Temperature]
		   )

	SELECT [ID_TestInfo]	= xC.[ID_TestInfo]
		, [ID_LabInfo]		= xC.[ID_LabInfo]

		, [HydrationTestNo] = xC.HydrationTestNo

		, [SequenceNo]		= xC.SequenceNo
		, [ElapsedTimeSec]	= xC.ElapsedTimeSec
		, [Viscosity]		= xC.Viscosity
		, [Temperature]		= xC.Temperature

	--SELECT xC.*
		FROM [SSIS_ENG].[fnRPT_xmlLAB_ChandlerTest_TestData]()	xC
			LEFT JOIN [dbo].[LAB_ChandlerTest_TestData]		sC ON sC.ID_TestInfo = xC.ID_TestInfo AND sC.SequenceNo = xC.SequenceNo

		WHERE xC.ID_TestInfo IS NOT NULL AND sC.ID_TestData IS NULL
					
	;

END 


GO
