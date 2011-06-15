<?php
 
class ApiAnalyticsMetriccomscore_unique_visitors extends ApiAnalyticsMetric{
	
	
	protected $canBeNormalized = true;
	
	protected $name = "comscore_unique_visitors";
	
	protected function getAllowedFilterParams(){
		return array("select_regions", "select_countries");
	}
	
}

//Any additions go here