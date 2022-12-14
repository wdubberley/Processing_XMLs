USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[PRE_REF_ChargeServices]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [SSIS_ENG].[PRE_REF_ChargeServices]	
AS
BEGIN

	DECLARE @rValue AS INT;
	
	WITH serviceCTE AS
		(SELECT DISTINCT xC.ServiceName
			FROM [SSIS_ENG].xmlImport_TS_ChargesServices xC 
		)

	INSERT INTO dbo.LOS_ChargeServices (ServiceName)

	SELECT xS.ServiceName 
		FROM serviceCTE xS
			LEFT JOIN dbo.LOS_ChargeServices lCS ON lCS.ServiceName = xS.ServiceName AND xS.ServiceName IS NOT NULL
		WHERE lCS.ID_ChargeService IS NULL;

	/***** RECORD INSERT HISTORY *****/
	SET @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.LOS_ChargeServices', 'Insert', @rValue;

END 

GO
