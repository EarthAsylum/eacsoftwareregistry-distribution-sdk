## {eac}SoftwareRegistry Distribution SDK  
[![EarthAsylum Consulting](https://img.shields.io/badge/EarthAsylum-Consulting-0?&labelColor=6e9882&color=707070)](https://earthasylum.com/)
[![WordPress](https://img.shields.io/badge/WordPress-Plugins-grey?logo=wordpress&labelColor=blue)](https://wordpress.org/plugins/search/EarthAsylum/)
[![eacDoojigger](https://img.shields.io/badge/Requires-%7Beac%7DDoojigger-da821d)](https://eacDoojigger.earthasylum.com/)

<details><summary>Plugin Header</summary>

Plugin URI:         https://swregistry.earthasylum.com/software-registry-sdk/  
Author:             [EarthAsylum Consulting](https://www.earthasylum.com)  
Stable tag:         1.0.9  
Last Updated:       08-Jun-2023  
Requires at least:  5.8  
Tested up to:       6.6  
Requires PHP:       7.4  
Contributors:       [kevinburkholder](https://profiles.wordpress.org/kevinburkholder)  
License:            GPLv3 or later  
License URI:        https://www.gnu.org/licenses/gpl.html  
Tags:               software registration, software registry, software license, license manager, registration API, registration SDK, {eac}SoftwareRegistry  
WordPress URI:      https://wordpress.org/plugins/eacsoftwareregistry-distribution-sdk  
Github URI:         https://github.com/EarthAsylum/eacsoftwareregistry-distribution-sdk  

</details>

> {eac}SoftwareRegistry Distribution SDK for the Software Registration Server - Implementing the Software Registry SDK Package.

### Description

**{eac}SoftwareRegistry Distribution SDK** is an extension plugin to [{eac}SoftwareRegistry Software Registration Server](https://swregistry.earthasylum.com/software-registration-server/).

The Software Registry Distribution SDK is used to generate a custom PHP package that you can include in your software project to register your product with your registration server and manage that registration.

_A custom version of this "readme.txt" file is included in the generated SDK package._

The SDK provides most of the PHP code you will need to implement the Application Program Interface with your Software Registration Server.

Included with the Software Registration SDK package...

+   `(your_productid)_registration.(wordpress_or_filebased).trait.php`
+   `(your_productid)_registration.includes.php`
+   `(your_productid)_registration.interface.php`
+   `(your_productid)_registration.interface.trait.php`
+   `(your_productid)_registration.refresh.php`


#### Software Registry Implementation

After extracting the `(your_productid)_registration.zip` file, move the `(your_productid)_registration` folder to your project.

In your project or class file, include `(your_productid)_registration/(your_productid)_registration.includes.php` to load the required interface and traits.

Your class file must then:

+   implement `\(your_namespace)\Interfaces\(your_productid)_registration`
+   use `\(your_namespace)\Traits\(your_productid)_registration_(wordpress_or_filebased)`

Example:

    include "(your_productid)_registration/(your_productid)_registration.includes.php";

    class <your_classname> implements \(your_namespace)\Interfaces\(your_productid)_registration
    {
        use \(your_namespace)\Traits\(your_productid)_registration_(wordpress_or_filebased);
            ...
    }

(your_productid)_registration.interface.php will have your product and registration server API constants.

    const SOFTWARE_REGISTRY_PRODUCTID   = '{your_software_registry_productid}';
    const SOFTWARE_REGISTRY_HOST_URL    = '{your_software_registry_host_url}';
    const SOFTWARE_REGISTRY_CREATE_KEY  = '{your_software_registry_create_key}';
    const SOFTWARE_REGISTRY_UPDATE_KEY  = '{your_software_registry_update_key}';
    const SOFTWARE_REGISTRY_READ_KEY    = '{your_software_registry_read_key}';


#### Using The API

**API Parameters**

API parameters are passed as an array:

    $apiParams =
    [
        'registry_key'          => 'unique ID',                     // * registration key (assigned by registry server)
        'registry_name'         => 'Firstname Lastname',            //   registrant's full name
        'registry_email'        => 'email@domain.com',              // * registrant's email address
        'registry_company'      => 'Comapny/Organization Name',     //   registrant's company name
        'registry_address'      => 'Street\n City St Zip',          //   registrant's full address (textarea)
        'registry_phone'        => 'nnnnnnnnnn',                    //   registrant's phone
        'registry_product'      => 'productId',                     // * your product name/id ((your_productid))
        'registry_title'        => 'Product Title',                 //   your product title
        'registry_description'  => 'Product Description',           //   your product description
        'registry_version'      => 'M.m.p',                         //   your product version
        'registry_license'      => 'Lx',                            //   'L1'(Lite), 'L2'(Basic), 'L3'(Standard), 'L4'(Professional), 'L5'(Enterprise), 'LD'(Developer)
        'registry_count'        => int,                             //   Number of licenses (users/seats/devices)
        'registry_variations'   => array('name'=>'value',...),      //   array of name/value pairs
        'registry_options'      => array('value',...),              //   array of registry options
        'registry_domains'      => array('domain',...),             //   array of valid/registered domains
        'registry_sites'        => array('url',...),                //   array of valid/registered sites/uris
        'registry_transid'      => '',                              //   external transaction id
        'registry_timezone'     => '',                              //   standard timezone string (client timezone)
    ];

\* *Required values (registry_key not required when creating a new registration).*

>   If setting registry_transid, the recommended (not required) format is `{id}|{source}|{suffix}` where {id} is the transaction id, {source} indicates the source of the transaction, and {suffix} may be used as needed.

Any additional fields passed wil be saved as custom fields.

Although typically set by the Software Registry server, with the proper option setting, the API _may_ override:

    [
        'registry_status'       => 'status',                        // 'pending', 'trial', 'active', 'inactive', 'expired', 'terminated'
        'registry_effective'    => 'YYYY-MM-DD',                    // Effective date (Y-m-d)
        'registry_expires'      => 'YYYY-MM-DD',                    // Expiration date (Y-m-d) or term ('30 days', '1 year',... added to effective date)
    ];

Payment information may be posted with:

    [
        'registry_paydue'       => float,                           // amount to be paid/billed,
        'registry_payamount'    => float,                           // amount paid,
        'registry_paydate'      => 'YYYY-MM-DD',                    // date paid
        'registry_payid'        => 'payment id'                     // transaction id/check #, etc.
        'registry_nextpay'      => 'YYYY-MM-DD',                    // next payment/renewal date
    ];


**API Requests**

Create/request a new registration...

    $response = $this->registryApiRequest('create',$apiParams);

Activate an existing registration...

    $response = $this->registryApiRequest('activate',['registry_key' => '<registrationKeyValue>']);

Activate and Update an existing registration...

    $response = $this->registryApiRequest('activate',$apiParams);

Deactivate an existing registration...

    $response = $this->registryApiRequest('deactivate',['registry_key' => '<registrationKeyValue>']);

Verify or Refresh an existing registration...

    $response = $this->registryApiRequest('verify',['registry_key' => '<registrationKeyValue>']);
    $response = $this->registryApiRequest('refresh',$apiParams);

Revise an existing registration...

    $response = $this->registryApiRequest('revise',$apiParams);

**API Response**

The API response is a standard object. status->code is an http status, 200 indicating success.

    status      ->
    (
        'code'                  -> 200,             // HTTP status code
        'message'               -> '(action) ok'    // (action) = 'create', 'activate', 'deactivate', 'verify', 'revise'
    ),
    registration ->
    (
        'registry_key'          -> string           // UUID,
        'registry_status'       -> string,          // 'pending', 'trial', 'active', 'inactive', 'expired', 'terminated', 'invalid'
        'registry_effective'    -> string,          // DD-MMM-YYYY effective date
        'registry_expires'      -> string,          // DD-MMM-YYYY expiration date
        'registry_name'         -> string,
        'registry_email'        -> string,
        'registry_company'      -> string,
        'registry_address'      -> string,
        'registry_phone'        -> string,
        'registry_product'      -> string,
        'registry_title'        -> string,
        'registry_description'  -> string,
        'registry_version'      -> string,
        'registry_license'      -> string,
        'registry_count'        -> int,
        'registry_variations'   -> array,
        'registry_options'      -> array,
        'registry_domains'      -> array,
        'registry_sites'        -> array,
        'registry_transid'      -> string,
        'registry_timezone'     -> string,
        'registry_valid'        -> bool,            // true/false
    ),
    registrar ->
    (
        'contact'               -> object(
            'name'              -> string           // Registrar Name
            'email'             -> string           // Registrar Support Email
            'phone'             -> string           // Registrar Telephone
            'web'               -> string           // Registrar Web Address
        ),
        'cacheTime'             -> int,             // in seconds, time to cache the registration response (Default Cache Time)
        'refreshInterval'       -> int,             // in seconds, time before refreshing the registration (Default Refresh Time)
        'refreshSchedule'       -> string,          // 'hourly','twicedaily','daily','weekly' corresponding to refreshInterval
        'options'               -> array(           // from settings page, registrar_options (Allow API to...)
            'allow_set_key',
            'allow_set_status',
            'allow_set_effective',
            'allow_set_expiration',
            'allow_activation_update'
        ),
        'notices'               -> object(
            'info'              -> string,          // information message text
            'warning'           -> string,          // warning message text
            'error'             -> string,          // error message text
            'success'           -> string,          // success message text
        ),
        'message'               -> string,          // html message
    ),
    registryHtml                -> string,          // html (table) of human-readable registration values

On a successful response (status->code = 200), the SDK will automatically cache the registration data and schedule the next refresh event (you do not have to do this).

_notices_ may be set (according to severity) to indicate an expiration or pending expiration and should be displayed to the user. Typically, only one notice will be set but they can be set via the `eacSoftwareRegistry_api_registration_notices` filter.

_message_ is set via the `eacSoftwareRegistry_api_registration_message` filter.

On an error response, an additional element is included:

    error      ->
    (
        'code'                  -> 'error_code',
        'message'               -> 'error message'
    ),

error->message may be more informative than status->message.
Errors may be handled with something like:

    if ($this->is_api_error($response))
    {
        echo "<div class='notice notice-error'><h4>Error ".$response->error->code." : ".$response->error->message."</h4></div>";
    }


#### Methods, Hooks, and Callbacks

Useful methods built into the SDK...

    $this->isValidRegistration();
        // Returns boolean
        if ( $this->isValidRegistration() ) {...}

    $this->getRegistrationKey();
        // Returns the current registration key
        $registrationKey = $this->getRegistrationKey();

    $this->getCurrentRegistration();
        // Returns the current registration object (above response object)
        $currentRegistration = $this->getCurrentRegistration();

    $this->isRegistryValue($keyName);
        // Returns the value of a specific registry key
        $regStatus = $this->isRegistryValue( 'status ');

    $this->isRegistryValue($keyName, $value, $test);
        // Returns boolean comparison of the value of a registry key ($test is '=|eq' (default), '<|lt', '>|gt', '<=|le', '>=|ge')
        if ( $this->isRegistryValue('license', 'L3', '>=') ) {...}


Several hooks are available to customize or react to registration events.
In WordPresss, there are several actions and filters, for file based projects there are corresponding callback methods...

     filter/callback: (your_productid)_api_remote_request( $request, $endpoint )
        @param  array $request ['method'=>, 'timeout'=>, 'redirection'=>, 'sslverify'=>, 'headers'=>, 'body'=>]
        @param  string $endpoint create, activate, deactivate, verify, refresh, revise
        @return array request body

     action/callback: (your_productid)_api_remote_response( $body, $request, $endpoint )
        @param  array $body response body
        @param  array $request ['method'=>, 'timeout'=>, 'redirection'=>, 'sslverify'=>, 'headers'=>, 'body'=>]
        @param  string $endpoint create, activate, deactivate, verify, refresh, revise

     action/callback: (your_productid)_api_remote_$endpoint( $body, $request, $endpoint )
        @param  array $body response body
        @param  array $request ['method'=>, 'timeout'=>, 'redirection'=>, 'sslverify'=>, 'headers'=>, 'body'=>]
        @param  string $endpoint create, activate, deactivate, verify, refresh, revise

     action/callback: (your_productid)_api_remote_error( $error, $request, $endpoint )
        @param  object $error {status:{}, error: {}}
        @param  array $request ['method'=>, 'timeout'=>, 'redirection'=>, 'sslverify'=>, 'headers'=>, 'body'=>]
        @param  string $endpoint create, activate, deactivate, verify, refresh, revise

     action/callback: (your_productid)_update_registration($registration)
        @param  array $registration registration object

     action/callback: (your_productid)_purge_registration()


#### What You Need To Do

**For WordPress Projects**

In your class constructor/initialization, add an action to fulfill the registration refresh scheduled by the `scheduleRegistryRefresh()` method in `(your_productid).wordpress.trait.php`

    \add_action( '(your_productid)_registry_refresh', array($this, 'refreshRegistration') );

You can add this and other hooks with:

    $this->addSoftwareRegistryHooks();

The `addSoftwareRegistryHooks()` method adds:

    \add_action( '(your_productid)_registry_refresh',     array($this, 'refreshRegistration') );
    \add_filter( '(your_productid)_is_registered',        array($this, 'isValidRegistration') );
    \add_filter( '(your_productid)_registration_key',     array($this, 'getRegistrationKey') );
    \add_filter( '(your_productid)_registration',         array($this, 'getCurrentRegistration') );
    \add_filter( '(your_productid)_registry_value',       array($this, 'isRegistryValue'), 10, 4 );

Example:

    include "(your_productid)_registration/(your_productid)_registration.includes.php";

    class <your_classname> implements \(your_namespace)\Interfaces\(your_productid)_registration
    {
        use \(your_namespace)\Traits\(your_productid)_registration_wordpress;
            ...
        public function __construct()
        {
            $this->addSoftwareRegistryHooks();
        }
    }


**For Other File Based Projects**

The `scheduleRegistryRefresh()` method in `(your_productid)_registration.filebased.trait.php` is called to schedule the next registration refresh. This method can be modified to schedule a cron event to execute the refresh at a future time. The scheduled event may run `(your_productid)_registration.refresh.php <registrationKeyValue>` from the command line to refresh the registration.

When left as is, the `checkRegistryRefreshEvent()` method uses the key file to check for a needed registration refresh.

In your class constructor or destructor add:

    $this->checkRegistryRefreshEvent();

to trigger the refresh check.

Example:

    include "(your_productid)_registration/(your_productid)_registration.includes.php";

    class <your_classname> implements \(your_namespace)\Interfaces\(your_productid)_registration
    {
        use \(your_namespace)\Traits\(your_productid)_registration_filebased;
            ...
        public function __destruct()
        {
            /* if necessary, set HOME and/or TMP/TMPDIR/TEMP directories */
            // putenv('HOME={your home directory}');   // where the registration key is stored, otherwise use $_SERVER['DOCUMENT_ROOT']
            // putenv('TMP={your temp directory}');    // where the registration data is stored, otherwise use sys_get_temp_dir()
            $this->checkRegistryRefreshEvent();
        }
    }


#### User Interface

Of course, the user interface is up to you, the developer, but you may look at (and maybe use) the registration UI trait included  with _{eac}Doojigger_ and used by _{eac}SoftwareRegistry_ as an example.

see:

+   .../Traits/swRegistrationUI.trait.php in the eacDoojigger folder.
+   .../Extensions/class.eacSoftwareRegistry_registration.extension.php in the eacSoftwareRegistry folder.


### Installation

**{eac}SoftwareRegistry Distribution SDK** is an extension plugin to and requires installation and registration of [{eac}SoftwareRegistry](https://swregistry.earthasylum.com/).*

#### Automatic Plugin Installation

This plugin is available from the [WordPress Plugin Repository](https://wordpress.org/plugins/search/earthasylum/) and can be installed from the WordPress Dashboard » *Plugins* » *Add New* page. Search for 'EarthAsylum', click the plugin's [Install] button and, once installed, click [Activate].

See [Managing Plugins -> Automatic Plugin Installation](https://wordpress.org/support/article/managing-plugins/#automatic-plugin-installation-1)

#### Upload via WordPress Dashboard

Installation of this plugin can be managed from the WordPress Dashboard » *Plugins* » *Add New* page. Click the [Upload Plugin] button, then select the eacsoftwareregistry-distribution-sdk.zip file from your computer.

See [Managing Plugins -> Upload via WordPress Admin](https://wordpress.org/support/article/managing-plugins/#upload-via-wordpress-admin)

#### Manual Plugin Installation

You can install the plugin manually by extracting the eacsoftwareregistry-distribution-sdk.zip file and uploading the 'eacsoftwareregistry-distribution-sdk' folder to the 'wp-content/plugins' folder on your WordPress server.

See [Managing Plugins -> Manual Plugin Installation](https://wordpress.org/support/article/managing-plugins/#manual-plugin-installation-1)

#### Settings

Options for this extension will be added to the *Software Registry » Settings » Distribution* tab.


### Screenshots

1. {eac}SoftwareRegistry Distribution
![{eac}SoftwareRegistry Distribution](https://ps.w.org/eacsoftwareregistry-distribution-sdk/assets/screenshot-1.png)

2. UI Example 1 (Activate/Register):
![Software Registration](https://ps.w.org/eacsoftwareregistry-distribution-sdk/assets/screenshot-2.png)

3. UI Example 2 (Refresh/Delete):
![Software Registration](https://ps.w.org/eacsoftwareregistry-distribution-sdk/assets/screenshot-3.png)


### Other Notes

#### See Also

+   [{eac}SoftwareRegistry – Software Registration Server](https://swregistry.earthasylum.com/software-registration-server/)

+   [{eac}SoftwareRegistry Custom Hooks](https://swregistry.earthasylum.com/software-registry-hooks/)


