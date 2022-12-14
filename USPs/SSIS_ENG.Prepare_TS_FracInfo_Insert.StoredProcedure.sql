USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_FracInfo_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******************************************************************************
  20210708(v003)- Added Reservation_Land
  20211110(v004)- Added Energized_Fluid
*******************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_FracInfo_Insert]	
AS
BEGIN
	INSERT INTO dbo.FracInfo
		([ID_Pad]
		,[ID_Well]
		,[ID_District]
		,[LOS_ProjectNo]
		,[Formation]
		,[Well_BHST]
		,[Well_MaxPressure]
		,[ID_CompletionType]
		,[ID_WellType]
		,[TotalIntervals]
		,[MainFluidTypes]
		,[MainProppantTypes]
		,[DateCompletion]
		,[PadName]
		,[xmlMacroVersion]
		,[Customer_Address]
		,[LOS_Address]
		,[Reservation_Land]			/* 20210708 */
		,[Energized_Fluid]			/* 20211110 */
		)

	SELECT ID_Pad		= CASE WHEN xI.alt_ID_Pad IS NULL THEN xI.ID_Pad ELSE xI.alt_ID_Pad END
		, ID_Well		= xI.ID_Well
		, ID_District	= xI.ID_District

		, LOS_ProjectNo		= LTRIM(RTRIM(xI.TicketNo))
		, Formation			= xI.Formation
		, Well_BHST			= xI.Well_BHST
		, Well_MaxPressure	= xI.Well_MaxPressure
		, ID_CompletionType = xI.ID_CompletionType
		, ID_WellType		= xI.ID_WellType
		, TotalIntervals	= xI.TotalIntervals
		, MainFluidTypes	= xI.MainFluidTypes
		, MainProppantTypes	= xI.MainProppantTypes
		, DateCompletion	= CASE WHEN ISDATE(xI.DateCompletion)=1 THEN xI.DateCompletion ELSE NULL END
		, PadName			= CASE WHEN xI.Pad_Name IS NULL OR xI.Pad_Name='' THEN PadName ELSE xI.Pad_Name END
		, xmlMacroVersion	= xI.xmlMacroVersion
		, Customer_Address	= xI.Customer_Address
		, LOS_Address		= xI.LOS_Address

		, Reservation_Land	= xI.Reservation_Land						/* 20210708 */
		, Energized_Fluid	= xI.Energized_Fluid						/* 20211110 */

		--, fX.*
		
		FROM [SSIS_ENG].fnRPT_xmlTS_FracInfo() xI
		WHERE ID_FracInFo IS NULL
	;

END 

GO
