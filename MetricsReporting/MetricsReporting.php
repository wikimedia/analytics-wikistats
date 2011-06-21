<?php 

$wgeAnalyticsFieldNames = array(
	'select_regions' => "REGION",
	'select_countries' => "COUNTRY",
	'select_web_projects' => "WEBPROJ",
	'select_wikis' => "WIKI",
	'select_editors' => "EDITOR",
	'select_edits' => "EDITS",
	'select_platform' => "MOBILE",
);

$wgeAnalyticsFieldReturns = array(
	'select_regions' => "region",
	'select_countries' => "country",
	'select_web_projects' => "web project",
	'select_wikis' => "wiki",
	'select_editors' => "editors",
	'select_edits' => "edits",
	'select_platform' => "mobile",
);


$wgeAnalyticsValidParams = array(

"select_regions" => array(
	"AS" => "Asia Pacific",
	"C" => "China",
	"EU" => "Europe",
	"I"  => "India",
	"LA" => "Latin-America",
	"MA" => "Middle-East/Africa",
	"NA" => "North-America",
	"US" => "United States",
	"W" => "World",
),
//"select_countries" => array(),
//"select_web_properties"=> array(),
"select_projects"=> array(
	"wb" => "Wikibooks",
	"wk" => "Wiktionary",
	"wn" => "Wikinews",
	"wp" => "Wikipedia",
	"wq" => "Wikiquote",
	"ws" => "Wikisource",
	"wv" => "Wikiversity",
	"co" => "Commons",
	"wx" => "Other projects", 
),
//"select_wikis"=> array(),
"select_editors"=> array(
	"A" => "Anonymous",
	"R" => "Registered User",
	"B" => "Bot",
),
"select_edits"=> array(
	"M" => "Manual",
	"B" => "Bot",
),
"select_platform"=> array(
	"M" => "Moblie",
	"N" => "Non-Mobile",
),

);

$dir = dirname( __FILE__ );
$wgAutoloadClasses['ApiAnalytics'] = $dir . '/api/ApiAnalytics.php';
$wgAutoloadClasses['ApiAnalyticsMetric'] = $dir . '/api/ApiAnalyticsMetric.php';
$wgAutoloadClasses['MetricsReportingQuery'] = $dir . '/MetricsReportingQuery.php';

$wgeAnalyticsMetricsList = array();
$metricsdir = $dir."/metrics";
$dh = opendir($metricsdir);
while( ($file = readdir($dh)) !== false){
	if(filetype($metricsdir."/".$file) == "file" ){
		$file_path_parts = pathinfo($metricsdir."/".$file);
		if($file_path_parts['extension'] == 'php'){
			$wgAutoloadClasses["ApiAnalyticsMetric{$file_path_parts['filename']}"] = $metricsdir."/".$file;
			$wgeAnalyticsMetricsList[] = $file_path_parts['filename'];
		}
	}
}


$wgAPIModules['analytics'] = 'ApiAnalytics';



function wfAnalyticsMetricConnection() {
	global $wgeAnalyticsMetricDBserver, $wgeAnalyticsMetricDBname;
	global $wgeAnalyticsMetricDBuser, $wgeAnalyticsMetricDBpassword;
	
	static $db;
	
	if ( !$db ) {
		$db = new DatabaseMysql(
		$wgeAnalyticsMetricDBserver,
		$wgeAnalyticsMetricDBuser,
		$wgeAnalyticsMetricDBpassword,
		$wgeAnalyticsMetricDBname );
		$db->query( "SET names utf8" );
	}
	
	return $db;
}
 
