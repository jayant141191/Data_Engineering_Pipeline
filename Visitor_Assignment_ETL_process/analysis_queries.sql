--Note: Below queries are written against PostgresSQL DB 9.6

--Task: What are the total number users assigned to the “Test” and “Control” groups in each experiment?

--Get the total number users assigned to the Test and Control groups in each experiment
SELECT 
     assignment_grp, 
	 experiment, 
	 COUNT(*) AS no_of_users
FROM (
		SELECT 
			   message, 
			   DATE(date_timestamp) AS date_logged, 
			   CASE 
				  WHEN POSITION('test' IN message) > 0 THEN 'test'
				  WHEN POSITION('control' IN message) > 0 THEN 'control' 
				  ELSE ''
			   END AS assignment_grp,
			   TRIM(SUBSTRING(message, 'MS-\d+')) AS experiment
		FROM 
			public.visitor_info
) AS a
GROUP BY
  assignment_grp, 
  experiment
ORDER BY 
    assignment_grp ASC, 
	experiment ASC
;

--Task: Which day had the highest number of user group assignments per experiment?

--Get the day that had the highest number of user group assignments per experiment
SELECT 
      experiment, 
      date_logged AS day_highest_group_assign
FROM (
		SELECT 
			 date_logged,
			 experiment, 
			 no_of_user_grp_assign,
			 DENSE_RANK() OVER (PARTITION BY experiment ORDER BY no_of_user_grp_assign DESC) AS rank
		FROM (
				SELECT 
					   date_logged, 
					   experiment, 
					   COUNT(*) AS no_of_user_grp_assign
				FROM (
					SELECT 
						 message, 
						 DATE(date_timestamp) AS date_logged, 
						 CASE 
						 WHEN POSITION('test' IN message) > 0 THEN 'test'
						 WHEN POSITION('control' IN message) > 0 THEN 'control' 
						 ELSE ''
						 END AS assignment_grp,
						 TRIM(SUBSTRING(message, 'MS-.*')) AS experiment
					FROM 
					   public.visitor_info
			 ) AS a
			GROUP BY
			   date_logged, 
			   experiment
	) AS b
) AS c
WHERE 
   rank = 1
ORDER BY 
    experiment ASC,
    day_highest_group_assign ASC 
;



