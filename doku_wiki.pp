
package {
	'apache2':
	ensure => present;
	'php7.3':
	ensure => present;
}


exec { 
  'wget-dokuwiki':
    cwd     => '/usr/src',
    command => '/usr/bin/wget -O /usr/src/dokuwiki.tgz https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz';
}


exec {
	'Extraction Doku':
	cwd => '/usr/src',
	command => 'tar -xzvf dokuwiki.tgz',
	creates => '/usr/src/dokuwiki',
	path => ['/usr/bin', '/usr/sbin',];
}

