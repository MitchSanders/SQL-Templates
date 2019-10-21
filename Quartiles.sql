WITH raw_data AS (
	Select P.BusinessUnit as series --Business Unit Client as a 'series'
			,U.RunTimeSeconds as value	-- BCT in seconds as the 'value'
		FROM [NeptuneIntegration].[dbo].[Unit] as U WITH (NOLOCK)  
				join [dbo].[CorporateCalendar] as C WITH (NOLOCK) on U.UnitPartitionKey = C.CLDR_YYYYMMDD_VAL 
				join [dbo].[FacilityLine] as FL WITH (NOLOCK) on FacilityLineGenID = U.FacilityLineID --left join [dbo].[vw_Facility] as F on U.FacilityLineID = F.[FacilityLineGenID]
				join [dbo].[Facility] as F WITH (NOLOCK) on F.FacilityGenID = FL.FacilityID 
				join [dbo].[Product] as P WITH (NOLOCK) on U.ProductID = P.ProductGenID

				WHERE  --apply existing business logic filters
					U.UnitRunType in ('Production','Hardware') 		
					AND U.UnitStatus in ('PASS','Finished','Finished with Errors') 
					AND U.IntegrationType IN ('L10') 
					AND U.RunTimeSeconds > 0	
					AND F.FacilityType != 'Dell Test'  -- exclude Vantage & testing 	
					AND F.CodeName IS NOT NULL -- have no CodeName, meaning Facility is unidentified			
					AND P.ProductFamily is not NULL 		
					AND P.LineOfBusiness is not NULL 			
					AND P.LineOfBusiness not in ('Alienware', 'Vostro', 'Inspiron Notebooks')	
					AND U.UnitIdentifier NOT IN (			
						'me45u84','ps6100e','ps6100x','ps6210e','ps6210x','ps6610e','sc100dl','sc120dl','sc180dl'		
						,'sc200dl','sc220dl','sc360dl','sc400dl','sc420dl','sc460dl'--APOS Generic tags; 2-5+ hours BCT each		
					)
					AND P.BusinessUnit = 'Dell Client' 
					--AND P.BusinessUnit = 'Dell Enterprise'
					--AND P.BusinessUnit = 'Storage & Solutions'
),

details AS (
    SELECT series,
           value,
           ROW_NUMBER() OVER (PARTITION BY series ORDER BY value) AS row_number,
           SUM(1) OVER (PARTITION BY series) AS total
      FROM raw_data
),

quartiles AS (
SELECT series,
       value,
       AVG(CASE WHEN row_number >= (FLOOR(total/2.0)/2.0) 
                 AND row_number <= (FLOOR(total/2.0)/2.0) + 1 
                THEN value/1.0 ELSE NULL END
          ) OVER (PARTITION BY series) AS q1,
       AVG(CASE WHEN row_number >= (total/2.0) 
                 AND row_number <= (total/2.0) + 1 
                THEN value/1.0 ELSE NULL END
          ) OVER (PARTITION BY series) AS median,
       AVG(CASE WHEN row_number >= (CEILING(total/2.0) + (FLOOR(total/2.0)/2.0))
                 AND row_number <= (CEILING(total/2.0) + (FLOOR(total/2.0)/2.0) + 1) 
                THEN value/1.0 ELSE NULL END
          ) OVER (PARTITION BY series) AS q3
  FROM details
)

SELECT series,
       MIN(value) AS minimum,
       AVG(q1) AS q1,
       AVG(median) AS median,
       AVG(q3) AS q3,
       MAX(value) AS maximum
  FROM quartiles
group by series
ORDER BY AVG(median)
