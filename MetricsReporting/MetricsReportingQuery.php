<?php
class MetricsReportingQuery {

	public $query = "";
	public $queryProperties = array();

	public function __construct() {
	}

	public function __construct( $initial_query, $initial_prop_name, $initial_prop_value ) {
		$this->query = $initial_query;
		$this->queryProperties = array( $initial_prop_name => $initial_prop_value );
	}

	public function mergeWith( MetricsReportingQuery $queryObj ) {
		$this->query = $this->query . $queryObj->query;
		$this->queryProperties = array_merge( $this->queryProperties, $queryObj->queryProperties );
	}
}