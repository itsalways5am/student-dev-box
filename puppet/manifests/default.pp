$as_vagrant   = 'sudo -u vagrant -H bash -l -c'
$home         = '/home/vagrant'

Exec {
  path => ['/usr/sbin', '/usr/bin', '/sbin', '/bin']
}

# --- Preinstall Stage ---------------------------------------------------------

stage { 'preinstall':
  before => Stage['main']
}

class apt_get_update {
  exec { 'apt-get -y update':
    unless => "test -e ${home}/.rbenv"
  }
}
class { 'apt_get_update':
  stage => preinstall
}

# --- SQLite -------------------------------------------------------------------

package { ['sqlite3', 'libsqlite3-dev']:
  ensure => installed;
}

# --- PostgreSQL ---------------------------------------------------------------

class install_postgres {
  class { 'postgresql': }

  class { 'postgresql::server': }

  pg_user { 'rails':
    ensure   => present,
    createdb => true,
    require  => Class['postgresql::server']
  }

  pg_user { 'vagrant':
    ensure    => present,
    superuser => true,
    require   => Class['postgresql::server']
  }

  package { 'libpq-dev':
    ensure => installed
  }

  package { 'postgresql-contrib':
    ensure  => installed,
    require => Class['postgresql::server'],
  }
}
class { 'install_postgres': }

# --- Packages -----------------------------------------------------------------

package { 'curl':
  ensure => installed
}

package { 'build-essential':
  ensure => installed
}

package { 'git-core':
  ensure => installed
}

package { 'vim':
  ensure => installed
}

# rmagick dependencies.
package { 'libmagickwand-dev':
  ensure => installed
}

# Nokogiri dependencies.
package { ['libxml2', 'libxml2-dev', 'libxslt1-dev']:
  ensure => installed
}

# ExecJS runtime.
package { 'nodejs':
  ensure => installed,
  require => Apt::Ppa['ppa:chris-lea/node.js'],
}

package { 'zsh':
  ensure => installed
}

# --- Configuration Files ---------------------------------------------------------------------

class { 'dotfiles': }

# --- Ruby ---------------------------------------------------------------------

class { 'rbenv': install_dir => "${home}/.rbenv" }
$rubyver = '2.1.1'

rbenv::plugin { ['sstephenson/ruby-build', 'rkh/rbenv-update', 'sstephenson/rbenv-gem-rehash']: }
rbenv::build { $rubyver: global => true }
rbenv::gem { 'pry': ruby_version => $rubyver }
rbenv::gem { 'hirb': ruby_version => $rubyver }
rbenv::gem { 'rmagick': ruby_version => $rubyver }
rbenv::gem { 'nokogiri': ruby_version => $rubyver }

# --- Node ---------------------------------------------------------------------

class { 'apt': }
apt::ppa { 'ppa:chris-lea/node.js': }

# --- Zsh and Oh-My-Zsh ---------------------------------------------------------------------

class { 'ohmyzsh': }
ohmyzsh::install { 'vagrant': }
