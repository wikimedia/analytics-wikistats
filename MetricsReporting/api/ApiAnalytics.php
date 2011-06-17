<?php

if ( !defined( 'MEDIAWIKI' ) ) {
	// Eclipse helper - will be ignored in production
	require_once( 'ApiBase.php' );
}


class ApiAnalytics extends ApiBase {
	
	public function execute() {
		
			global $wgeAnalyticsMetricsList, $wgeAnalyticsFieldReturns;
			$params = $this->extractRequestParams();
			$result = $this->getResult();

			foreach($wgeAnalyticsMetricsList as $metricName){
				//find the metric requested
				if($metricName == $params["metric"]){
					
					//instantiate the class and an empty array of metricsreportingquery objects
					$metricClassName = "ApiAnalyticsMetric$metricName";
					$metric = new $metricClassName;
					$filterParams = $metric->getAllowedFilterParams();
					$queries = array();
					
					//check to see which filters are set
					foreach($filterParams as $filterParam){
						if(isset( $params["$filterParam"])){
							$filter_results = $this->collectQueryFilters($filterParam, $params["$filterParam"]);
							
							//if multiple results returned, merge each of the query objects with whatever exists
							if (count($filter_results) > 1){
								foreach ($filter_results as $result){
									foreach ($queries as $queryObj){
										$result->merge($queryObj);
									}
								}
								$queries = $filter_results;		
							}
							//else just merge with the only object
							else{
								foreach($queries as &$queryObj){
									$queryObj->merge($filter_results[0]);
								}
							}
						} //endif
					}//end filters
					
					//calculate time
					$range = " DATE = {$params["months"]}"; //TODO: query
					$minDate = $params["months"];
					if(strpos($params["months"],";") !== FALSE){
						$rangeVals = explode($params["months"], ";");
						$range = " DATE >= $rangeVals[0]  AND DATE <= $rangeVals[1]";
						$minDate = $rangeVals[0];
					}
					$timeStart = 0;
					if(($timeStart = strtotime($str)) !== false){
						$result->addValue("","timeStart",strfmttime("%Y%m%d%H%M%S",$timeStart));
					}
					
					//foreach query
					foreach($queries as &$queryObj){
						$queryObj->query = $queryObj->query . " AND " . $range;
						
						foreach($queryObj->queryProperties as $filterName => $filterVal){
							$result->addValue("", $filterName, $filterVal); //filters
						}
						
						if($metric->canBeNormalized){
							//TODO: modify queries for normalization
							if(isset($params["normalized"]) && (strpos($params["normalized"], "true") !== FALSE)){
							//is normalized
								$result->addValue("","normalized","true");
							} else {
								$result->addValue("","normalized","false");	
							}
							
							
							if(isset($params["modailty"]) && (strpos($params["modality"], "indexed") !== FALSE)){
								//modify query for indexed
								$result->addValue("","modality","indexed");
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
		$returnQueries = array(new MetricsReportingQuery);
		
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
					$returnQueries[] = new MetricsReportingQuery("$filedName = $sub_query ",
					$fieldName,$sub_query);;  //TODO: This is not what the query means
			}
			else{
				if(!$topval){
					//TODO:check for {project}:{lang} (ie wp:en) style here
					
					$this->validate_atomic_param($sub_query, $field);
					$returnQueries[] = new MetricsReportingQuery("$fieldName = $sub_query ", //TODO: this might be what this query means
					$fieldName, $sub_query);		
				}
				else{
					$returnQueries[] = new MetricsReportingQuery("$fieldName < $topval", //TODO: This is not what this query means
					$fieldName, $topval); 
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

	public function getVersion() {
		return __CLASS__ . ': $Id$';
	}
}