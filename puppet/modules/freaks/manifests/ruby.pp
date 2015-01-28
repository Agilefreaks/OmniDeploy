class freaks::ruby (
    $gemset = 'freaks',
    $user = 'deploy'
  ) {
  class { 'rvm': version => $requiered_rvm_version }->
  rvm_system_ruby { $requiered_ruby_version:
    ensure      => present,
    default_use => true
  }->
  rvm_gemset { "$ruby_version@$gemset":
    ensure  => present
  }->
  rvm::system_user { "$user": }
}
