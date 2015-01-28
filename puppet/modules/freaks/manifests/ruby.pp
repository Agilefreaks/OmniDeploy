class freaks::ruby (
    $gemset = 'freaks',
    $user = 'deploy'
  ) {
  class { 'rvm': version => $required_rvm_version }->
  rvm_system_ruby { $required_ruby_version:
    ensure      => present,
    default_use => true
  }->
  rvm_gemset { "$required_ruby_version@$gemset":
    ensure  => present
  }->
  rvm::system_user { "$user": }
}
