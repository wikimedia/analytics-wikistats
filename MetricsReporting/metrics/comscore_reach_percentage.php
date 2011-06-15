<?php
 
class ApiAnalyticsMetriccomscore_reach_percentage extends ApiAnalyticsMetric{
	
	
	protected $canBeNormalized = true;
	
	protected $name = "comscore_reach_percentage";
	
	protected function getAllowedFilterParams(){
		return array("select_regions", "select_countries");
	}
	
}

//Any additions go here