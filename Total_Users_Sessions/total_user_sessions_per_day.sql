--Note: Below query is written against PostgresSQL DB 9.6

--Task: Write an SQL statement to find the total number of user sessions each page has each day

--Get the total_user_sessions per day and per page 
SELECT
      page_id,
      visit_date,
      COUNT(*) AS total_user_sessions
FROM
    public.page_views
GROUP BY
    page_id,
    visit_date
ORDER BY
    page_id ASC
;