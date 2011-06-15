<?php

if ( !defined( 'MEDIAWIKI' ) ) {
	// Eclipse helper - will be ignored in production
	require_once( 'ApiBase.php' );
}


class ApiAnalytics extends ApiBase {
	
	public function execute() {
		
			global $wgeAnalyticsMetricsList;
			$params = $this->extractRequestParams();
			$result = $this->getResult();

			foreach($wgeAnalyticsMetricsList as $metricName){
				if($metricName == $params["metric"]){
					$metricClassName = "ApiAnalyticsMetric$metricName";
					$metric = new $metricClassName;
					$filterParams = $metric->getAllowedFilterParams();
					$queries = array();
					foreach($filterParams as $filterParam){
						if(isset( $params["$filterParam"])){
							$queries= array_merge($queries, $this->collectQueryFilters($filterParam, $params["$filterParam"]));
						}
					}
					
					$range = " DATE = {$params["months"]}"; //TODO: query
					
					if(strpos($params["months"],";") !== FALSE){
						$rangeVals = explode($params["months"], ";");
						$range = " DATE >= $rangeVals[0]  AND DATE <= $rangeVals[1]";
					}
					
					foreach($queries as &$query){
						$query = $query . " AND " . $range;
						
						if($metric->canBeNormalized){
							$result->addValue("","normalized","false");
							//TODO: modify queries for normalization
							if(isset($params["normalized"]) && (strpos($params["normalized"], "true") !== FALSE)){
							//is normalized
							$result->addValue("","normalized","true");
							}
						}
							
					}
					
					$language = $params["report_language"];
					
					$dbr = wfAnalyticsMetricConnection();
					//TODO: build return object from queries
					
					
					
				}
			}
	}


	//override with vars for individual metrics
	protected function collectQueryFilters($field, $fieldVal){
		global $wgeAnalyticsFieldNames;
		
		//get rid of any potential whitespace
		$param = preg_replace('/\s\s+/', '', $fieldVal);
		$returnQueries = array();
		
		if(!isset ($wgeAnalyticsFieldNames["$field"]) ){
			return $returnQueries;
		}
		
		$fieldName = $wgeAnalyticsFieldNames["$field"];
		
		$sub_queries = explode(",", $param); 
		foreach($sub_queries as $sub_query){
			$topval = 0;
			if(strpos($sub_query,"top:") !== FALSE){
				$topval = (int)	substr($sub_query, strpos($sub_query,"top:") + 4);
			}
			
			if(strpos($sub_query,"+") !== FALSE ){
				$and_params = explode("+", $sub_query);
				foreach($and_params as $and_param){
						$this->validate_atomic_param($and_param, $field);
					}
					$returnQueries[] = "$filedName = $sub_query ";  //TODO: This is not what the query means
			}
			else{
				if(!$topval){
					//TODO:check for {project}:{lang} (ie wp:en) style here
					
					$this->validate_atomic_param($sub_query, $field);
					$returnQueries[] = "$fieldName = $sub_query ";		
				}
				else{
					$returnQueries[] = "$fieldName < $topval"; //TODO: This is not what this query means
				}
			}
		}
		return $returnQueries;
	}
	
	protected function validate_atomic_param($param, $field){
		global $wgeAnalyticsValidParams;
		if(isset($wgeAnalyticsValidParams["$field"])  && count($wgeAnalyticsValidParams["$field"])  > 0){
			if(count( array_keys($wgeAnalyticsValidParams["$field"], $param)   ) > 0){
				return true;
			} else {
				return false;
			}
		}
		return true;
	}
}