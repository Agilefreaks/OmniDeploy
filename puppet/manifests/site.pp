package { "vim":
  ensure => latest
}

package { "git":
  ensure => latest
}

node /apistaging\d./ {
  class { 'freaks::web':
    gemset => 'omniapi',
    app_name => 'omniapi'
  }
}

node /apiproduction\d./ {
  class { 'freaks::web':
    gemset => 'omniapi',
    app_name => 'omniapi'
  }
}

node /webstaging\d./ {
  class { 'freaks::web':
    gemset => 'webomni',
    app_name => 'webomni'
  }

  $environment_variables = {
    'GOOGLE_CLIENT_SECRET' =>  { ensure => present, value => '\'{"web":{"auth_uri":"https://accounts.google.com/o/oauth2/auth","client_secret":"4mLcVIVpj0zHuIR9sbmSPoSH","token_uri":"https://accounts.google.com/o/oauth2/token","client_email":"930634995806-vqol11op6ugtvljcftoqcc1v757gep8u@developer.gserviceaccount.com","redirect_uris":["https://webstaging.omnipasteapp.com/users/auth/google_oauth2/callback"],"client_x509_cert_url":"https://www.googleapis.com/robot/v1/metadata/x509/930634995806-vqol11op6ugtvljcftoqcc1v757gep8u@developer.gserviceaccount.com","client_id":"930634995806-vqol11op6ugtvljcftoqcc1v757gep8u.apps.googleusercontent.com","auth_provider_x509_cert_url":"https://www.googleapis.com/oauth2/v1/certs","javascript_origins":["https://webstaging.omnipasteapp.com"]}}\'', }
  }

  create_resources(systemenv::var, $environment_variables)
}

node /webproduction\d./ {
  class { 'freaks::web':
    gemset => 'webomni',
    app_name => 'webomni'
  }    
}

node /syncstaging\d./ {
  class { 'freaks::sync':
    gemset => 'omnisync',
    app_name => 'omnisync'
  }
}

node /syncproduction\d./ {
  class { 'freaks::sync':
    gemset => 'omnisync',
    app_name => 'omnisync'
  }
}

node /omnikiqproduction\d./ {
  class { 'freaks::omnikiq': }
}

node /omnikiqstaging\d./ {
  class { 'freaks::omnikiq': }
}

node /^mongo[0-2]$/ {
  class { 'freaks::mongo': }
}

node /^redis[0-2]$/ {
  class { 'freaks::redis_server': }
}

node /lb\d./ {
  class { 'freaks::haproxy': }
}

node 'admin' {
  class { 'freaks::admin': }
}
