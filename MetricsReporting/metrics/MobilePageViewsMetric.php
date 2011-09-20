<?php

/**
 *
 */
class MobilePageViewsMetric extends GenericMetricBase {

	protected $tableName = 'mobilepageviews';

	public function getDescription() {
		return "Number of mobile page views";
	}

	protected function getExamples() {
		return "";
	}
}
