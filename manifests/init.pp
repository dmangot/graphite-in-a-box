
# looks like there is an old version of Puppet on here, might want to be nice and upgrade
#package { 'puppetyum-setup':
  # ensure => installed,
  #provider => rpm,
  # source => 'http://yum.puppetlabs.com/el/6/products/i386/puppetlabs-release-6-7.noarch.rpm',
#}

package { 'EPEL-repo':
    ensure   => installed,
    name     => 'epel-release-6-8.noarch',
    provider => rpm,
    source   => 'http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm',
  }

$python_prereqs = [ 'python-pip', 'python-devel']

package { $python_prereqs:
  ensure  => latest,
  require => Package['EPEL-repo']
}

$pip_pkgs = [ 'graphite-web', 'carbon', 'whisper']

package { $pip_pkgs:
  ensure   => present,
  provider => pip,
  require  => Package[ $python_prereqs ],
}

service { 'carbon-cache':
    ensure  => running,
    stop    => '/opt/graphite/bin/carbon-cache stop',
    start   => '/opt/graphite/bin/carbon-cache start',
    status  => '/opt/graphite/bin/carbon-cache status',
    require => Package['carbon','whisper'],
}

# also graphite.conf and httpd.conf

file { '/etc/httpd/conf.d/0NameVirtualHost.conf':
  ensure  => present,
  content => 'NameVirtualHost *:80',
  require => Package['httpd'],
  notify  => Service['httpd'],
}
file { '/etc/httpd/conf.d/graphite.conf':
  ensure  => present,
  source  => '/opt/graphite/examples/example-graphite-vhost.conf',
  require => Package['httpd','graphite-web'],
  notify  => Service['httpd'],
}

# could probably clean this up, defined type
file { '/opt/graphite/conf/carbon.conf':
  ensure  => present,
  source  => '/opt/graphite/conf/carbon.conf.example',
  require => Package['carbon'],
  notify  => Service['httpd'],
}
file { '/opt/graphite/conf/storage-schemas.conf':
  ensure  => present,
  source  => '/opt/graphite/conf/storage-schemas.conf.example',
  require => Package['carbon'],
  notify  => Service['httpd'],
}
file { '/opt/graphite/conf/graphite.wsgi':
  ensure  => present,
  source  => '/opt/graphite/conf/graphite.wsgi.example',
  require => Package['carbon'],
  notify  => Service['httpd'],
}

# needed for info.log and exception.log
file { '/opt/graphite/storage/log/webapp':
  ensure => directory,
  group  => apache,
  mode   => '0775',
}

# needed for graphite.db
file { '/opt/graphite/storage':
  ensure => directory,
  group  => apache,
  mode   => '0775',
}

# http://obfuscurity.com/2012/04/Unhelpful-Graphite-Tip-4
exec { 'syncdb':
    command => '/usr/bin/python /opt/graphite/webapp/graphite/manage.py syncdb --noinput',
    unless  => '/usr/bin/python /opt/graphite/webapp/graphite/manage.py inspectdb | grep account_mygraph',
    require => Package['graphite-web'],
}


$system_pkgs = [ 'python-twisted', 'python-django-tagging', 'Django14','httpd', 'mod_wsgi', 'pycairo', 'bitmap-fonts-compat']
package { $system_pkgs:
    ensure  => latest,
    require => Package['EPEL-repo']
}

service { 'iptables':
    ensure => stopped,
    enable => false,
}

service { 'httpd':
    ensure  => running,
    require => Package['graphite-web',$system_pkgs],
}