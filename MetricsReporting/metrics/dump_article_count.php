<?php

class ApiAnalyticsMetricdump_article_count extends ApiAnalyticsMetric{
	
	
	protected $canBeNormalized = true;
	
	protected $name = "dump_article_count";
	
	protected function getAllowedFilterParams(){
		return array("select_projects", "select_wikis");
	}
	
}

//Any additions go here