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

host { 
	'recette':
	ip => '127.0.0.1';
	'politique':
	ip => '127.0.0.2';
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


file { '/var/www/politique':
	ensure => 'directory',
	owner => 'www-data',
	group => 'www-data',
	mode  => '0755',
	before => Exec['copie-dokuwiki'];
	'/var/www/recettes':
        ensure => 'directory',
        owner => 'www-data',
        group => 'www-data',
        mode => '0755',
        before => Exec['copie-dokuwiki'],
}



exec { 'copie-conf-vhost':
    command => 'cp /etc/apache2/sites-available/000-default.conf /var/www/politique/politique.conf && cp /etc/apache2/sites-available/000-default.conf /var/www/recettes/recettes.conf',
    path    => ['/usr/bin', '/usr/sbin',],
}

exec { 'conf-vhost':
    command => 'sed -i \'s/html/politique/g\' /var/www/politique/politique.conf && sed -i \'s/html/recettes/g\' /var/www/recettes/recettes.conf',
    path    => ['/usr/bin', '/usr/sbin',],
}

exec { 'port-conf-vhost':
    command => 'sed -i \'s/*:80/*:1080/g\' /var/www/politique/politique.conf && sed -i \'s/*:80/*:1080/g\' /var/www/recettes/recettes.conf',
    path    => ['/usr/bin', '/usr/sbin',],
}


exec { 'link-vhost':
    command => 'ln -s /var/www/politique/politique.conf /etc/apache2/sites-available/politique.conf && ln -s /var/www/recettes/recettes.conf /etc/apache2/sites-available/recettes.conf',
    path    => ['/usr/bin', '/usr/sbin',],
}


exec { 'activation-vhost':
	command => 'a2ensite recettes && a2ensite politique',
	path    => ['/usr/bin', '/usr/sbin',],
	require => Package['apache2']
}













