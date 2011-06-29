<?php

class ApiAnalyticsMetricdump_new_registered_editors extends ApiAnalyticsMetric {


	protected $canBeNormalized = true;

	protected $name = "dump_new_registered_editors";

	protected function getAllowedFilterParams() {
		return array( "select_projects", "select_wikis" );
	}

}

// Any additions go here