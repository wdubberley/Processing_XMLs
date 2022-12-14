USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_FracInfo_CorrectTicketNo]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******************************************************************
  20200728(v001)- Set update for TaskNo automatically
  20200810(v002)- Added log XML to track ticket number changes
  20210219(v003)- Changed xI.TaskNo to compare with nvarchar quotes
*******************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_FracInfo_CorrectTicketNo]	
AS
BEGIN

	DECLARE @tblTS_Tickets TABLE (
		[ID_FracInfo]	[INT] NOT NULL,
		[ID_Pad]		[INT] NOT NULL,
		[ID_Well]		[INT] NOT NULL,
		[Client]		[VARCHAR](255) NULL,
		[Pad_No]		[INT] NULL,
		[PadName]	[VARCHAR](255) NULL,	
		[WellName]	[VARCHAR](255) NULL,	
		[TaskNo]	[NVARCHAR](100) NULL,	
		[TicketNo]	[NVARCHAR](100) NULL,
		[xmlFileName]	[NVARCHAR](255) NULL	
	)

	INSERT INTO @tblTS_Tickets
	SELECT vW.ID_FracInfo, xI.ID_Pad, xI.ID_Well
		, rP.Client, rP.Pad_No--, rP.Field_PadName
		, xI.PadName, xI.WellName, vW.LOS_Ticket_Number, xI.TicketNo
		, xI.xmlFileName
	
		FROM [SSIS_ENG].[fnRPT_xmlTS_FracInfo] ()	xI
			INNER JOIN [dbo].[fnREFs_Pads] ('')	rP ON rP.Field_PadName = xI.Pad_Name and (DATEDIFF(DD, rP.tTo, GETDATE()) <= 31 or rP.flag_recent = 1)
			INNER JOIN [Engineering].[vw_TechSheet_WellInfo] vW ON vW.Pad_Name = xI.PadName AND vW.Well_Name = xI.WellName
			
		WHERE (vW.LOS_Ticket_Number < '100000' AND xI.TaskNo > '100000')
			--OR (vW.LOS_Ticket_Number <> xI.TaskNo)
		

	--select * from @tblTS_Tickets

	DECLARE @rDate	AS DATETIME		= GETDATE()
		, @rLogin	AS VARCHAR(100) = ORIGINAL_LOGIN()
		, @rSource	AS VARCHAR(255) = '[SSIS_ENG].[Prepare_TS_FracInfo_CorrectTicketNo]'	--This procedure's name
		, @rParams	AS VARCHAR(Max) = 'Update Ticket/Task number(s)'	-- Description/etc.
		, @uRecords AS INT = 0
		, @rXML		AS XML 

	IF (SELECT COUNT(*) FROM @tblTS_Tickets) > 0
	BEGIN
		--select ChargeCode from dbo.Charge_Chemicals

		SET @uRecords = (SELECT COUNT(*) FROM @tblTS_Tickets)

		SET @rParams = REPLACE(@rParams, 'Update', 'Update ' + CONVERT(VARCHAR(10),@uRecords))

		SET @rXML = (SELECT [ID_FracInfo],[ID_Pad],[ID_Well]
						, [Client], [Pad_No], [PadName],[WellName]	
						, [TaskNo],	[TicketNo], [xmlFileName]
						, [DateModified]= GETDATE()
						FROM @tblTS_Tickets t 

					FOR XML PATH ('TicketInfo'), ROOT('FracInfo'))
	END

	IF @rXML IS NOT NULL 
	BEGIN
		/*** TEST SELECT 
		select @uRecords, @rParams, @rXML
		select * 
			from @tblTS_Tickets t INNER JOIN [dbo].[FracInfo] fI ON fI.ID_FracInfo = t.ID_FracInfo
		--**************************************/
		
		EXECUTE [History].[usp_History_XML] @rDate, @rLogin, @rSource, @rParams,@rXML

		IF @uRecords > 0
		BEGIN
			DECLARE @rValue AS INT = 0;

			UPDATE fI SET fI.LOS_ProjectNo = t.[TicketNo]
			--select * 
				FROM @tblTS_Tickets t
					INNER JOIN [dbo].[FracInfo] fI ON fI.ID_FracInfo = t.ID_FracInfo

			SET @rValue = ISNULL(@@ROWCOUNT, 0)

			IF @rValue > 0 EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.FracInfo', 'Update-TicketNo', @rValue;
		END
	END
		
END 


GO
