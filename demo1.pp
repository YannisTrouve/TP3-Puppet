package {
	'irssi':
	ensure => purged;

	'apache2':
	ensure => present;

	'mariadb-server':
	ensure => present;

	'tmux':
	ensure => present;

}



