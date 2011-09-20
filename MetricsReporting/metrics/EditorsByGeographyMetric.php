<?php

/**
 *
 */
class EditorsByGeographyMetric extends GenericMetricBase {

	protected $tableName = 'editorsbygeography';

	public function getDescription() {
		return "Number of active unique registered editors by country";
	}

	protected function getExamples() {
		return "";
	}
}
