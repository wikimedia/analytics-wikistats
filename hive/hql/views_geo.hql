USE wmf ;

SELECT
  s.continent,
  s.country_name,
  s.country_code,
  s.project wiki,
  s.access_method,
  s.time_bin,
  count(*) AS count

FROM

 (SELECT 
    year,
    month,
    day,
    hour,
    concat (year, '-', lpad(month,2,'0'), '-', lpad(day,2,'0'), ':', lpad(hour,2,'0'), '-', lpad(format_number (floor(minute(ts)/15)*15,0),2,'0')) as time_bin,
    access_method,
    geocoded_data['continent']        continent,
    geocoded_data['country_code']     country_code,
    geocoded_data['country']          country_name,
    pageview_info['project']          project

  FROM
    webrequest
--  TABLESAMPLE(BUCKET 1 OUT OF 10 ON rand())

  WHERE
        is_pageview 
    AND year=2015    -- '${hivevar:my_year}' 
    AND month=11     -- ${hiveconf:my_month} 
    AND day=1       -- ${hiveconf:my_day}
    AND hour=1      -- ${hiveconf:my_hour}


  GROUP BY 
    s.continent,
    s.country_code,
    s.country_name,
    s.project,
    s.access_method,
    s.time_bin

  ORDER BY
    s.continent,
    s.country_code,
    s.country_name,
    s.project,
    s.access_method,
    s.time_bin

LIMIT 10000000 ;
       
