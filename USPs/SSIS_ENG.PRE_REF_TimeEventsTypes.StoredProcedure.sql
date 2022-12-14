USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[PRE_REF_TimeEventsTypes]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******************************************************
  Created:	KPHAM (2016)
  Modified: 20190206- Added inserts for TimeParty
*******************************************************/
CREATE PROCEDURE [SSIS_ENG].[PRE_REF_TimeEventsTypes]	
AS
BEGIN

	DECLARE @rValue AS INT 
		
	/***** TimeParty: PARTY (20190206) *****/
	INSERT INTO dbo.ref_TimeParties (ID_TimeType, PartyName)
	SELECT DISTINCT ID_TimeType = 0, PartyName = LTRIM(RTRIM(xT.[Party]))
		FROM [SSIS_ENG].xmlImport_TT_TimeLogs xT
			LEFT JOIN dbo.ref_TimeParties rParty ON LTRIM(RTRIM(xT.[Party])) = rParty.PartyName
		WHERE rParty.ID_TimeParty IS NULL AND LTRIM(RTRIM(xT.[Party])) IS NOT NULL

	SELECT @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.ref_TimeParties', 'Insert', @rValue;

	/***** TimeEvent: ALIAS *****/
	INSERT INTO dbo.ref_Alias (AliasName)
	SELECT DISTINCT LTRIM(RTRIM(xT.[Alias]))
		FROM [SSIS_ENG].xmlImport_TT_TimeLogs xT
			LEFT JOIN dbo.ref_Alias rAE ON LTRIM(RTRIM(xT.[Alias])) = rAE.AliasName
		WHERE rAE.ID_Alias IS NULL AND LTRIM(RTRIM(xT.[Alias])) IS NOT NULL

	SELECT @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.ref_Alias', 'Insert', @rValue;
	
	/***** TimeEvent: GENERAL MAIN EVENT *****/
	INSERT INTO dbo.ref_GenMainEvents (EventDesc)
	SELECT DISTINCT LTRIM(RTRIM(xT.[Gen Main Event]))
		FROM [SSIS_ENG].xmlImport_TT_TimeLogs xT
			LEFT JOIN dbo.ref_GenMainEvents rGE ON LTRIM(RTRIM(xT.[Gen Main Event])) = rGE.EventDesc
		WHERE rGE.ID_GenMainEvent IS NULL AND LTRIM(RTRIM(xT.[Gen Main Event])) IS NOT NULL

	SELECT @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.ref_GenMainEvents', 'Insert', @rValue;

	/***** TimeEvent: MAIN EVENT *****/
	INSERT INTO dbo.ref_TimeEvents (EventName)
	SELECT DISTINCT LTRIM(RTRIM(xT.[Main Event])) 
		FROM [SSIS_ENG].xmlImport_TT_TimeLogs xT
			LEFT JOIN dbo.ref_TimeEvents rME ON LTRIM(RTRIM(xT.[Main Event]))  = rME.EventName
		WHERE rME.ID_TimeEvent IS NULL AND LTRIM(RTRIM(xT.[Main Event])) IS NOT NULL
	
	SELECT @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.ref_TimeEvents', 'Insert', @rValue;
	
END 


GO
