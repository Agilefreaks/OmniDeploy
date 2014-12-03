class freaks::web_base (
    $gemset = 'freaks',
    $app_name = 'freaks'
  ) {
  class { 'newrelic':
    license_key => $::newrelic_license_key,
    use_latest  => true
  }

  class { 'freaks::user': }->
  class { 'freaks::ruby':
    gemset => $gemset
  }
}

class freaks::web (
    $gemset = 'freaks',
    $app_name = 'freaks'
  ) {
  class { 'freaks::web_base':
    gemset => $gemset,
    app_name => $app_name
  }->
  class { 'freaks::nginx::web':
    app_name => $app_name,
    deploy_to => $deploy_to,
  }
}

class freaks::sync (
    $gemset = 'freaks',
    $app_name = 'freaks'
  ) {
  class { 'freaks::web_base':
    gemset => $gemset,
    app_name => $app_name
  }->
  class { 'freaks::nginx::websocket':
    app_name => $app_name,
    deploy_to => $deploy_to,
  }
}

class freaks::mongo {
  class { 'newrelic':
    license_key => $::newrelic_license_key,
    use_latest  => true
  }

  class { 'mongodb::globals':
    manage_package_repo => true,
  }->
  class { 'mongodb::server': 
    bind_ip => ['127.0.0.1',"$ipaddress_eth0"],
    replset    => 'rsfreaks'
  }->
  class { 'mongodb::client': }
}

class freaks::haproxy {
  class { 'apt': }
  apt::ppa { 'ppa:vbernat/haproxy-1.5': }->
  package { 'haproxy':
    ensure => latest
  }

  class { 'newrelic':
    license_key => $::newrelic_license_key,
    use_latest  => true
  }
}

class freaks::admin (
  $gemset = 'admin'
  ) {  
  class { 'newrelic':
    license_key => $::newrelic_license_key,
    use_latest  => true
  }
  
  class { 'rvm':
    version => $::rvm_version
  }->
  rvm_system_ruby { $::ruby_version:
    ensure      => present,
    default_use => true
  }->
  rvm_gemset { "$::ruby_version@$gemset":
    ensure  => present
  }->

  class { 'vagrant': }->
  vagrant::plugin { 'vagrant-digitalocean': }->
  vagrant::plugin { 'vagrant-triggers': }
}
