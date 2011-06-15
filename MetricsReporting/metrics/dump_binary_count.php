<?php

class ApiAnalyticsMetricdump_binary_count extends ApiAnalyticsMetric{
	
	
	protected $canBeNormalized = true;
	
	protected $name = "dump_binary_count";
	
	protected function getAllowedFilterParams(){
		return array("select_projects", "select_wikis");
	}
	
}

//Any additions go here