WITH AvgStd AS (
  SELECT
    AVG(CONVERT(BIGINT, RunTimeSeconds) ) AS avgnum,
    STDEVP(CONVERT(BIGINT, RunTimeSeconds)  ) AS stdnum
		  FROM [NeptuneIntegration].[dbo].[Unit] as U WITH (NOLOCK)  
			join [dbo].[CorporateCalendar] as C WITH (NOLOCK) on U.UnitPartitionKey = C.CLDR_YYYYMMDD_VAL 
			join [dbo].[FacilityLine] as FL WITH (NOLOCK) on FacilityLineGenID = U.FacilityLineID 
			join [dbo].[Facility] as F WITH (NOLOCK) on F.FacilityGenID = FL.FacilityID 
			join [dbo].[Product] as P WITH (NOLOCK) on U.ProductID = P.ProductGenID
			WHERE 
				[RunTimeSeconds] >= 0				
				AND U.UnitRunType in ('Production','Hardware') 		
				AND U.UnitStatus in ('PASS','Finished','Finished with Errors') 
				--AND U.IntegrationType IN ('L10') 
				AND F.FacilityType != 'Dell Test'  
				AND F.CodeName IS NOT NULL 			
				AND P.ProductFamily is not NULL 		
				AND P.LineOfBusiness is not NULL 			
				AND P.LineOfBusiness not in ('Alienware', 'Vostro', 'Inspiron Notebooks')	
				AND U.UnitIdentifier NOT IN (			
					'me45u84','ps6100e','ps6100x','ps6210e','ps6210x','ps6610e','sc100dl','sc120dl','sc180dl'		
					,'sc200dl','sc220dl','sc360dl','sc400dl','sc420dl','sc460dl')
				AND P.BusinessUnit = 'Dell Enterprise'
				--AND C.FISC_WEEK_VAL = '2020-W01'
				)

				SELECT 
				  MIN(CONVERT(BIGINT, RunTimeSeconds)) as MIN
				  ,MAX(CONVERT(BIGINT, RunTimeSeconds)) as MAX
				  ,count(*) as 'CNT'
				  ,'blank'
				  ,AVG(CONVERT(BIGINT, RunTimeSeconds)) as 'Ave BCT - 2 STD DEV'


						  FROM [NeptuneIntegration].[dbo].[Unit] as U WITH (NOLOCK)  
							join [dbo].[CorporateCalendar] as C WITH (NOLOCK) on U.UnitPartitionKey = C.CLDR_YYYYMMDD_VAL 
							join [dbo].[FacilityLine] as FL WITH (NOLOCK) on FacilityLineGenID = U.FacilityLineID 
							join [dbo].[Facility] as F WITH (NOLOCK) on F.FacilityGenID = FL.FacilityID 
							join [dbo].[Product] as P WITH (NOLOCK) on U.ProductID = P.ProductGenID
							CROSS JOIN AvgStd

							WHERE 
													 
								[RunTimeSeconds] >= 0				
								AND U.UnitRunType in ('Production','Hardware') 		
								AND U.UnitStatus in ('PASS','Finished','Finished with Errors') 
								--AND U.IntegrationType IN ('L10') 
								AND F.FacilityType != 'Dell Test'  
								AND F.CodeName IS NOT NULL 			
								AND P.ProductFamily is not NULL 		
								AND P.LineOfBusiness is not NULL 			
								AND P.LineOfBusiness not in ('Alienware', 'Vostro', 'Inspiron Notebooks')	
								AND U.UnitIdentifier NOT IN (			
									'me45u84','ps6100e','ps6100x','ps6210e','ps6210x','ps6610e','sc100dl','sc120dl','sc180dl'		
									,'sc200dl','sc220dl','sc360dl','sc400dl','sc420dl','sc460dl')
								AND P.BusinessUnit = 'Dell Enterprise'
								AND C.FISC_WEEK_VAL = '2020-W30'

								AND CONVERT(BIGINT, RunTimeSeconds)  < (avgnum + (2*stdnum))
								AND CONVERT(BIGINT, RunTimeSeconds)  > (avgnum - (2*stdnum));
