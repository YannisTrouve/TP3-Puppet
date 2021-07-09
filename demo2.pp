file {'/tmp/hello':
	ensure => present,
	owner => 'root',
	group => 'root',
	mode => '0600',
	content => 'Hello World';
}
