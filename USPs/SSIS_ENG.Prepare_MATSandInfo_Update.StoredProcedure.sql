USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_MATSandInfo_Update]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***********************************************************************************
 20220117(v002)- Added DateModified
************************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_MATSandInfo_Update]	
AS
BEGIN

	UPDATE sI
		SET sI.DesignPadVariance	= xS.DesignPadVariance
		, sI.ScrewVariance			= xS.ScrewVariance
		, sI.ShutInVariance			= xS.ShutInVariance
		, sI.Est_TrucksLeftToDeliver = xS.Est_TrucksLeftToDeliver
		, sI.Vol_Delivered			= xS.Vol_Delivered
		, sI.Avg_DeliveryTime		= xS.Avg_DeliveryTime
		, sI.Vol_LeftToDeliver		= xS.Vol_LeftToDeliver
		, sI.Vol_OnLocation			= xS.Vol_OnLocation
		, sI.Vol_TotalDesign		= xS.Vol_TotalDesign
		, sI.Est_StageVolAvailable	= xS.Est_StageVolAvailable
		, sI.Total_Records			= xS.Total_Records

		, sI.DateModified	= GETDATE()

	--select *
		FROM [SSIS_ENG].[fnRPT_xmlMAT_SandInfo]() xS
			INNER JOIN dbo.Material_SandInfo sI ON (sI.ID_MaterialInfo = xS.ID_MaterialInfo AND sI.ID_Proppant=xS.ID_Proppant) 
	;

END 


GO
