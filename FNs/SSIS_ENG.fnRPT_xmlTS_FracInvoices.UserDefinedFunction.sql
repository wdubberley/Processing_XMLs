USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlTS_FracInvoices]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******************************************************************
 Created:	KPHAM (20210427)
 20210503(v002)- Added ID_Invoice by LEFT JOIN
******************************************************************/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlTS_FracInvoices] ()
RETURNS TABLE
RETURN

	SELECT DISTINCT
		  ID_FracInfo	= x.ID_FracInfo --ISNULL(fI.ID_FracInfo, i.ID_FracInfo)
		, InvoiceRange	= x.TicketRangeNum
		, frStage		= MIN(x.StageNo)
		, toStage		= MAX(x.StageNo)
		, DateInvoice	= CONVERT(DATE, MAX(ISNULL(x.EndFracDate, x.StartFracDate)))
		, Ticket_Discount	= x.Ticket_Discount
		--, VersionNo		= MAX(ISNULL(fV.VersionNo, 0)) + 1
						--(SELECT MAX(
							--FROM dbo.FracInvoices	t 
							--WHERE t.ID_FracInfo = i.ID_FracInfo AND t.InvoiceRange = fS.TicketRangeNum)

		, WellName	= x.WellName
		, PadName	= i.PadName
		, TicketNo	= i.TicketNo
		, ID_Invoice= fV.ID_Invoice

		FROM [SSIS_ENG].[fnRPT_xmlTS_FracStages] ()	x
			INNER JOIN [SSIS_ENG].[fnRPT_xmlTS_FracInfo] ()	i ON i.ID_FracInfo = x.ID_FracInfo
			
			LEFT JOIN dbo.FracInvoices		fV ON fV.IsDeleted = 0 AND fV.ID_FracInfo = x.ID_FracInfo AND fV.InvoiceRange = x.TicketRangeNum 

		WHERE 1=1
			AND x.TicketRangeNum <> ''
			AND ISNUMERIC(i.TicketNo) = 1 AND i.TicketNo > '100000'
			--AND x.TicketRangeNum NOT LIKE '%.Well'
			--AND fV.ID_Invoice IS NULL

			--and i.ID_Pad in (4574)
			--and i.ID_FracInfo = 13721

		GROUP BY x.ID_FracInfo	--ISNULL(fI.ID_FracInfo, i.ID_FracInfo)
			, x.TicketRangeNum
			, x.Ticket_Discount
			, x.WellName
			, i.PadName
			, i.TicketNo
			, fV.ID_Invoice
GO
