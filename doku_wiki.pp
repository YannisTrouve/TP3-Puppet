
package {
	'apache2':
	ensure => present;
	'php7.3':
	ensure => present;
}


file {'/usr/src/dokuwiki.tgz':
	ensure => 'present',
	source => 'https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz',
	path => '/usr/src/dokuwiki.tgz',
	checksum_value => '8867b6a5d71ecb5203402fe5e8fa18c9';
}

exec {
	'Extraction Doku':
	cwd => '/usr/src',
	command => 'tar -xzvf dokuwiki.tgz',
	creates => '/usr/bin/dokuwiki',
	path => ['/usr/bin', '/usr/sbin',];
}

