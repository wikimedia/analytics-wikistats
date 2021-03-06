USE wmf ;

SELECT 
  event_user_text_latest,
  count (event_user_text_latest) count

FROM 
  mediawiki_history

WHERE 
      snapshot     = '2017-08'
  AND wiki_db      = 'afwiki'
  AND event_entity = 'revision'
  AND page_namespace_latest = 0
  AND NOT revision_is_deleted   

GROUP BY
  event_user_text_latest

ORDER BY
  count DESC,
  event_user_text_latest

LIMIT 10000 ; 
