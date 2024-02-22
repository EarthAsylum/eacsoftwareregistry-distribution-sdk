<?php
namespace EarthAsylumConsulting\Traits;

/**
 * EarthAsylum Consulting {eac} Software Registration - software registration API trait for file-based transients
 *
 * uses common code from softwareregistry_interface trait
 *
 * @category	WordPress Plugin
 * @package		{eac}SoftwareRegistry
 * @author		Kevin Burkholder <KBurkholder@EarthAsylum.com>
 * @copyright	Copyright (c) 2021 EarthAsylum Consulting <www.EarthAsylum.com>
 * @version		1.x
 */

trait softwareregistry_filebased
{
	use softwareregistry_interface;

	/**
	 * add filebased registry hooks
	 *
	 * @return void
	 */
	public function addSoftwareRegistryHooks()
	{
	}


	/**
	 * get the next refresh event
	 *
	 * @return object|bool scheduled event or false
	 */
	public function nextRegistryRefreshEvent(string $registrationKey=null)
	{
		$result = $this->getKeyFilePath(self::SOFTWARE_REGISTRY_OPTION);
		if (is_file($result) && ($result = \file_get_contents($result)))
		{
			return unserialize($result);
		}
		return false;
	}


	/**
	 * check/verify the next refresh event
	 *
	 * @return void
	 */
	public function checkRegistryRefreshEvent(string $registrationKey=null)
	{
		if ($result = $this->nextRegistryRefreshEvent($registrationKey))
		{
			if ($result->timestamp < time())
			{
				$this->refreshRegistration($result->registry_key);
			}
		}
		else if ($registrationKey)
		{
			$this->refreshRegistration($registrationKey);
		}
	}


	/**
	 * schedule the next refresh event
	 *
	 * @param int $secondsFromNow time in seconds in the future
	 * @param string $schedule hourly, daily, twicedaily, weekly
	 * @param object $registration (registry_*) values
	 * @return bool
	 */
	public function scheduleRegistryRefresh(int $secondsFromNow, string $schedule, $registration)
	{
		// schedule a future event that will execute -
		//		$this->refreshRegistration($registration->registry_key);
		// at time() + $secondsFromNow and/or on every $schedule

		// otherwise, checkRegistryRefreshEvent() checks the expiration time and triggers refreshRegistration()
	}


	/**
	 * get a path to key file
	 *
	 * @param string file name
	 * @return string
	 */
	private function getKeyFilePath(string $fileName)
	{
		static $keyFilePath = null;

		if ($fileName) $fileName = '.'.ltrim($fileName,'.').'_'.self::SOFTWARE_REGISTRY_READ_KEY;
		if (empty($keyFilePath))
		{
			while (true)
			{
				if (function_exists('getenv'))
				{
					$keyFilePath = rtrim( (getenv('HOME', true) ?: getenv('HOME')), DIRECTORY_SEPARATOR);
					if ($keyFilePath && is_writable($keyFilePath))
					{
						break;
					}

					$keyFilePath = rtrim( (getenv('USERPROFILE', true) ?: getenv('USERPROFILE')), DIRECTORY_SEPARATOR);
					if ($keyFilePath && is_writable($keyFilePath))
					{
						break;
					}
				}

				if (isset($_SERVER) && isset($_SERVER['DOCUMENT_ROOT']))
				{
					$keyFilePath = rtrim($_SERVER['DOCUMENT_ROOT'],DIRECTORY_SEPARATOR);
					if ($keyFilePath && is_writable($keyFilePath))
					{
						break;
					}
				}

				$keyFilePath = rtrim(__DIR__, DIRECTORY_SEPARATOR);
				if ($keyFilePath && is_writable($keyFilePath))
				{
					break;
				}
			}
		}
		return $keyFilePath . DIRECTORY_SEPARATOR . $fileName;
	}


	/**
	 * get a path to cache file
	 *
	 * @param string file name
	 * @return string
	 */
	private function getCacheFilePath(string $fileName)
	{
		static $cacheFilePath = null;

		if ($fileName) $fileName = '.'.ltrim($fileName,'.').'_'.self::SOFTWARE_REGISTRY_READ_KEY;
		if (empty($cacheFilePath))
		{
			while (true)
			{
				if (function_exists('getenv'))
				{
					$cacheFilePath = rtrim( (getenv('TMP', true) ?: getenv('TMP')), DIRECTORY_SEPARATOR);
					if ($cacheFilePath && is_writable($cacheFilePath))
					{
						break;
					}

					$cacheFilePath = rtrim( (getenv('TMPDIR', true) ?: getenv('TMPDIR')), DIRECTORY_SEPARATOR);
					if ($cacheFilePath && is_writable($cacheFilePath))
					{
						break;
					}

					$cacheFilePath = rtrim( (getenv('TEMP', true) ?: getenv('TEMP')), DIRECTORY_SEPARATOR);
					if ($cacheFilePath && is_writable($cacheFilePath))
					{
						break;
					}
				}

				$cacheFilePath =  rtrim(sys_get_temp_dir(), DIRECTORY_SEPARATOR);
				break;
			}
		}
		return $cacheFilePath . DIRECTORY_SEPARATOR . $fileName;
	}


	/**
	 * get the current registration key
	 *
	 * @param string registration key
	 * @return string
	 */
	public function getRegistrationKey(string $registrationKey=null)
	{
		if (!empty($registrationKey))
		{
			return $registrationKey;
		}
		$result = $this->getKeyFilePath(self::SOFTWARE_REGISTRY_OPTION);
		if (is_file($result) && ($result = \file_get_contents($result)))
		{
			$result = unserialize($result);
			return $result->registry_key;
		}
		return null;
	}


	/**
	 * get registration cache
	 *
	 * @return	array
	 */
	public function getRegistrationCache()
	{
		$result = $this->getCacheFilePath(self::SOFTWARE_REGISTRY_TRANSIENT);
		if (is_file($result) && ($result = \file_get_contents($result)))
		{
			$result = unserialize($result);
			if ($result->timestamp  < time())
			{
				\unlink($this->getCacheFilePath(self::SOFTWARE_REGISTRY_TRANSIENT));
				return null;
			}
			return $result->registry_data;
		}
		return null;
	}


	/**
	 * set registration cache
	 *
	 * @param object $registration
	 * @return	void
	 */
	public function setRegistrationCache($registration)
	{
		// save the registration key
		\file_put_contents(
			$this->getKeyFilePath(self::SOFTWARE_REGISTRY_OPTION),
			serialize((object)[
				'registry_key'	=> $registration->registration->registry_key,
				'hook'      	=> self::SOFTWARE_REGISTRY_REFRESH,
				'timestamp' 	=> time()+$registration->registrar->refreshInterval,
				'interval'  	=> $registration->registrar->refreshInterval,
				'args'      	=> $registration->registration->registry_key,

			])
		);
		// save the registration data
		\file_put_contents(
			$this->getCacheFilePath(self::SOFTWARE_REGISTRY_TRANSIENT),
			serialize((object)[
				'registry_data'	=> $registration,
				'hook'      	=> self::SOFTWARE_REGISTRY_REFRESH,
				'timestamp' 	=> time()+$registration->registrar->cacheTime,
				'interval'  	=> $registration->registrar->cacheTime,
				'args'      	=> $registration->registration->registry_key,
			])
		);

		/**
		 * callback {productid}_update_registration
		 * @param array $registration registration object
		 */
		if (method_exists($this,self::SOFTWARE_REGISTRY_PRODUCTID.'_update_registration'))
		{
			call_user_func_array([$this,self::SOFTWARE_REGISTRY_PRODUCTID.'_update_registration'],[$registration]);
		}
	}


	/**
	 * purge registration cache
	 *
	 * @return	void
	 */
	public function purgeRegistrationCache()
	{
		// delete the registration key
		unlink($this->getKeyFilePath(self::SOFTWARE_REGISTRY_OPTION));
		// delete the registration data
		unlink($this->getCacheFilePath(self::SOFTWARE_REGISTRY_TRANSIENT));

		/**
		 * callback {productid}_purge_registration
		 */
		if (method_exists($this,self::SOFTWARE_REGISTRY_PRODUCTID.'_purge_registration'))
		{
			call_user_func_array([$this,self::SOFTWARE_REGISTRY_PRODUCTID.'_purge_registration']);
		}
	}


	/**
	 * API remote request - remote http request (wp_remote_request or curl)
	 *
	 * @param	string	$endpoint create, activate, deactivate, verify
	 * @param	string	$remoteUrl remote Url
	 * @param	array 	$request api request
	 * @return	object api response (decoded)
	 */
	public function api_remote_request($endpoint,$remoteUrl,$request)
	{
		/**
		 * callback {productid}_api_remote_request()
		 * @param	array $request ['method'=>, 'timeout'=>, 'redirection'=>, 'sslverify'=>, 'headers'=>, 'body'=>]
		 * @param	string $endpoint create, activate, deactivate, verify, refresh, revise
		 * @return	array request body
		 */
		if (method_exists($this,self::SOFTWARE_REGISTRY_PRODUCTID.'_api_remote_request'))
		{
			$request = call_user_func_array([$this,self::SOFTWARE_REGISTRY_PRODUCTID.'_api_remote_request'],[$request, $endpoint]);
		}

		$headers = array();
		foreach ($request['headers'] as $key => $value) {
			$headers[] = "{$key}: {$value}";
		}

		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, $remoteUrl); 							// remote url
		curl_setopt($ch, CURLOPT_FOLLOWLOCATION, 1);						// allow redirection
		curl_setopt($ch, CURLOPT_MAXREDIRS, $request['redirection']);		// max redirects
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);						// return results as string
		curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $request['method']); 		// http method
		curl_setopt($ch, CURLOPT_TIMEOUT, $request['timeout']);				// max time in seconds
		curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, $request['sslverify']);	// don't verify ssl certs
		curl_setopt($ch, CURLOPT_HTTPHEADER, $headers); 					// headers ['Content-Type: application/json']
		if (!in_array($request['method'],['GET','HEAD','DELETE'])) {
			curl_setopt($ch, CURLOPT_POSTFIELDS, $request['body']); 		// body
		}

		$result = curl_exec($ch);
		$error	= false;
		$code	= curl_getinfo($ch,CURLINFO_HTTP_CODE);

		if (empty($result)) {
			$error = [$code,curl_error($ch),$code,curl_error($ch)];
		} else {
			$body = json_decode($result);
			if (isset($body->code) && isset($body->message)) {
				$error = [$code,curl_error($ch),$body->code,$body->message];
			}
		}

		if ($error)
		{
			$error 	= json_decode('{"status":{"code":"'.$error[0].'","message":"'.addslashes($error[1]).'"},'.
								 '"error":{"code":"'.$error[2].'","message":"'.addslashes($error[3]).'"}}');
			/**
			 * callback {productid}_api_remote_error
			 * @param	object {status:{}, error: {}}
			 * @param	array $request ['method'=>, 'timeout'=>, 'redirection'=>, 'sslverify'=>, 'headers'=>, 'body'=>]
			 * @param	string $endpoint create, activate, deactivate, verify, refresh, revise
			 */
			if (method_exists($this,self::SOFTWARE_REGISTRY_PRODUCTID.'_api_remote_error'))
			{
				call_user_func_array([$this,self::SOFTWARE_REGISTRY_PRODUCTID.'_api_remote_error'],[$error, $request, $endpoint]);
			}

			return $error;
		}

		/**
		 * callback {productid}_api_remote_response()
		 * @param	array $body response body
		 * @param	array $request ['method'=>, 'timeout'=>, 'redirection'=>, 'sslverify'=>, 'headers'=>, 'body'=>]
		 * @param	string $endpoint create, activate, deactivate, verify, refresh, revise
		 */
		if (method_exists($this,self::SOFTWARE_REGISTRY_PRODUCTID.'_api_remote_response'))
		{
			call_user_func_array([$this,self::SOFTWARE_REGISTRY_PRODUCTID.'_api_remote_response'],[$body, $request, $endpoint]);
		}
		/**
		 * callback {productid}_api_remote_$endpoint()
		 * @param	array $body response body
		 * @param	array $request ['method'=>, 'timeout'=>, 'redirection'=>, 'sslverify'=>, 'headers'=>, 'body'=>]
		 * @param	string $endpoint create, activate, deactivate, verify, refresh, revise
		 */
		if (method_exists($this,self::SOFTWARE_REGISTRY_PRODUCTID.'_api_remote_'.$endpoint))
		{
			call_user_func_array([$this,self::SOFTWARE_REGISTRY_PRODUCTID.'_api_remote_'.$endpoint],[$body, $request, $endpoint]);
		}

		return $body;
	}


	/**
	 * is API error
	 *
	 * @param	string	$apiResponse
	 * @return	bool
	 */
	public function is_api_error($apiResponse)
	{
		return ($apiResponse->status->code != '200');
	}
}
?>
