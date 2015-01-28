class freaks::redis {
	class { 'redis': version => $required_redis_version }->
	redis::instance { 'redis':
		redis_port => '6379',		
		redis_bind_address => ['127.0.0.1',"$ipaddress_eth0"],
		redis_password     => hiera('redis_password'),
		redis_max_memory   => '400mb',
	}
}