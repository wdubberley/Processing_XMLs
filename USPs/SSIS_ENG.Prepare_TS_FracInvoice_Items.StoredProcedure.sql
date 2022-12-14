USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_FracInvoice_Items]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******************************************************************************
  Created: KPHAM (20210429)
  20210511(v002)- make sure ChargeDesc is '' when empty
  20210525(v003)- Corrected WHERE clause to only dismiss ChargeDesc NULL
  20210610(v004)- Corrected ChargeQty to 0 when NULL
******************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_FracInvoice_Items]
AS
BEGIN 
	
	DECLARE @tbl_Invoices AS TABLE (ID_FracInfo INT, InvoiceRange NVARCHAR(50), frStage INT, toStage INT, DateInvoice DATE, Ticket_Discount REAL
								, IDs_FracStage NVARCHAR(MAX), WellName VARCHAR(255), PadName VARCHAR(255), TicketNo NVARCHAR(50))
	INSERT INTO @tbl_Invoices

	SELECT ID_FracInfo
		, InvoiceRange
		, frStage
		, toStage
		, DateInvoice
		, Ticket_Discount
		, IDs_FracStage = STUFF((SELECT DISTINCT ',' + CONVERT(NVARCHAR(15),t.[ID_FracStage]) -- Add a comma (,) before each value
								FROM [dbo].[FracStageSummary] t 
								WHERE t.IsDeleted = 0 AND t.ID_FracInfo = x.ID_FracInfo AND t.StageNo BETWEEN x.frStage AND x.toStage
								GROUP BY t.ID_FracInfo, t.ID_FracStage--, t.[StageNo]
								--ORDER BY CONVERT(NVARCHAR(15),t.[ID_FracStage])
							FOR XML PATH('') -- Select it as XML
							), 1, 1, '' )
		, WellName, PadName, TicketNo

		FROM [SSIS_ENG].[fnRPT_xmlTS_FracInvoices] () x
		WHERE ID_FracInfo IS NOT NULL
			--and ID_FracInfo IN (13914)

	--select * from @tbl_Invoices

	DECLARE @tbl_InvoiceItems AS TABLE (ID_FracInfo INT, ID_ChargeType INT, DateInvoice DATE
									, ChargeDesc NVARCHAR(266), ChargeCode INT, ChargeQty DECIMAL(18,5)
									, ChargePrice DECIMAL(18,5), ChargeUOM VARCHAR(50), ChargeDiscount DECIMAL(18,5), ChargeTotal DECIMAL(18,6)
									, item_Discount DECIMAL(18,5), well_Discount DECIMAL(18,5))
	INSERT INTO @tbl_InvoiceItems

	/********* SERVICES :: 23 **************************************************/
	SELECT DISTINCT
		  ID_FracInfo	= xCS.ID_FracInfo
		, ID_ChargeType = 23
		, DateInvoice	= xI.DateInvoice
		
		, ChargeDesc	= ISNULL(rS.ServiceName,'')
		, ChargeCode	= xCS.ChargeCode
		, ChargeQty		= SUM(xCS.Service_Quantity)
		, ChargePrice	= xCS.Service_Price
		, ChargeUOM		= xCS.Charge_Unit
		, ChargeDiscount= xCS.Service_Discount + ISNULL(xI.Ticket_Discount, 0)
		, ChargeTotal	= SUM(xCS.Service_Cost)
						- CASE WHEN xCS.Service_Price > 0 
							THEN (SUM(xCS.Service_Cost) * ISNULL(xI.Ticket_Discount, 0)) --* -1
							ELSE 0 END 

		, item_Discount = xCS.Service_Discount
		, well_Discount = ISNULL(xI.Ticket_Discount, 0)

		--, InvoiceRange	= xI.InvoiceRange
		--, TicketNo		= xI.TicketNo
		--, WellName		= xI.WellName
		--, originalCharge= SUM(xCS.Service_Cost)
		--, addPercent	= ISNULL(xI.Ticket_Discount, 0)
		--, addDiscount	= CASE WHEN xCS.Service_Price > 0 
		--					THEN (SUM(xCS.Service_Cost) * ISNULL(xI.Ticket_Discount, 0)) --* -1
		--					ELSE 0 END 

		FROM @tbl_Invoices	xI 
			INNER JOIN dbo.FracStageSummary		s ON s.IsDeleted=0 AND s.ID_FracInfo = xI.ID_FracInfo and s.StageNo between xI.frStage and xi.toStage
			INNER JOIN dbo.Charge_Services		xCS ON xCS.ID_FracInfo = xI.ID_FracInfo AND xCS.ID_FracStage = s.ID_FracStage -- in (SELECT Item FROM [dbo].[SplitStrings_XML] (xI.IDs_FracStage,','))
			INNER JOIN dbo.LOS_ChargeServices	rS ON rS.ID_ChargeService = xCS.ID_Service

		GROUP BY xCS.ID_FracInfo
			, xI.InvoiceRange
			, xI.DateInvoice
			, xI.TicketNo, xI.WellName
			, rS.ServiceName 
			, xCS.ChargeCode
			, xCS.Service_Price
			, xCS.Charge_Unit
			, xCS.Service_Discount 
			, ISNULL(xI.Ticket_Discount, 0)

	/********* CHEMICALS :: 24 **************************************************/
	UNION ALL
	SELECT DISTINCT
		  ID_FracInfo	= xCC.ID_FracInfo
		, ID_ChargeType = 24
		, DateInvoice	= xI.DateInvoice
		
		, ChargeDesc	= ISNULL(xCC.Chemical_Desc,'')
		, ChargeCode	= xCC.ChargeCode
		, ChargeQty		= SUM(xCC.Chemical_Quantity)
		, ChargePrice	= xCC.Chemical_Price
		, ChargeUOM		= xCC.Charge_Unit
		, ChargeDiscount= xCC.Chemical_Discount + ISNULL(xI.Ticket_Discount, 0)
		, ChargeTotal	= SUM(xCC.Chemical_Cost)
						- CASE WHEN xCC.Chemical_Price > 0 
							THEN (SUM(xCC.Chemical_Cost) * ISNULL(xI.Ticket_Discount, 0)) --* -1
							ELSE 0 END 
		
		, item_Discount = xCC.Chemical_Discount
		, well_Discount = ISNULL(xI.Ticket_Discount, 0)

		--, InvoiceRange	= xI.InvoiceRange
		--, TicketNo		= xI.TicketNo
		--, WellName		= xI.WellName
		--, originalCharge = SUM(xCC.Chemical_Cost)
		--, addPercent	= ISNULL(xI.Ticket_Discount, 0)
		--, addDiscount	= CASE WHEN xCC.Chemical_Price > 0 
		--					THEN (SUM(xCC.Chemical_Cost) * ISNULL(xI.Ticket_Discount, 0)) --* -1
		--					ELSE 0 END 

		FROM @tbl_Invoices	xI -- [SSIS_ENG].[fnRPT_xmlTS_FracInvoices] ()	xI
			INNER JOIN dbo.FracStageSummary		s ON s.IsDeleted=0 AND s.ID_FracInfo = xI.ID_FracInfo and s.StageNo between xI.frStage and xI.toStage
			INNER JOIN dbo.Charge_Chemicals		xCC ON xCC.ID_FracInfo = xI.ID_FracInfo AND xCC.ID_FracStage = s.ID_FracStage -- in (SELECT Item FROM [dbo].[SplitStrings_XML] (xI.IDs_FracStage,','))

		GROUP BY xCC.ID_FracInfo
			, xI.InvoiceRange
			, xI.DateInvoice
			, xI.TicketNo, xI.WellName
			, xCC.Chemical_Desc
			, xCC.ChargeCode
			, xCC.Chemical_Price
			, xCC.Charge_Unit
			, xCC.Chemical_Discount 
			, ISNULL(xI.Ticket_Discount, 0)

	/********* PROPPANTS :: 25 **************************************************/
	UNION ALL
	SELECT DISTINCT
		  ID_FracInfo	= xPpt.ID_FracInfo
		, ID_ChargeType = 25
		, DateInvoice	= xI.DateInvoice
		
		, ChargeDesc	= ISNULL(xPpt.Proppant_Name,'')
		, ChargeCode	= xPpt.ChargeCode
		, ChargeQty		= SUM(xPpt.Customer_Quantity)
		, ChargePrice	= xPpt.Customer_Price
		, ChargeUOM		= xPpt.Customer_UOM
		, ChargeDiscount= xPpt.Proppant_Discount + ISNULL(xI.Ticket_Discount, 0)
		, ChargeTotal	= SUM(xPpt.Customer_Cost)
						- CASE WHEN xPpt.Customer_Price > 0 
							THEN (SUM(xPpt.Customer_Cost) * ISNULL(xI.Ticket_Discount, 0)) --* -1
							ELSE 0 END 
		
		, item_Discount = xPpt.Proppant_Discount
		, well_Discount = ISNULL(xI.Ticket_Discount, 0)
		
		--, InvoiceRange	= xI.InvoiceRange
		--, TicketNo		= xI.TicketNo
		--, WellName		= xI.WellName
		--, originalCharge	= SUM(xPpt.Customer_Cost)
		--, addPercent	= ISNULL(xI.Ticket_Discount, 0)
		--, addDiscount	= CASE WHEN xPpt.Customer_Price > 0 
		--					THEN (SUM(xPpt.Customer_Cost) * ISNULL(xI.Ticket_Discount, 0)) --* -1
		--					ELSE 0 END 
		FROM @tbl_Invoices	xI -- [SSIS_ENG].[fnRPT_xmlTS_FracInvoices] ()	xI
			INNER JOIN dbo.FracStageSummary		s ON s.IsDeleted=0 AND s.ID_FracInfo = xI.ID_FracInfo and s.StageNo between xI.frStage and xi.toStage
			INNER JOIN [dbo].Charge_Proppants	xPpt ON xPpt.ID_FracInfo = xI.ID_FracInfo AND xPpt.ID_FracStage = s.ID_FracStage -- in (SELECT Item FROM [dbo].[SplitStrings_XML] (xI.IDs_FracStage,','))

		GROUP BY xPpt.ID_FracInfo
			, xI.InvoiceRange
			, xI.DateInvoice
			, xI.TicketNo, xI.WellName
			, xPpt.Proppant_Name
			, xPpt.ChargeCode
			, xPpt.Customer_Price
			, xPpt.Customer_UOM
			, xPpt.Proppant_Discount 
			, ISNULL(xI.Ticket_Discount, 0)

	--/* INSERT Invoice Items */
	INSERT INTO [dbo].[FracInvoice_Items]
        ([ID_Invoice]
        ,[ID_FracInfo]
        ,[ID_ChargeType]
        ,[ChargeDesc]
        ,[ChargeCode]
        ,[ChargeQty]
        ,[ChargePrice]
        ,[ChargeUOM]
        ,[ChargeDiscount]
        ,[ChargeTotal]
        ,[item_Discount]
        ,[well_Discount])

	SELECT --ID_Invoice = (select top 1 id_invoice from dbo.FracInvoices t where t.IsDeleted = 0 and t.id_Fracinfo = i.ID_FracInfo and t.InvoiceRange = i.InvoiceRange)
		  v.ID_Invoice
		--, i.InvoiceRange
		, vI.ID_FracInfo
		, vI.ID_ChargeType
		, vI.[ChargeDesc]
        , vI.[ChargeCode]
        , ChargeQty		= ISNULL(vI.[ChargeQty],0)
        , vI.[ChargePrice]
        , vI.[ChargeUOM]
        , vI.[ChargeDiscount]
        , vI.[ChargeTotal]
        , vI.[item_Discount]
        , vI.[well_Discount]
		--, vI.*

		FROM @tbl_InvoiceItems vI
			inner join @tbl_Invoices	i ON i.ID_FracInfo = vI.ID_FracInfo AND i.DateInvoice = vI.DateInvoice

			left join dbo.FracInvoices	v ON v.IsDeleted = 0 AND v.ID_FracInfo = i.ID_FracInfo AND v.InvoiceRange = i.InvoiceRange


		WHERE v.ID_Invoice IS NOT NULL
			--AND vI.ChargeDesc IS NOT NULL

		ORDER BY i.InvoiceRange, vI.ID_ChargeType, vI.ChargeCode
	;

END

GO
