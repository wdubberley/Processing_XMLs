USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_Pads_Update_CorrectPadNo]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******************************************************************************************
  Created:	KPHAM (20201102)
  Desc:		Update & RecordHistory for changes on Pad_No
  20210215(v002)- Adjusted @uRecords validation on IF statement
******************************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_Pads_Update_CorrectPadNo]	
AS
BEGIN

	DECLARE @rValue AS INT = 0;
	
	DECLARE @tbl_Pads AS TABLE (Client VARCHAR(255), PadName VARCHAR(255), Pad_No INT, ID_Operator INT)
	INSERT INTO @tbl_Pads
	SELECT DISTINCT 
			  Client	= xTT.Customer
			, [PadName]	= xTT.Pad
			, Pad_No	= ISNULL(xTT.Pad_No, 0)
			, ID_Operator	= ISNULL(mO.ID_Operator, 0)

			FROM [SSIS_ENG].xmlImport_TT_TimeLogs				xTT
				INNER JOIN [SSIS_ENG].mapping_Customer_Operator	mO ON mO.Customer = xTT.Customer
				INNER JOIN [dbo].[LOS_Pads]						rP ON rP.Field_PadName = xTT.Pad AND rP.ID_Operator = ISNULL(mO.ID_Operator, 0)
	
	--select * from @tbl_Pads

	/******* Update Existing Pad_No from xmlTimeLogs (TimeTrackers) *******/
	DECLARE @rDate	AS DATETIME		= GETDATE()
		, @rLogin	AS VARCHAR(100) = ORIGINAL_LOGIN()
		, @rSource	AS VARCHAR(255) = '[SSIS_ENG].[Prepare_Pads_Update_PadNo]'	--This procedure's name
		, @rParams	AS VARCHAR(Max) = 'Update Project/Pad number(s)'	-- Description/etc.
		, @uRecords AS INT = 0
		, @rXML		AS XML 

	IF (SELECT COUNT(*) FROM @tbl_Pads) > 0
	BEGIN
		
		SET @uRecords = (SELECT COUNT(*) 
							FROM @tbl_Pads					xP
								INNER JOIN [dbo].[LOS_Pads]	rP ON rP.Field_PadName = xP.PadName AND rP.ID_Operator = xP.ID_Operator
							WHERE xP.Pad_No <> rP.Pad_No
						)

		SET @rParams = REPLACE(@rParams, 'Update', 'Update ' + CONVERT(VARCHAR(10),@uRecords))

		SET @rXML = (SELECT xP.[Client], xP.[PadName], xP.[Pad_No], xPad_No = rP.Pad_No, xP.[ID_Operator]	
						, [DateModified]= GETDATE()
						FROM @tbl_Pads xP 
							INNER JOIN [dbo].[LOS_Pads]	rP ON rP.Field_PadName = xP.PadName AND rP.ID_Operator = xP.ID_Operator
								WHERE xP.Pad_No <> rP.Pad_No

					FOR XML PATH ('PadInfo'), ROOT('LOS_Pads'))

	END

	IF @rXML IS NOT NULL 
	BEGIN
		/*** TEST SELECT 
		select @uRecords, @rParams, @rXML
		--**************************************/
		
		EXECUTE [History].[usp_History_XML] @rDate, @rLogin, @rSource, @rParams,@rXML

		IF @uRecords > 0
		BEGIN
				
			UPDATE rP 
				SET rP.Pad_No	= CASE WHEN xP.Pad_No IS NULL THEN 0 
									WHEN xP.Pad_No BETWEEN 0 AND 9999999 AND rP.Pad_No > 9999999 THEN rP.Pad_No
									ELSE xP.Pad_No END
			--select * 
				FROM @tbl_Pads					xP
					INNER JOIN [dbo].[LOS_Pads]	rP ON rP.Field_PadName = xP.PadName AND rP.ID_Operator = xP.ID_Operator

				WHERE xP.Pad_No <> rP.Pad_No

			--/***** RECORD INSERT HISTORY *****/
			SELECT @rValue = @@ROWCOUNT
			IF @rValue > 0 
				EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.LOS_Pads', 'Update-Pad/Project number', @rValue
		END
	END
	
END 

GO
