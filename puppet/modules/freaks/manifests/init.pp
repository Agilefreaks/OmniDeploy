class freaks::newrelic_base {
  class { 'newrelic':
    license_key => $::newrelic_license_key,
    use_latest  => true
  }  
}

class freaks::web_base (
    $gemset = 'freaks',
    $app_name = 'freaks'
  ) {
  class { 'freaks::newrelic_base': }

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
  class { 'freaks::newrelic_base': }

  class { 'mongodb::globals':
    manage_package_repo => true,
  }->
  class { 'mongodb::server': 
    bind_ip => ['127.0.0.1',"$ipaddress_eth1"],
    replset    => 'rsfreaks'
  }->
  class { 'mongodb::client': }
}

class freaks::redis_server {
  class { 'freaks::newrelic_base': }

  class { 'redis':
    port => '6379',   
    bind => "127.0.0.1 $ipaddress_eth1",
    maxmemory   => '400000000',
  }
}

class freaks::haproxy {
  class { 'apt': }
  apt::ppa { 'ppa:vbernat/haproxy-1.5': }->
  package { 'haproxy':
    ensure => latest
  }

  class { 'freaks::newrelic_base': }
}

class freaks::omnikiq {
  class { 'freaks::newrelic_base': }

  class { 'freaks::ruby':
    gemset => 'omnikiq'
  }
}

class freaks::admin (
  $gemset = 'admin'
  ) {  
  class { 'freaks::newrelic_base': }

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
