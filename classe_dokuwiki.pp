class require_packages {

package { 'apache2':
        ensure => 'present';
        'php7.3':
        ensure => 'installed';

	}

service { 'apache2':
        ensure    => running,
        enable    => true,
        notify => Package['apache2'];

	}


}



class extract_doku {
	

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

}

class install_wiki ($sitename, $hostname) {
	
	host { '${hostname}':
	ip => '127.0.0.1',
	}

	file {'change-permission':
	ensure => 'directory',
	path   => '/var/www/${sitename}/data',
	mode   => '0755',
	before => File['create-conf-apache'];

	  'create-conf-apache':
	ensure => 'present',
	source => '/etc/apache2/sites-available/000-default.conf',
	path   => '/etc/apache2/sites-available/${sitename}.conf',
	before => Exec['changement-conf'];
	}

	exec {
	  'changement-conf':
        command =>  'sed -i \'s/html/${sitename}/g\' /etc/apache2/sites-enabled/${sitename}.conf && sed -i \'s/#ServerName www.example.com/ServerName ${sitename}.wiki/g\' /etc/apache2/sites-enabled/${sitename}.conf',
        path => ['/usr/bin', '/usr/sbin',],
	}
	
	exec { 
	   'start':
	path	=> ['/usr/bin/', '/usr/sbin'],
	command => 'a2ensite ${sitename}';
	}	
}

node 'control' {
	
	include require_packages
}


node 'server0' {

	class { 'install_wiki':
	  sitename => 'politique',
	  hostname => 'politique.wiki',
	}
	include require_packages
	include extract_doku
	include install_wiki	
}

node 'server1' {

        class { 'install_wiki':
          sitename => 'recettes',
	  hostname => 'recettes.wiki',
        }

	include require_packages
	include extract_doku
	include install_wiki
}
