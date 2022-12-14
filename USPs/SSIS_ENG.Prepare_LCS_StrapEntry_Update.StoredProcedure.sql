USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_LCS_StrapEntry_Update]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***********************************************************************************************
  Created:	KPHAM (2018)
  20190701(v002)- Added TotalPumped, TotalVariance
************************************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_LCS_StrapEntry_Update]	
AS
BEGIN

	UPDATE sS
		SET sS.[StrapValue]	= xS.[LocationStrap]
		, sS.[TotalPumped]	= xS.[TotalPumped]
		, sS.[TotalVariance]= xS.[TotalVariance]
		
		, sS.[StrapNo]		= xS.[StrapNo]
		, sS.[SequenceNo]	= xS.[RecordNo]

	--SELECT xS.*
		FROM [SSIS_ENG].[fnRPT_xmlLCS_LocationStraps] ()	xS
			INNER JOIN dbo.Location_StrapEntries			sS 
				ON sS.ID_LocStrapInfo = xS.ID_LocStrapInfo 
					AND sS.Location_TimeStamp = xS.Location_TimeStamp 
					AND sS.ID_Chemical = xS.ID_Chemical 
					
	;

END 

GO
