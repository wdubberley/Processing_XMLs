USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_LCS_StrapEntry_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***********************************************************************************************
  Created:	KPHAM (2018)
  20190701(v002)- Added TotalPumped, TotalVariance
************************************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_LCS_StrapEntry_Insert]	
AS
BEGIN

	INSERT INTO [dbo].[Location_StrapEntries]
        ([ID_LocStrapInfo]
		, [Location_TimeStamp]
        , [ID_Chemical]
        , [StrapValue]
        , [TotalPumped]
		, [TotalVariance]
        , [StrapNo]
        , [SequenceNo])

	SELECT [ID_LocStrapInfo]	= xS.[ID_LocStrapInfo]
		, [Location_TimeStamp]	= xS.[Location_TimeStamp]
        , [ID_Chemical]			= xS.[ID_Chemical]
        , [StrapValue]			= xS.[LocationStrap]
        , [TotalPumped]			= xS.[TotalPumped]
		, [TotalVariance]		= xS.[TotalVariance]

		, [StrapNo]		= xS.[StrapNo]
        , [SequenceNo]	= xS.[RecordNo]

		FROM [SSIS_ENG].[fnRPT_xmlLCS_LocationStraps] ()	xS
			LEFT JOIN dbo.Location_StrapEntries				sS 
				ON sS.ID_LocStrapInfo = xS.ID_LocStrapInfo 
					AND sS.Location_TimeStamp = xS.Location_TimeStamp 
					AND sS.ID_Chemical = xS.ID_Chemical 

		WHERE sS.ID_LocStrap IS NULL

	;

END 

GO
