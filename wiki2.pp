package {
        'apache2':
        ensure => 'present';
        'php7.3':
        ensure => 'installed';
}

service { 'apache2':
	ensure    => running,
	enable    => true,
	notify => Package['apache2'];

}

file { 'download-dokuwiki':
        ensure => 'present',
        source => 'https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz',
        path => '/usr/src/dokuwiki.tgz',
        checksum_value => '8867b6a5d71ecb5203402fe5e8fa18c9';
}

exec { 'extraction-doku':
        cwd => '/usr/src',
        command => 'tar -xzvf dokuwiki.tgz',
        creates => '/usr/src/dokuwiki',
        path => ['/usr/bin', '/usr/sbin',],
	require => File['download-dokuwiki'];
       'copie-dokuwiki':
        cwd => '/usr/src/',
        command => 'rsync -a dokuwiki/ /var/www/politique && rsync -a dokuwiki/ /var/www/recettes',
        path => ['/usr/bin', '/usr/sbin',],
        require => Exec['extraction-doku'],
}



file {
  'change-permission-recette':
    ensure => 'directory',
    path   => '/var/www/recettes/data',
    mode   => '0755',
    before => File['create-conf-recette-apache'];
  'change-permission-politique':
    ensure => 'directory',
    path   => '/var/www/politique/data',
    mode   => '0755',
    before => File['create-conf-politique-apache'];
}



file {
  'create-conf-recette-apache':
    ensure => 'present',
    source => '/etc/apache2/sites-available/000-default.conf',
    path   => '/etc/apache2/sites-available/recettes.conf',
    before => Exec['changement-conf'];
  'create-conf-politique-apache':
    ensure => 'present',
    source => '/etc/apache2/sites-available/000-default.conf',
    path   => '/etc/apache2/sites-available/politique.conf',
    before => Exec['changement-conf'];
}

exec {'changement-conf':
	command =>  'sed -i \'s/html/politique/g\' /etc/apache2/sites-enabled/politique.conf && sed -i \'s/#ServerName www.example.com/ServerName politique.wiki/g\' /etc/apache2/sites-enabled/politique.conf && sed -i \'s/html/recettes/g\' /etc/apache2/sites-enabled/recettes.conf && sed -i \'s/#ServerName www.example.com/ServerName recettes.wiki/g\' /etc/apache2/sites-enabled/recettes.conf',
	path => ['/usr/bin', '/usr/sbin',],
}


exec {
  'start-recette':
    path    => ['/usr/bin/', '/usr/sbin'],
    command => 'a2ensite recettes';
  'start-politique':
    path    => ['/usr/bin', '/usr/sbin'],
    command => 'a2ensite politique';
}

