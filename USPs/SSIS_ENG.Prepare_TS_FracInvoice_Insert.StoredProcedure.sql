USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_FracInvoice_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******************************************************************************
  Created: KPHAM (20210426)
  202010501(v002)- Adjusted VersionNo
******************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_FracInvoice_Insert]
AS
BEGIN 

	INSERT INTO [dbo].[FracInvoices]
		([ID_FracInfo]
		,[InvoiceRange]
		,[frStage]
		,[toStage]
		,[DateInvoice]
		,[IDs_FracStage]
		--,[DateCreated]
		,[VersionNo]
		--,[IsDeleted]
		--,[ID_Status]
		--,[DateStatus]
		--,[DateModified]
		)
	SELECT ID_FracInfo  = x.ID_FracInfo
		, InvoiceRange	= x.InvoiceRange
		, frStage		= x.frStage
		, toStage		= x.toStage
		, DateInvoice	= x.DateInvoice
		, IDs_FracStage =  STUFF((SELECT DISTINCT ',' + CONVERT(NVARCHAR(15),t.[ID_FracStage]) -- Add a comma (,) before each value
								FROM [dbo].[FracStageSummary] t 
								WHERE t.IsDeleted = 0 AND t.ID_FracInfo = x.ID_FracInfo AND t.StageNo BETWEEN x.frStage AND x.toStage
								GROUP BY t.ID_FracInfo, t.ID_FracStage--, t.[StageNo]
								--ORDER BY CONVERT(NVARCHAR(15),t.[ID_FracStage])
							FOR XML PATH('') -- Select it as XML
							), 1, 1, '' )
		, VersionNo		= 1 ----MAX(ISNULL(fV.VersionNo, 0)) + 1
						+ ISNULL((SELECT COUNT(*) 
									FROM [dbo].[FracInvoices]	t 
									WHERE t.ID_FracInfo = x.ID_FracInfo AND t.InvoiceRange = x.InvoiceRange)
								, 0)

		FROM [SSIS_ENG].[fnRPT_xmlTS_FracInvoices] ()	x
			LEFT JOIN dbo.FracInvoices					fV ON fV.IsDeleted = 0 AND fV.ID_FracInfo = x.ID_FracInfo AND fV.InvoiceRange = x.InvoiceRange

		WHERE fV.ID_Invoice IS NULL

		GROUP BY x.ID_FracInfo
			, x.InvoiceRange
			, x.frStage
			, x.toStage
			, x.DateInvoice

		ORDER BY x.ID_FracInfo
			, x.frStage
			, x.toStage
	;

END

GO
