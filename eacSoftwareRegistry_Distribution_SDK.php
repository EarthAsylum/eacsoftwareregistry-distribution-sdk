<?php
/**
 * EarthAsylum Consulting {eac} Software Registration Server - Distribution SDK
 *
 * @category	WordPress Plugin
 * @package		{eac}SoftwareRegistry Distribution SDK
 * @author		Kevin Burkholder <KBurkholder@EarthAsylum.com>
 * @copyright	Copyright (c) 2024 EarthAsylum Consulting <www.earthasylum.com>
 * @uses		{eac}SoftwareRegistry
 *
 * @wordpress-plugin
 * Plugin Name:	        {eac}SoftwareRegistry Distribution SDK
 * Description:	        Software Registration Server Distribution SDK - generate custom PHP packages that can be include in your project to register your product with your registration server.
 * Version:	            1.1.2
 * Requires at least:   5.8
 * Tested up to:        6.8
 * Requires PHP:        7.4
 * Plugin URI:        	https://swregistry.earthasylum.com/software-registry-sdk/
 * Author:				EarthAsylum Consulting
 * Author URI:			http://www.earthasylum.com
 * License: 			GPLv3 or later
 * License URI: 		https://www.gnu.org/licenses/gpl.html
 * Text Domain:			eacSoftwareRegistry
 * Domain Path:			/languages
 */

/**
 * This simple plugin file responds to the 'eacSoftwareRegistry_load_extensions' filter to load additional extensions.
 * Using this method prevents overwriting extensions when the plugin is updated or reinstalled.
 */

namespace EarthAsylumConsulting;

define('EAC_SOFTWARE_REGISTRY_SDK', dirname(__FILE__));

class eacSoftwareRegistry_Distribution_SDK
{
	/**
	 * constructor method
	 *
	 * @return	void
	 */
	public function __construct()
	{
		/**
		 * eacSoftwareRegistry_load_extensions - get the extensions directory to load
		 *
		 * @param 	array	$extensionDirectories - array of [plugin_slug => plugin_directory]
		 * @return	array	updated $extensionDirectories
		 */
		add_filter( 'eacSoftwareRegistry_load_extensions',	function($extensionDirectories)
			{
				/*
    			 * Enable update notice (self hosted or wp hosted)
    			 */
				eacSoftwareRegistry::loadPluginUpdater(__FILE__,'wp');

				/*
    			 * Add links on plugins page
    			 */
				add_filter( 'plugin_action_links_' . plugin_basename( __FILE__ ),function($pluginLinks, $pluginFile, $pluginData)
					{
						return array_merge(
							[
								'settings'		=> eacSoftwareRegistry::getSettingsLink($pluginData,'distribution'),
								'documentation'	=> eacSoftwareRegistry::getDocumentationLink($pluginData),
								'support'		=> eacSoftwareRegistry::getSupportLink($pluginData),
							],
							$pluginLinks
						);
					},20,3
				);

				/*
    			 * Add our extension to load
    			 */
				$extensionDirectories[ plugin_basename( __FILE__ ) ] = [plugin_dir_path( __FILE__ )];
				return $extensionDirectories;
			}
		);
	}
}
new \EarthAsylumConsulting\eacSoftwareRegistry_Distribution_SDK();
?>
