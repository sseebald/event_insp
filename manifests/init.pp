class event_insp {

  exec {'install vim_env':
    command => 'puppet module install jpadams/puppet_vim_env',
    path    => '/opt/puppet/bin',
    unless  => 'grep -r puppet_vim_env /etc/puppetlabs/puppet/environments/production/modules 2>/dev/null',
    before  => File['/etc/puppetlabs/puppet/environments/production/manifests/site.pp.bak'],
  }

  file {'/etc/puppetlabs/puppet/environments/production/manifests/site.pp.bak':
    ensure => file,
    source => '/etc/puppetlabs/puppet/environments/production/manifests/site.pp',
  }

  @file {'replace':
    ensure  => file,
    path    => '/etc/puppetlabs/puppet/environments/production/manifests/site.pp',
    source  => 'puppet:///modules/event_insp/site.pp',
    require => File['/etc/puppetlabs/puppet/environments/producton/manifests/site.pp.bak'],
  }

  exec {'mco':
    command => 'sudo -i -u peadmin mco puppet runonce -I centos64a -I centos64b -I centos59a',
    path    => ['/bin','/opt/puppet/bin'],
    before  => @File['revert'],
  }

  @file {'revert':
    ensure  => file,
    path    => '/etc/puppetlabs/puppet/environments/production/manifests/site.pp',
    source  => '/etc/puppetlabs/puppet/environments/production/manifests/site.pp.bak',
    require => Exec['mco'],
  }

}
