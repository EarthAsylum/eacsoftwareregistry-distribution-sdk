<?php
namespace EarthAsylumConsulting\Interfaces;

/**
 * EarthAsylum Consulting {eac} Software Registration - software registration API interface
 *
 * implemented by softwareregistry_interface with softwareregistry_wordpress or softwareregistry_filebased
 *
 * @category	WordPress Plugin
 * @package		{eac}SoftwareRegistry
 * @author		Kevin Burkholder <KBurkholder@EarthAsylum.com>
 * @copyright	Copyright (c) 2021 EarthAsylum Consulting <www.EarthAsylum.com>
 * @version		1.x
 */

interface softwareregistry
{
	/**
	 * @var the product id for this registration interface
	 * used in the api and the option/transient names
	 */
	const SOFTWARE_REGISTRY_PRODUCTID   = '<your_software_registry_productid>';

	/**
	 * @var string registration server remote api url
	 * the registration server url
	 */
	const SOFTWARE_REGISTRY_HOST_URL	= '<your_software_registry_host_url>';

	/**
	 * @var string registration server unique create key
	 * used when creating a new registration
	 */
	const SOFTWARE_REGISTRY_CREATE_KEY	= '<your_software_registry_create_key>';

	/**
	 * @var string registration server unique update key
	 * used when updating (activate/deactivate) a registration
	 */
	const SOFTWARE_REGISTRY_UPDATE_KEY	= '<your_software_registry_update_key>';

	/**
	 * @var string registration server unique read key
	 * used when verifying a registration
	 */
	const SOFTWARE_REGISTRY_READ_KEY	= '<your_software_registry_read_key>';

	/**
	 * @var string option name for plugin registry key
	 * name used when storing the registration key
	 */
	const SOFTWARE_REGISTRY_OPTION		= self::SOFTWARE_REGISTRY_PRODUCTID.'_registry_key';

	/**
	 * @var string transient name for plugin registry data
	 * name used when storing the registration information
	 */
	const SOFTWARE_REGISTRY_TRANSIENT	= self::SOFTWARE_REGISTRY_PRODUCTID.'_registry_data';

	/**
	 * @var string event name for registry refresh event
	 * name used when scheduling the next refresh/verify action
	 */
	const SOFTWARE_REGISTRY_REFRESH		= self::SOFTWARE_REGISTRY_PRODUCTID.'_registry_refresh';

	/**
	 * @var string the version number of the software registry API
	 * used when code changes require version checks
	 */
	const SOFTWARE_REGISTRY_API_VERSION	= '1.0.0';


	/**
	 * get the registration server's api create key
	 *
	 * @return string
	 */
	public function getApiCreateKey();


	/**
	 * get the registration server's api update key
	 *
	 * @return string
	 */
	public function getApiUpdateKey();


	/**
	 * get the registration server's api read key
	 *
	 * @return string
	 */
	public function getApiReadKey();


	/**
	 * get the registration server's api endpoint URL
	 *
	 * @param string $endpoint one of 'create', 'activate', 'deactivate', 'verify'
	 * @return string
	 */
	public function getApiEndPoint(string $endpoint = null);


	/**
	 * add registry hooks
	 *
	 * @return void
	 */
	public function addSoftwareRegistryHooks();


	/**
	 * get the next refresh event
	 *
	 * @return object|bool scheduled event or false
	 */
	public function nextRegistryRefreshEvent(string $registrationKey=null);


	/**
	 * check/verify the next refresh event
	 *
	 * @return void
	 */
	public function checkRegistryRefreshEvent(string $registrationKey=null);


	/**
	 * schedule the next refresh event, forces refresh from registration server
	 *
	 * @param int $secondsFromNow time in seconds in the future
	 * @param string $schedule hourly, daily, twicedaily, weekly
	 * @param array $registration (registry_*) values
	 * @return bool
	 */
	public function scheduleRegistryRefresh(int $secondsFromNow, string $schedule, $registration);


	/**
	 * is the current registry information valid
	 *
	 * @param string registration key
	 * @return bool
	 */
	public function isValidRegistration(string $registrationKey=null);


	/**
	 * get or check the value of a registry key
	 *
	 * @example $this->isRegistryValue('license');
	 * @example $this->isRegistryValue('license', 'L3', 'ge');
	 *
	 * @param string $keyName the key name (sans prefix) of the registry value
	 * @param string $value the value to compare
	 * @param string $compare the comparison to make (=,<,>,<=,>=)
	 * @return bool|mixed
	 */
	public function isRegistryValue(string $keyName, $value=null, string $compare='=');


	/**
	 * get the current registration key
	 *
	 * @param string registration key
	 * @return string
	 */
	public function getRegistrationKey(string $registrationKey=null);


	/**
	 * get registry information from the storage (transient) or api refresh
	 *
	 * @param string registration key
	 * @return string
	 */
	public function getCurrentRegistration(string $registrationKey=null);


	/**
	 * refresh registry information from the remote registration server
	 *
	 * @param string registration key
	 * @return string
	 */
	public function refreshRegistration(string $registrationKey=null, array $registrationValues=[]);


	/**
	 * get registration cache
	 *
	 * @return	array
	 */
	public function getRegistrationCache();


	/**
	 * set registration cache
	 *
	 * @param object $registration
	 * @return	void
	 */
	public function setRegistrationCache($registration);


	/**
	 * purge registration cache
	 *
	 * @return	void
	 */
	public function purgeRegistrationCache();


	/**
	 * remote API request - builds request array and calls api_remote_request
	 *
	 * @param	string	$endpoint
	 * @param	array	$params api parameters
	 * @return	object api response (decoded)
	 */
	public function registryApiRequest($endpoint,$params);


	/**
	 * API remote request - remote http request (wp_remote_request or curl)
	 *
	 * @param	string	$endpoint create, activate, deactivate, verify
	 * @param	string	$remoteUrl remote Url
	 * @return	object api response (decoded)
	 */
	public function api_remote_request($endpoint,$remoteUrl,$request);


	/**
	 * is API error
	 *
	 * @param	string	$apiResponse
	 * @return	bool
	 */
	public function is_api_error($apiResponse);
}
?>
