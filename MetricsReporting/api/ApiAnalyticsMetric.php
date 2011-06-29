<?php

abstract class ApiAnalyticsMetric {


	protected $canBeNormalized = false;

	protected $name = null;

	protected function getAllowedFilterParams() {
		return array();
	}



}


