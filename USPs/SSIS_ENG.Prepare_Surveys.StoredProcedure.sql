USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_Surveys]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*********************************************************
  20181126- Change formula to calculate OverallAverage from each column instead of reading values from XML
  20190603- Changed formula to not calculate OverallAverage for items that is NULL
  20190610- Updated code to also update CustomerRept/Supervisor when update
  20190917(v004)- Modified calculation to OverallAverage to NULL when no grade is given by customer
  20220117(v005)- Switch USP name from [SSIS_ENG].[Prepare_CustomerSurveys_v2017]
**********************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_Surveys]	
AS
BEGIN
	IF	Object_ID('TempDB..#tmpCustomerSurveys')	IS NOT NULL	DROP TABLE #tmpCustomerSurveys
	CREATE TABLE #tmpCustomerSurveys(
			[ID_Record]		[INT] NOT NULL,
			[ID_FracInfo]	[INT] NULL,
			[ID_Pad]		[INT] NULL,
			[ID_Crew]		[INT] NULL,
			[SurveyOrder]	[SMALLINT] NULL,
			[Operator]		[varchar](255) NULL,
			[Pad]			[varchar](255) NULL,
			[Well_Name]		[varchar](255) NULL,
			[Ticket_No]		[nvarchar](50) NULL,
			[Basin]			[varchar](255) NULL,
			[Crew]			[varchar](50) NULL,
			[Date_Survey]	[smalldatetime] NULL,
			[gradeTotal]	[float] NULL,
			[gradeCount]	[INT] NOT NULL DEFAULT(1))

	DECLARE @rValue AS INT;

	INSERT INTO #tmpCustomerSurveys
	SELECT ID_Record
			,ID_FracInfo, eI.ID_Pad, rC.ID_Crew
			, SurveyOrder	= RANK() OVER(PARTITION BY Ticket_No ORDER BY Date_Survey, ID_Record)
			,[Operator],[Pad],[Well_Name]
			,[Ticket_No]	= CASE WHEN CHARINDEX('-', Ticket_No,1) = 0 THEN Ticket_No
								ELSE SUBSTRING(Ticket_No,CHARINDEX('-', Ticket_No,1)+1, LEN(TIcket_No)) END
			,[Basin]
			,[Crew]
			,[Date_Survey]
			,[gradeTotal]	= ISNULL(xCS.Crew_Performance,0) 
							+ ISNULL(xCS.Safety_Functions,0) 
							+ ISNULL(xCS.Job_Site,0) 

							+ ISNULL(xCS.Crew_Preparedness,0) 
							+ ISNULL(xCS.Promptness,0) 
							+ ISNULL(xCS.Equipment,0) 
							+ ISNULL(xCS.Materials,0) 
							+ ISNULL(xCS.Recommendations_Provided,0) 
							
							+ ISNULL(xCS.Appearance,0) 
							+ ISNULL(xCS.Professionalism,0) 
							+ ISNULL(xCS.Correct_Services,0) 
							+ ISNULL(xCS.Service_Performance,0) 
							+ ISNULL(xCS.Job_Performance,0)
			,[gradeCount]	= CASE WHEN xCS.Crew_Performance IS NULL THEN 0 ELSE 1 END
							+ CASE WHEN xCS.Safety_Functions IS NULL THEN 0 ELSE 1 END
							+ CASE WHEN xCS.Job_Site IS NULL THEN 0 ELSE 1 END

							+ CASE WHEN xCS.Crew_Preparedness IS NULL THEN 0 ELSE 1 END
							+ CASE WHEN xCS.Promptness IS NULL THEN 0 ELSE 1 END
							+ CASE WHEN xCS.Equipment IS NULL THEN 0 ELSE 1 END
							+ CASE WHEN xCS.Materials IS NULL THEN 0 ELSE 1 END
							+ CASE WHEN xCS.Recommendations_Provided IS NULL THEN 0 ELSE 1 END
							
							+ CASE WHEN xCS.Appearance IS NULL THEN 0 ELSE 1 END
							+ CASE WHEN xCS.Professionalism IS NULL THEN 0 ELSE 1 END
							+ CASE WHEN xCS.Correct_Services IS NULL THEN 0 ELSE 1 END
							+ CASE WHEN xCS.Service_Performance IS NULL THEN 0 ELSE 1 END
							+ CASE WHEN xCS.Job_Performance IS NULL THEN 0 ELSE 1 END
							--13

		FROM [SSIS_ENG].[xmlImport_CustomerSurveys] xCS
			LEFT JOIN dbo.LOS_Wells		rW ON rW.WellName = xCS.Well_Name
			LEFT JOIN dbo.FracInfo		eI ON eI.ID_Well	= rW.ID_Well
												AND eI.LOS_ProjectNo = CASE WHEN CHARINDEX('-', Ticket_No,1) = 0 THEN Ticket_No
																		ELSE SUBSTRING(Ticket_No,CHARINDEX('-', Ticket_No,1)+1, LEN(TIcket_No)) END 
			INNER JOIN dbo.ref_Crews	rC ON rC.CrewName = xCS.Crew OR rC.CrewNameAlt = xCS.Crew

		WHERE xCS.Pad IS NOT NULL

		--select * from #tmpCustomerSurveys

	 UPDATE e
		SET e.ID_Crew			= t.ID_Crew
			, e.SurveyOrder		= t.SurveyOrder
			, e.DateSurvey		= x.Date_Survey
			, Customer_Representative	= x.Customer_Representative
			, Supervisor				= x.Supervisor

			, e.CrewPerformance		= x.Crew_Performance
			, e.SafetyFunctions		= x.Safety_Functions
			, e.JobSite				= x.Job_Site

			, e.CrewPreparedness	= x.Crew_Preparedness
			, e.Promptness			= x.Promptness
			, e.Equipment			= x.Equipment
			, e.Materials			= x.Materials
			, e.RecommendationsProvided	= x.Recommendations_Provided

			, e.Appearance			= x.Appearance
			, e.Professionalism		= x.Professionalism
			, e.CorrectServices		= x.Correct_Services
			, e.ServicePerformance	= x.Service_Performance
			, e.JobPerformance		= x.Job_Performance

			--, e.OverallAverage		= x.OVERALL_AVERAGE
			, e.OverallAverage		= CASE WHEN t.gradeCount = 0 THEN NULL ELSE t.gradeTotal / t.gradeCount END					--13
			, e.Comments			= x.Comments
			, e.DateModified		= GETDATE()
	--select * 
		FROM #tmpCustomerSurveys t
			INNER JOIN [SSIS_ENG].xmlImport_CustomerSurveys	x ON x.ID_Record = t.ID_Record
			INNER JOIN dbo.CustomerSurveys					e ON e.ID_FracInfo = t.ID_FracInfo AND e.SurveyOrder = t.SurveyOrder
	--*********************** END UPDATE MATCHING Surveys ***************************************/

	--/***** RECORD UPDATE HISTORY **********************************************************************
	SET @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.CustomerSurveys', 'Update', @rValue
	--*********************** END RECORD UPDATE HISTORY ***************************************/

	--/***** BEGIN INSERT new Surveys **********************************************************************
	INSERT INTO [dbo].[CustomerSurveys]
        ([ID_FracInfo],[ID_Crew],[ID_Pad]
        ,[SurveyOrder],[DateSurvey],[Customer_Representative],[Supervisor]

        ,[CrewPerformance],[SafetyFunctions],[JobSite],[CrewPreparedness]
        ,[Promptness],[Equipment],[Materials],[RecommendationsProvided]
        ,[Appearance],[Professionalism],[CorrectServices],[ServicePerformance]
        ,[JobPerformance],[OverallAverage],[Comments]
        ,[LoadingNote],[DateModified])
           
	SELECT ID_FracInfo		= t.ID_FracInfo
		, ID_Crew			= t.ID_Crew
		, ID_Pad			= t.ID_Pad
		, SurveyOrder		= t.SurveyOrder
		, DateSurvey		= t.Date_Survey
		, Customer_Representative	= x.Customer_Representative
		, Supervisor				= x.Supervisor

		, Crew_Performance	= x.Crew_Performance
		, Safety_Functions	= x.Safety_Functions
		, JobSite			= x.Job_Site

		, Crew_Preparedness = x.Crew_Preparedness
		, Promptness		= x.Promptness
		, Equipment			= x.Equipment
		, Materials			= x.Materials
		, Recommendations_Provided	= x.Recommendations_Provided
		
		, Appearance		= x.Appearance
		, Professionalism	= x.Professionalism
		, Correct_Services	= x.Correct_Services
		, ServicePerformance	= x.Service_Performance
		, JobPerformance	= x.Job_Performance

		, OverallAverage	= CASE WHEN t.gradeCount = 0 THEN NULL ELSE t.gradeTotal / t.gradeCount END					--13
		, Comments			= x.Comments
		, LoadingNote		= CONVERT(VARCHAR(10),GETDATE(),101) 
							+ '- Dataload file ' + x.FilePath
		, DateModified		= GETDATE()
		
		FROM #tmpCustomerSurveys t
			INNER JOIN [SSIS_ENG].xmlImport_CustomerSurveys	x ON x.ID_Record = t.ID_Record
			LEFT JOIN dbo.CustomerSurveys				e ON e.ID_FracInfo = t.ID_FracInfo AND e.SurveyOrder = t.SurveyOrder

		WHERE e.ID_Survey IS NULL 
			AND t.ID_FracInfo IS NOT NULL 

	--/***** RECORD INSERT HISTORY *****
	SET @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.CustomerSurveys', 'Insert', @rValue
	--*****************************************************************************************************/

END 

GO
