USE wmf ;

SELECT 
  page_title_latest,
  page_namespace_latest
--  page_namespace_is_content_latest

FROM 
  mediawiki_history

WHERE 
      snapshot     = '2017-08'
  AND wiki_db      = 'afwiki'
  AND event_entity = 'page'
  AND page_namespace_latest = 12 
--AND page_title_latest = 'Andy_Warhol'

GROUP BY
  page_title_latest,
  page_namespace_latest

ORDER BY
  page_title_latest,
  page_namespace_latest



LIMIT 10000 ; 
