package { "vim":
  ensure => latest
}

ackage { "git":
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

node /^mongo[0-2]$/ {
  class { 'freaks::mongo': }
}

node /lb\d./ {
  class { 'freaks::haproxy': }
}

node 'admin' {
  class { 'freaks::admin': }
}
