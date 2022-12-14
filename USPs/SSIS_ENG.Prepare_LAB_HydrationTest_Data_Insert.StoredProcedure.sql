USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_LAB_HydrationTest_Data_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******
  Created:	20180816 (KPHAM)
  Modified:	20190416- Added new columns; Re-order columns
******/
CREATE PROCEDURE [SSIS_ENG].[Prepare_LAB_HydrationTest_Data_Insert]	
AS
BEGIN

	INSERT INTO [dbo].[LAB_HydrationTest_TestData]
           ([ID_TestInfo]
		   ,[ChandlerTestNo]
           ,[TestName]
           ,[HydrationTimeMin]
           ,[HydrationViscositycP]
           ,[ID_LabInfo]
		   ,[HydrationTemperatureDegF]
           ,[HydrationDegFann]
		   )

	SELECT [ID_TestInfo]	= xH.[ID_TestInfo]
		
		, [ChandlerTestNo]	= xH.ChandlerTestNo
		, [TestName]		= xH.TestName
		
		, [HydrationTimeMin]		= xH.[HydrationTimeMin]
		, [HydrationViscositycP]	= xH.[HydrationViscositycP]

		, [ID_LabInfo]				= xH.[ID_LabInfo]
		, [HydrationTemperatureDegF]= xH.[HydrationTemperatureDegF]
		, [HydrationDegFann]		= xH.[HydrationDegFann]
	
		FROM [SSIS_ENG].[fnRPT_xmlLAB_HydrationTest_TestData]() xH
			LEFT JOIN [dbo].[LAB_HydrationTest_TestData] sH
				ON sH.ID_TestInfo = xH.ID_TestInfo AND sH.HydrationTimeMin = xH.HydrationTimeMin
		
		WHERE xH.ID_TestInfo IS NOT NULL AND sH.ID_TestData IS NULL

		ORDER BY xH.ID_LabInfo, xH.ID_TestInfo, xH.HydrationTimeMin
					
	;

END 



GO
