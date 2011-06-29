<?php

class ApiAnalyticsMetricdump_active_editors_100 extends ApiAnalyticsMetric {


	protected $canBeNormalized = true;

	protected $name = "dump_active_editors_100";

	protected function getAllowedFilterParams() {
		return array( "select_projects", "select_wikis" );
	}

}

// Any additions go here