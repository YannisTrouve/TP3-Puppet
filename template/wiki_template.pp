$src_dir = '/usr/src'
$dokuwiki_archive = "${src_dir}/dokuwiki.tgz"
$dokuwiki_dir = "${src_dir}/dokuwiki-2020-07-29"

# Déclare les packages nécessaire au systeme
package {
  'apache2':
    ensure => present;
  'php7.3':
    ensure => present;
}

file {
  '/usr/src/dokuwiki.tgz':
    ensure => 'present',
    source => 'https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz',
}

exec {
  'dokuwiki::unarchive':
    cwd     => "${src_dir}",
    command => "tar xavf ${dokuwiki_archive}",
    creates => "${dokuwiki_dir}",
    path    => ['/bin'],
    require => File["${dokuwiki_archive}"],
}

$site_hostname = 'politique.wiki'
$site_dir = 'politique-wiki'

file {
  # 'dokuwiki::rename_dir':
  #   ensure  => 'present',
  #   source  => '/usr/src/dokuwiki-2020-07-29',
  #   path    => '/usr/src/dokuwiki',
  #   recurse => true,
  #   require => Exec['dokuwiki::unarchive'];

  '/var/www/recettes-wiki':
    ensure  => 'directory',
    owner   => 'www-data',
    group   => 'www-data',
    # mode    => '0755',
    source  => "${dokuwiki_dir}",
    recurse => true;

  '/var/www/politique-wiki':
    ensure  => 'directory',
    owner   => 'www-data',
    group   => 'www-data',
    # mode    => '0755',
    source  => "${dokuwiki_dir}",
    recurse => true;

  '/etc/apache2/sites-available/politique-wiki.conf':
    ensure  => present,
    content => template('/home/vagrant/template/site.conf.erb'),
    require => [Package['apache2'],
                File['/var/www/politique-wiki']];

#  '/etc/apache2/sites-available/recettes-wiki.conf':
#    ensure  => present,
#    content => template('./site.conf.erb'),
#    require => [Package['apache2'],
#                File['/var/www/recettes-wiki']];
}

exec {
  'enable-vhost-1':
    command => 'a2ensite politique-wiki',
    path    => ['/usr/bin', '/usr/sbin'],
    require => [File['/etc/apache2/sites-available/politique-wiki.conf'],
                Package['apache2']];

#  'enable-vhost-2':
#    command => 'a2ensite recettes-wiki',
#    path    => ['/usr/bin', '/usr/sbin'],
#    require => [File['/etc/apache2/sites-available/recettes-wiki.conf'],
#                Package['apache2']];
}

service {
  'apache2':
    ensure    => running,
    subscribe => [Exec['enable-vhost-1']],
                  #Exec['enable-vhost-2']],
}

host {
  'recettes.wiki':
    ip => '127.0.0.1';
  'politique.wiki':
    ip => '127.0.0.1';
}

