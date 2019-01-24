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