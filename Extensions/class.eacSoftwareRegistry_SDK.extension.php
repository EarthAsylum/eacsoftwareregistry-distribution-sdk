<?php
namespace EarthAsylumConsulting\Extensions;

/**
 * EarthAsylum Consulting {eac} Software Registration Server - Distribution SDK
 *
 * @category	WordPress Plugin
 * @package		{eac}SoftwareRegistry
 * @author		Kevin Burkholder <KBurkholder@EarthAsylum.com>
 * @copyright	Copyright (c) 2023 EarthAsylum Consulting <www.earthasylum.com>
 * @version		1.x
 */

class eacSoftwareRegistry_distribution_SDK extends \EarthAsylumConsulting\abstract_extension
{
	/**
 	 * @trait methods for creating zip archive
 	 */
	use \EarthAsylumConsulting\Traits\zip_archive;

	/**
	 * @var string extension version
	 */
	const VERSION	= '23.0608.1';


	/**
	 * constructor method
	 *
	 * @param 	object	$plugin main plugin object
	 * @return 	void
	 */
	public function __construct($plugin)
	{
		parent::__construct($plugin, self::ALLOW_ADMIN|self::ONLY_ADMIN);

		if ($this->is_admin())
		{
			$this->registerExtension( false );
			// Register plugin options when needed
			$this->add_action( "options_settings_page", array($this, 'admin_options_settings') );
		}
	}


	/**
	 * register options on options_settings_page
	 *
	 * @access public
	 * @return void
	 */
	public function admin_options_settings()
	{
		$root = EAC_SOFTWARE_REGISTRY_SDK.'/SDK/distributions';
		if (is_dir($root) && is_writable($root))
		{
			$this->registerExtensionOptions( ['Create Registration Package', 'distribution' ],
				[
					'_distribute_display'	=> array(
										'type'		=> 	'display',
										'label'		=> 	'<span class="dashicons dashicons-info-outline"></span>',
										'default'	=>	'Using the PHP Software Registry distribution SDK, '.
														'we can generate a custom PHP package that you can include in your project to register your product with your registration server. '.
														'In many cases, only a small amount of code will need to be added to your project with this package.',
									),
					'_distribute_product'	=> array(
										'type'		=> 	'text',
										'label'		=> 	'Product Code',
										'info'		=> 	'The exact name of the product as it is to be registered. (following PHP naming rules)',
										'attributes'=>	['required=required',"pattern='[a-zA-Z0-9_\\x7f-\\xff]*'"]
									),
					'_distribute_namespace'	=> array(
										'type'		=> 	'text',
										'label'		=> 	'PHP Namespace',
										'info'		=> 	'The PHP namespace you\'re using for your product. (following PHP naming rules)',
										'attributes'=>	['required=required',"pattern='[a-zA-Z0-9_\\x7f-\\xff]*'"]
									),
					'_distribute_type'		=> array(
										'type'		=> 	'checkbox',
										'label'		=> 	'Product Type',
										'options'	=>	['WordPress'],
										'info'		=> 	'Check if this is a WordPress distribution (WordPress plugin, etc.).',
									),
					'_create_distribution'	=> array(
										'type'		=> 	'button',
										'label'		=> 	'Create Distribution',
										'default'	=> 	'Create',
										'info'		=> 	'Creates a custom distribution for your product.',
									)
				]
			);

			$suffix		= (class_exists( '\ZipArchive' )) ? '_registration.zip' : '_registration';
			$packages 	= (class_exists( '\ZipArchive' )) ? glob($root.'/*'.$suffix) : glob($root.'/*'.$suffix,GLOB_ONLYDIR);
			if (! empty($packages)) {
				usort($packages,function($file1, $file2)
					{
						return filemtime($file1) < filemtime($file2);
					}
				);
				$downloads = [];
				foreach ($packages as $file) {
					$fdate = wp_date($this->plugin->date_time_format,filemtime($file));
					$file = str_replace($_SERVER['DOCUMENT_ROOT'],'',$file);
					$downloads[ '_'.basename($file,$suffix) ] = array(
										'type'		=> 	'display',
										'label'		=> 	basename($file,$suffix),
										'default'	=> 	(class_exists( '\ZipArchive' ))
														? "<a href='{$file}' download='".basename($file)."'>".basename($file)."</a>"
														: '...'.str_replace(WP_PLUGIN_DIR,'',$root.'/'.basename($file)),
										'info'		=> 'Download the registration package for '.basename($file,$suffix). ' created '.$fdate,
									);
				}
				$downloads[ '_dl_display']	= array(
										'type'		=> 	'display',
										'label'		=> 	'<span class="dashicons dashicons-info-outline"></span>',
										'default'	=>	"After downloading (and extracting) your distribution file, ".
														"move the folder to your project and see the package readme.txt file for implementation instructions. ",
									);
				$this->registerExtensionOptions( ['Download Registration Package', 'distribution' ], $downloads );
			}

			$this->add_filter( 'options_form_post__create_distribution', 	array($this, 'form_request_create_distribution'), 10, 4 );
		}
		else
		{
			$this->registerExtensionOptions( ['Create Registration Package', 'distribution' ],
				[
					'_distribute_display'	=> array(
										'type'		=> 	'display',
										'label'		=> 	'<span class="dashicons dashicons-info-outline"></span>',
										'default'	=>	'Unable to use the Software Registry distribution SDK '.
														'to generate a custom registration package because we do not have write access to the SDK folder.'
									),
				]
			);
		}

		// hide submit button
		$this->registerExtensionOptions( 'Create Registration Package',
			[
				'_btnSubmitOptions'		=> array(
										'type'		=> 	'hidden',
										'label'		=> 	'submit',
										'default'	=> 	'',
									),
			]
		);
	}


	/**
	 * filter for options_form_post_ _create_distribution
	 *
	 * @param $value - the value POSTed
	 * @param $fieldName - the name of the field/option
	 * @param $metaData - the option metadata
	 * @param $priorValue - the prior option value
	 * @return mixed
	 */
	public function form_request_create_distribution($value, $fieldName, $metaData, $priorValue)
	{
		$productName 	= $this->plugin->_POST('_distribute_product');
		$productType 	= ($this->plugin->_POST('_distribute_type') == 'WordPress') ? 'wordpress' : 'filebased';
		$namespace 		= $this->plugin->_POST('_distribute_namespace');
		if (!empty($namespace)) {
			$namespace 	= '\\'.$namespace;
		}
		$baseName 		= $productName.'_registration';
		$root 			= EAC_SOFTWARE_REGISTRY_SDK.'/SDK';
		$dirName 		= $root.'/distributions/'.$baseName;
		$traitName 		= $baseName;
		$traitName 		.= ($productType == 'wordpress') ? '_wordpress' : '_filebased';

		if (is_dir($root.'/PHP') && is_file($root.'/PHP/softwareregistry.interface.tpl'))
		{
			if ( ! is_dir( $dirName ) )
			{
				mkdir($dirName,0775);
				chmod($dirName,0775);
			}
			// readme.txt
			$fileName = $dirName."/{$baseName}.readme.txt";
			$contents = file_get_contents(EAC_SOFTWARE_REGISTRY_SDK.'/readme.txt');
			$contents = str_replace(
				[
					'(your_productid)',
					'(wordpress_or_filebased)',
					'(your_namespace)',
				],
				[
					$productName,
					$productType,
					ltrim($namespace,'\\')
				],
				$contents
			);
			file_put_contents($fileName, $contents);

			$namespace = ltrim($namespace,'\\');

			// softwareregistry.interface.php
			$fileName = $dirName."/{$baseName}.interface.php";
			$contents = file_get_contents($root.'/PHP/softwareregistry.interface.tpl');
			$contents = str_replace(
				[
					'softwareregistry',
					'<your_software_registry_productid>',
					'<your_software_registry_host_url>',
					'<your_software_registry_create_key>',
					'<your_software_registry_update_key>',
					'<your_software_registry_read_key>',
					'EarthAsylumConsulting',
				],
				[
					$baseName,
					$productName,
					home_url("/wp-json/".$this->plugin::CUSTOM_POST_TYPE.$this->plugin::API_VERSION),
					$this->get_option('registrar_create_key'),
					$this->get_option('registrar_update_key'),
					$this->get_option('registrar_read_key'),
					$namespace
				],
				$contents
			);
			file_put_contents($fileName, $contents);

			// softwareregistry.interface.trait.php
			$fileName = $dirName."/{$baseName}.interface.trait.php";
			$contents = file_get_contents($root.'/PHP/softwareregistry.interface.trait.tpl');
			$contents = str_replace(
				[
					'softwareregistry',
					'EarthAsylumConsulting',
				],
				[
					$baseName,
					$namespace
				],
				$contents
			);
			file_put_contents($fileName, $contents);

			// softwareregistry.{$productType}.trait.php
			$fileName = $dirName."/{$baseName}.{$productType}.trait.php";
			$contents = file_get_contents($root."/PHP/softwareregistry.{$productType}.trait.tpl");
			$contents = str_replace(
				[
					'softwareregistry',
					'<your_software_registry_productid>',
					'EarthAsylumConsulting',
				],
				[
					$baseName,
					$productName,
					$namespace
				],
				$contents
			);
			file_put_contents($fileName, $contents);

			// softwareregistry.includes.php
			$fileName = $dirName."/{$baseName}.includes.php";
			$contents = file_get_contents($root.'/PHP/softwareregistry.includes.tpl');
			$contents = str_replace(
				[
					'softwareregistry',
					'<wordpress_or_filebased>',
					'EarthAsylumConsulting',
				],
				[
					$baseName,
					$productType,
					$namespace
				],
				$contents
			);
			file_put_contents($fileName, $contents);

			// RegistrationRefresh.php
			$fileName = $dirName."/{$baseName}.refresh.php";
			$contents = file_get_contents($root.'/PHP/softwareregistry.refresh.tpl');
			$contents = str_replace(
				[
					'softwareregistry',
					'<your_software_registry_productid>',
					'<wordpress_or_filebased>',
					'EarthAsylumConsulting',
				],
				[
					$baseName,
					$productName,
					$productType,
					$namespace
				],
				$contents
			);
			file_put_contents($fileName, $contents);

			if ($this->zip_archive_create($dirName,$dirName.'.zip',true)) {
				rmdir($dirName);
			}

			echo "<script>window.location.reload()</script>";
			die();
		}
	}
}
/**
 * return a new instance of this class
 */
return new eacSoftwareRegistry_distribution_SDK($this);
?>
