USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[PRE_Process_XMLs_FracStages_Update]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [SSIS_ENG].[PRE_Process_XMLs_FracStages_Update]	
AS
BEGIN

	/******* Update PERF_Company (2017.01.18) *******/
	SET NOCOUNT ON
	UPDATE SSIS_ENG.xmlImport_TS_FracStages
		SET PERF_Company	= CASE WHEN PERF_Company IN ('Perf X','Perf-X') THEN 'PerfX' 
								WHEN PERF_Company IN ('Cutter','Cutter Wireline Services','Cutters') THEN 'Cutters Wireline Service Inc' 
								WHEN PERF_Company IN ('ENP') THEN 'E&P' 
								WHEN PERF_Company IN ('MBI') THEN 'MBI Energy Services' 
								WHEN PERF_Company IN ('9 Wireline','Nine') THEN 'Nine Energy Service' 
								WHEN PERF_Company IN ('Dynasty') THEN 'Dynasty Wireline Services' 
								WHEN PERF_Company IN ('GR','GR Energy') THEN 'GR Energy Services' 
								ELSE PERF_Company END
		WHERE PERF_Company IS NOT NULL
	
	UPDATE xS	/*20180215*/
		SET Supervisor		= CASE WHEN Supervisor IS NOT NULL THEN LTRIM(RTRIM(Supervisor)) ELSE NULL END
			, Engineer		= CASE WHEN Engineer IS NOT NULL THEN LTRIM(RTRIM(Engineer)) ELSE NULL END
			, CustomerRep	= CASE WHEN CustomerRep IS NOT NULL THEN LTRIM(RTRIM(CustomerRep)) ELSE NULL END
			, QAQC			= CASE WHEN QAQC IS NOT NULL THEN LTRIM(RTRIM(QAQC)) ELSE NULL END
		FROM SSIS_ENG.xmlImport_TS_FracStages xS
		WHERE Supervisor is not null or Engineer is not null or CustomerRep is not null or QAQC is not null

	SET NOCOUNT OFF
	
	/******* Update Crew name if it is missing from any line *******/
	UPDATE fxS
		SET Crew	= CASE WHEN fxS.ID_Crew IS NULL
							THEN (SELECT TOP 1 t.Crew FROM SSIS_ENG.xmlImport_TS_FracStages t 
									WHERE t.WellName=fxS.WellName AND t.Crew is not null AND t.Crew <> '0') ELSE fxS.Crew END

	--select *
		--, CASE WHEN fxS.ID_Crew IS NULL
		--		THEN (SELECT TOP 1 t.Crew FROM ssis.xmlImport_TechSheets t WHERE t.WellName=fxS.WellName AND t.Crew is not null) ELSE fxS.Crew END
		FROM SSIS_ENG.fnRPT_xmlTS_FracStages() fxS
			
		WHERE (fxS.id_crew is null)


	;

END 

GO
