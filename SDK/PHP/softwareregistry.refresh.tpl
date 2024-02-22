<?php
/**
 * EarthAsylum Consulting {eac} Software Registration - software registration command line refresh
 *
 * scheduled to run via crontab :
 * /path/to/php/php /path/to/html/classfolder/softwareregistry.refresh.php {registration_key}
 *
 * @category	WordPress Plugin
 * @package		{eac}SoftwareRegistry
 * @author		Kevin Burkholder <KBurkholder@EarthAsylum.com>
 * @copyright	Copyright (c) 2021 EarthAsylum Consulting <www.EarthAsylum.com>
 * @version		1.x
 */

include "softwareregistry.includes.php";

class <your_software_registry_productid>RegistrationRefresh implements \EarthAsylumConsulting\Interfaces\softwareregistry
{
	use \EarthAsylumConsulting\Traits\softwareregistry_<wordpress_or_filebased>;

	/**
	 * constructor method
	 *
	 * @param string current registration key
	 * @return 	void
	 */
	public function __construct(string $registrationKey = null)
	{
		return $this->refreshRegistration($registrationKey);
	}
}
return new <your_software_registry_productid>RegistrationRefresh($argv[0] ?: null);
