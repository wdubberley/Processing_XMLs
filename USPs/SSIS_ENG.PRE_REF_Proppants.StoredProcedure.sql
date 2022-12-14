USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[PRE_REF_Proppants]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/********************************************************************************
  20190509- Added additional filter to remove 'Screw' from proppant name
  20190609- Added additional correction to add Road Restrictions to PropStore&Handle desc
  20191022- Added additional correction to add Proppant handling & storage greater than 150 miles desc
  20191113- Added additional correction to add Proppant handling & storage between 50 and 100 desc
  20191217(v005)- Added additional correction to correct AlternateName in ('',0,NULL) to ChargeDescription
  20200121(v006)- Added additional correction for PropStore&Handle150
  20200217(v007)- Added additional correction for 51-75/76-100/101-125
*********************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[PRE_REF_Proppants]	
AS
BEGIN

	DECLARE @rValue AS INT;

	UPDATE [SSIS_ENG].[xmlImport_TS_FracQuotes]				/* 20191217 */
		SET AlternateName = ChargeDescription
		WHERE ChargeType='Proppant'
			AND ChargeDescription is not null AND (AlternateName IS NULL OR AlternateName = '' OR AlternateName = '0')

	UPDATE [SSIS_ENG].[xmlImport_TS_FracQuotes]
		SET AlternateName = 'PROPPANT - HANDLING & STORAGE GREATER THAN 150 MILES'
		WHERE ChargeType='Proppant'
			AND ChargeDescription like '%PROP%GREATER%150%' AND AlternateName NOT LIKE '%PROP%GREATER%150%'

	UPDATE [SSIS_ENG].[xmlImport_TS_ChargesProppants]
		SET Proppant_Desc = REPLACE(Proppant_Desc, 'PropStore&Handle150', 'PropStore&Handle')
		WHERE Proppant_Name LIKE '%PROP%GREATER%150%' AND Proppant_Desc NOT LIKE '%PROP%GREATER%150%'

	UPDATE [SSIS_ENG].[xmlImport_TS_ChargesProppants]
		SET Proppant_Desc = REPLACE(Proppant_Desc, 'PropStore&Handle', 'PROPPANT - HANDLING & STORAGE GREATER THAN 150 MILES')
		WHERE Proppant_Name LIKE '%PROP%GREATER%150%' AND Proppant_Desc NOT LIKE '%PROP%GREATER%150%'

	UPDATE [SSIS_ENG].[xmlImport_TS_ChargesProppants]
		SET Proppant_Desc = REPLACE(Proppant_Desc, 'PropStore&Handle150', 'PROPPANT - HANDLING & STORAGE GREATER THAN 150 MILES')
		WHERE Proppant_Name LIKE '%PROP%GREATER%150%' AND Proppant_Desc NOT LIKE '%PROP%GREATER%150%'

	UPDATE [SSIS_ENG].[xmlImport_TS_FracQuotes]
		SET AlternateName = 'PropStore&Handle - Road Restrictions'
		WHERE ChargeType='Proppant'
			AND ChargeDescription like '%PROP%ROAD%RESTRICTION%' AND AlternateName NOT LIKE '%PROP%ROAD%RESTRICTION%'

	UPDATE [SSIS_ENG].[xmlImport_TS_ChargesProppants]
		SET Proppant_Desc = REPLACE(Proppant_Desc, 'PropStore&Handle', 'PropStore&Handle - Road Restrictions')
		WHERE Proppant_Name LIKE '%PROP%ROAD%RESTRICTION%' AND Proppant_Desc NOT LIKE '%PROP%ROAD%RESTRICTION%'

	/****** PROPPANT HANDLING & STORAGE (51-75 miles) **************/
	UPDATE [SSIS_ENG].[xmlImport_TS_FracQuotes]
		SET AlternateName = 'PROPPANT HANDLING & STORAGE (51-75 miles)'
		WHERE ChargeType='Proppant'
			AND ChargeDescription like '%PROP%HAND%STORAGE%51%75%' AND AlternateName NOT LIKE '%PROP%HAND%STORAGE%51%75%'

	UPDATE [SSIS_ENG].[xmlImport_TS_ChargesProppants]
		SET Proppant_Desc = 'PROPPANT HANDLING & STORAGE (51-75 miles)'
		WHERE Proppant_Name LIKE '%PROP%HAND%STORAGE%51%75%' AND Proppant_Desc NOT LIKE '%PROP%HAND%STORAGE%51%75%'

	/****** PROPPANT HANDLING & STORAGE (76-100 miles) **************/
	UPDATE [SSIS_ENG].[xmlImport_TS_FracQuotes]
		SET AlternateName = 'PROPPANT HANDLING & STORAGE (76-100 miles)'
		WHERE ChargeType='Proppant'
			AND ChargeDescription like '%PROP%HAND%STORAGE%76%100%' AND AlternateName NOT LIKE '%PROP%HAND%STORAGE%76%100%'

	UPDATE [SSIS_ENG].[xmlImport_TS_ChargesProppants]
		SET Proppant_Desc = 'PROPPANT HANDLING & STORAGE (76-100 miles)'
		WHERE Proppant_Name LIKE '%PROP%HAND%STORAGE%76%100%' AND Proppant_Desc NOT LIKE '%PROP%HAND%STORAGE%76%100%'

	/****** PROPPANT HANDLING & STORAGE (101-125 miles) **************/
	UPDATE [SSIS_ENG].[xmlImport_TS_FracQuotes]
		SET AlternateName = 'PROPPANT HANDLING & STORAGE (101-125 miles)'
		WHERE ChargeType='Proppant'
			AND ChargeDescription like '%PROP%HAND%STORAGE%101%125%' AND AlternateName NOT LIKE '%PROP%HAND%STORAGE%101%125%'

	UPDATE [SSIS_ENG].[xmlImport_TS_ChargesProppants]
		SET Proppant_Desc = 'PROPPANT HANDLING & STORAGE (101-125 miles)'
		WHERE Proppant_Name LIKE '%PROP%HAND%STORAGE%101%125%' AND Proppant_Desc NOT LIKE '%PROP%HAND%STORAGE%101%125%'
	
	/****** PROPPANT HANDLING & STORAGE BETWEEN 50 AND 100 MILES **************/
	UPDATE [SSIS_ENG].[xmlImport_TS_FracQuotes]
		SET AlternateName = 'PROPPANT HANDLING & STORAGE BETWEEN 50 AND 100 MILES'
		WHERE ChargeType='Proppant'
			AND ChargeDescription like '%PROP%HAND%BETWEEN%50 AND 100%' AND AlternateName NOT LIKE '%PROP%HAND%BETWEEN%50 AND 100%'

	UPDATE [SSIS_ENG].[xmlImport_TS_ChargesProppants]
		SET Proppant_Desc = 'PROPPANT HANDLING & STORAGE BETWEEN 50 AND 100 MILES'
		WHERE Proppant_Name LIKE '%PROP%HAND%BETWEEN%50 AND 100%' AND Proppant_Desc NOT LIKE '%PROP%HAND%BETWEEN%50 AND 100%'

	UPDATE [SSIS_ENG].xmlImport_TS_ChargesProppants
		SET Proppant_Desc = Proppant_Name WHERE Proppant_Desc IS NULL AND Proppant_Name IS NOT NULL;

	WITH propCTE AS
		(SELECT DISTINCT xP.ProppantName
			FROM [SSIS_ENG].xmlImport_TS_FracProppants xP 
		UNION 
		SELECT DISTINCT REPLACE(REPLACE(xCP.Proppant_Desc, ' Actual Weight',''), ' Screw', '')
			FROM [SSIS_ENG].xmlImport_TS_ChargesProppants xCP
		UNION
		SELECT DISTINCT xMS.SandName
			FROM [SSIS_ENG].xmlImport_MAT_SandInfo xMS
		)

	INSERT INTO dbo.LOS_Proppants (ProppantName)

	SELECT DISTINCT xP.ProppantName

		FROM propCTE xP 
			LEFT JOIN dbo.LOS_Proppants lP ON lP.ProppantName = xP.ProppantName AND xP.ProppantName IS NOT NULL
		WHERE lP.ID_Proppant IS NULL

	/***** RECORD INSERT HISTORY *****/
	SET @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.LOS_Proppants', 'Insert', @rValue

END 



GO
