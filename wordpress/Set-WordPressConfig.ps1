<#
    Sets all configuration parameters in pristine WordPress core files
#>

[CmdletBinding()]
Param(
    # Root path of the WordPress implementation
    [Parameter (Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String] $Path,
    
    # WordPress site config in JSON string format
    [Parameter (Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String] $SiteConfig,
    
    # WordPress database user password (better pass this value from an environment variable)
    [Parameter (Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String] $DbUserPwd
)

# Parse site configuration
$SiteConfigJson = ConvertFrom-Json $SiteConfig

# Get project root
$ProjectRoot = ((Get-Item $PSScriptRoot).Parent).FullName

# Add tools
."$ProjectRoot\.tools\Convert-VarsToStrings.ps1"

# Add constants
$Constants = Get-Content ".\wordpress-constants.json" | ConvertFrom-Json

# Set/expand variables before using WP CLI
$TextInfo = (Get-Culture).TextInfo
$_wordpress_path = $Path + $Constants.paths.wordpress
$_host = $SiteConfigJson.database.host
$_name = $SiteConfigJson.database.name
$_user = $SiteConfigJson.database.user
$_prefix = $SiteConfigJson.database.prefix
$_skip_check = Convert-WpCliConfigCreateSkipCheck ($SiteConfigJson.database.skip_check)
$_prefix = $SiteConfigJson.database.prefix
$_site_url = $SiteConfigJson.settings.site_url
$_content_url = $SiteConfigJson.settings.content_url
$_plugin_url = $SiteConfigJson.settings.plugin_url
$_noblogredirect_url = $SiteConfigJson.settings.noblogredirect_url
$_disable_fatal_error_handler_and_debug_display = $SiteConfigJson.settings.disable_fatal_error_handler_and_debug_display
$_cache = $SiteConfigJson.settings.cache
$_save_queries = $SiteConfigJson.settings.save_queries
$_empty_trash_days = $SiteConfigJson.settings.empty_trash_days
$_disallow_file_edit = $SiteConfigJson.settings.disallow_file_edit
$_disallow_file_mods = $SiteConfigJson.settings.disallow_file_mods
$_force_ssl_admin = $SiteConfigJson.settings.force_ssl_admin
$_http_block_external = $SiteConfigJson.settings.http_block_external
$_accessible_hosts = Convert-WpCliConfigCreateAccessibleHosts $SiteConfigJson.settings.accessible_hosts
$_auto_update_core = Convert-WpCliConfigCreateAutoUpdateCore $SiteConfigJson.settings.auto_update_core
$_image_edit_overwrite = $SiteConfigJson.settings.image_edit_overwrite

# Create wp-config.php file
# More info at https://wordpress.org/support/article/editing-wp-config-php/
wp config create --path=$_wordpress_path --dbhost=$_host --dbname=$_name --dbuser=$_user --dbpass=$DbUserPwd --dbprefix=$_prefix --force $_skip_check
wp config set WP_SITEURL $_site_url --type=constant --path=$_wordpress_path
wp config set WP_HOME $_site_url --type=constant --path=$_wordpress_path
wp config set WP_CONTENT_URL $_content_url --type=constant --path=$_wordpress_path
wp config set WP_PLUGIN_URL $_plugin_url --type=constant --path=$_wordpress_path
wp config set NOBLOGREDIRECT $_noblogredirect_url --type=constant --path=$_wordpress_path
wp config set WP_DISABLE_FATAL_ERROR_HANDLER $TextInfo.ToLower("$_disable_fatal_error_handler_and_debug_display") --raw --type=constant --path=$_wordpress_path
wp config set WP_DEBUG_DISPLAY $TextInfo.ToLower("$_disable_fatal_error_handler_and_debug_display") --raw --type=constant --path=$_wordpress_path
wp config set WP_DEBUG $TextInfo.ToLower("$_disable_fatal_error_handler_and_debug_display") --raw --type=constant --path=$_wordpress_path
wp config set WP_CACHE $TextInfo.ToLower("$_cache") --raw --type=constant --path=$_wordpress_path
wp config set SAVEQUERIES $TextInfo.ToLower("$_save_queries") --raw --type=constant --path=$_wordpress_path
wp config set EMPTY_TRASH_DAYS $_empty_trash_days --raw --type=constant --path=$_wordpress_path
wp config set DISALLOW_FILE_EDIT $TextInfo.ToLower("$_disallow_file_edit") --raw --type=constant --path=$_wordpress_path
wp config set DISALLOW_FILE_MODS $TextInfo.ToLower("$_disallow_file_mods") --raw --type=constant --path=$_wordpress_path
wp config set FORCE_SSL_ADMIN $TextInfo.ToLower("$_force_ssl_admin") --raw --type=constant --path=$_wordpress_path
wp config set WP_HTTP_BLOCK_EXTERNAL $TextInfo.ToLower("$_http_block_external") --raw --type=constant --path=$_wordpress_path
wp config set WP_ACCESSIBLE_HOSTS $TextInfo.ToLower($_accessible_hosts) --type=constant --path=$_wordpress_path
wp config set WP_AUTO_UPDATE_CORE $TextInfo.ToLower($_auto_update_core) --type=constant --path=$_wordpress_path
wp config set IMAGE_EDIT_OVERWRITE $TextInfo.ToLower("$_image_edit_overwrite") --raw --type=constant --path=$_wordpress_path