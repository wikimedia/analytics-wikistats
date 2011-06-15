<?php

class ApiAnalyticsMetricsquid_page_views extends ApiAnalyticsMetric{
	
	
	protected $canBeNormalized = true;
	
	protected $name = "squid_page_views";
	
	protected function getAllowedFilterParams(){
		return array("select_regions", "select_countries", "select_web_properties", "select_projects", "select_wikis", "select_platform"
		);
	}
	
}

//Any additions go here