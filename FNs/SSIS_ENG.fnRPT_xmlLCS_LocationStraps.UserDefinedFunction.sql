USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlLCS_LocationStraps]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************************************ 
  CREATED:	20180801 
  20190701(v002)- Added TotalPumped, TotalVariance
************************************************/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlLCS_LocationStraps]()
RETURNS TABLE
AS
RETURN 
		
	SELECT ID_LocStrapInfo	= xI.ID_LocStrapInfo
		, [ID_Chemical]		= rC.ID_Chemical

		, [Location_TimeStamp]	= xLS.[Location_TimeStamp]
		, [LocationStrap]		= xLS.[LocationStrap]
		, [TotalPumped]			= xLS.[TotalPumped]
		, [TotalVariance]		= xLS.[TotalVariance]

		, [StrapNo]		= RANK() OVER(PARTITION BY xLS.ChemicalName ORDER BY xI.PadName, xLS.Location_TimeStamp)
		, [RecordNo]	= RANK() OVER(PARTITION BY xI.PadName, xLS.Location_TimeStamp ORDER BY xLS.ChemicalName)
		
		--, rNo			= ROW_NUMBER() OVER(ORDER BY xI.PadName, xLS.Location_TimeStamp, xLS.ChemicalName)
		, [ID_Record]	= xLS.ID_Record
		, [PadName]		= xLS.PadName
		, [ChemicalName]= xLS.ChemicalName
		, [ID_Pad]		= xI.ID_Pad

		FROM [SSIS_ENG].[xmlImport_LCS_ChemicalStraps]	xLS
			INNER JOIN [SSIS_ENG].fnrpt_xmlLCS_Info()	xI ON xI.PadName = xLS.PadName
			INNER JOIN [dbo].[LOS_Chemicals]			rC ON rC.ChemicalName = xLS.ChemicalName

	;

GO
