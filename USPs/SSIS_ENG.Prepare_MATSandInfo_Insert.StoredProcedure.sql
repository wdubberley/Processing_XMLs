USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_MATSandInfo_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [SSIS_ENG].[Prepare_MATSandInfo_Insert]	
AS
BEGIN
	
	INSERT INTO dbo.[Material_SandInfo]
		([ID_MaterialInfo]
		,[ID_Proppant]
		,[DesignPadVariance]
		,[ScrewVariance]
		,[ShutInVariance]
		,[Est_TrucksLeftToDeliver]
		,[Vol_Delivered]
		,[Avg_DeliveryTime]
		,[Vol_LeftToDeliver]
		,[Vol_OnLocation]
		,[Vol_TotalDesign]
		,[Est_StageVolAvailable]
		,[Total_Records])

	SELECT ID_MaterialInfo		= xS.ID_MaterialInfo
		, ID_Proppant			= xS.ID_Proppant
		, DesignPadVariance		= xS.DesignPadVariance
		, ScrewVariance			= xS.ScrewVariance
		, ShutInVariance		= xS.ShutInVariance
		, Est_TrucksLeftToDeliver = xS.Est_TrucksLeftToDeliver
		, Vol_Delivered			= xS.Vol_Delivered
		, Avg_DeliveryTime		= xS.Avg_DeliveryTime
		, Vol_LeftToDeliver		= xS.Vol_LeftToDeliver
		, Vol_OnLocation		= xS.Vol_OnLocation
		, Vol_TotalDesign		= xS.Vol_TotalDesign
		, Est_StageVolAvailable	= xS.Est_StageVolAvailable
		, Total_Records			= xS.Total_Records

		--, xS.*
	
		FROM [SSIS_ENG].[fnRPT_xmlMAT_SandInfo]()	xS
			LEFT JOIN dbo.Material_SandInfo			sI ON (sI.ID_MaterialInfo = xS.ID_MaterialInfo AND sI.ID_Proppant=xS.ID_Proppant) 

		WHERE (xS.ID_MaterialInfo IS NOT NULL AND xS.ID_MaterialInfo IS NOT NULL)
			AND sI.ID_SandInfo IS NULL
	;

END 

GO
