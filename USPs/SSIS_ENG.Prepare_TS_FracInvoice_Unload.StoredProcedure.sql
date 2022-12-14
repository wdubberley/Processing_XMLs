USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_FracInvoice_Unload]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******************************************************************************
  Created: KPHAM (20210428)
******************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_FracInvoice_Unload]
AS
BEGIN 
	
	UPDATE v
		SET v.IsDeleted		= 1
			, v.DateModified= GETDATE()
			, v.ID_Status	= 5
			, v.DateStatus	= GETDATE()

	--select * 

		FROM [SSIS_ENG].[fnRPT_xmlTS_FracInvoices] () x
			INNER JOIN dbo.FracInvoices		v ON v.IsDeleted = 0 AND v.InvoiceRange = x.InvoiceRange
	;

END

GO
