<?php

class ApiAnalyticsMetricdump_edits extends ApiAnalyticsMetric {


	protected $canBeNormalized = true;

	protected $name = "dump_active_edits";

	protected function getAllowedFilterParams() {
		return array( "select_projects", "select_wikis" );
	}

}

// Any additions go here