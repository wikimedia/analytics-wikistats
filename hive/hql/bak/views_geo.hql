USE wmf ;

SELECT
  s.*,
  count(*) AS count

FROM

 (SELECT 
--  x_analytics,
    year,
    month,
    day,
    hour,
    concat (year, '-', lpad(month,2,'0'), '-', lpad(day,2,'0'), ':', lpad(hour,2,'0'), '-', lpad(format_number (floor(minute(ts)/15)*15,0),2,'0')) as time_bin,
--  dt,
--  ts, -- unix timestamp in millisec, extracted from dt 
    access_method,
    geocoded_data['continent']    continent,
    geocoded_data['country_code'] country_code,
    geocoded_data['country']      country_name
--  is_pageview
--  CASE WHEN x_analytics LIKE '%https%' THEN 'https' ELSE 'http' END AS secure

  FROM
    webrequest
    TABLESAMPLE(BUCKET 1 OUT OF 100 ON rand())

  WHERE
        is_pageview 
    AND year=yyyy    -- '${hivevar:my_year}' 
    AND month=mm     -- ${hiveconf:my_month} 
    AND day=dd       -- ${hiveconf:my_day}
    AND hour=hh      -- ${hiveconf:my_hour}
  ) s

--WHERE
--    secure='secure'
--  country='China'

  GROUP BY 
    s.year,
    s.month,
    s.day,
    s.hour,
    s.time_bin,
--  s.min15,
--  s.dt,
--  s.ts,
--  s.ts2,
    s.access_method,
--  s.is_pageview,
    s.continent,
    s.country_code,
    s.country_name
--  s.secure,

  ORDER BY
    s.year,
    s.month,
    s.day,
    s.hour,
    s.time_bin,
--  s.min15,
--  s.dt,
--  s.ts,
--  s.ts2,
    s.access_method,
--  s.is_pageview,
    s.continent,
    s.country_code,
    s.country_name
--  s.secure,

LIMIT 10000000 ;
       
