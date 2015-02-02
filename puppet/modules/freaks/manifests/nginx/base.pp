class freaks::nginx::base (
    $app_name = 'freaks',
    $deploy_to = '/var/www',
    $user = 'deploy',
    $group = 'www-data',
    $domain = 'agilefreaks.com',
    $cfg_append = ''
  ) {
  file { [$deploy_to,
        "$deploy_to/$app_name",
        "$deploy_to/$app_name/releases",
        "$deploy_to/$app_name/shared",
        "$deploy_to/$app_name/shared/log",
        "$deploy_to/$app_name/shared/tmp",
        "$deploy_to/$app_name/shared/tmp/sockets",
        "$deploy_to/$app_name/shared/tmp/pids"]:
    ensure => 'directory',
    owner  => $user,
    group  => $group
  }->

  class { 'nginx':
    worker_rlimit_nofile: '16384',
  }

  nginx::resource::upstream { "$app_name":
    ensure  => present,
    members => ["unix:$deploy_to/$app_name/shared/tmp/sockets/puma.sock"]
  }->
  nginx::resource::vhost { "${app_name}.${domain}":
    ensure => present,
    access_log => "$deploy_to/$app_name/shared/log/nginx_access.log",
    error_log => "$deploy_to/$app_name/shared/log/nginx_error.log",
    proxy => "http://$app_name/",
    location_cfg_append => $cfg_append
  }  
}
