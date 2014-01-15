class event_insp {

  exec {'install vim_env':
    command => 'puppet module install jpadams/puppet_vim_env',
    path    => ['/opt/puppet/bin','/bin'],
    unless  => 'grep -r puppet_vim_env /etc/puppetlabs/puppet/environments/production/modules 2>/dev/null',
  }

  file {'/etc/puppetlabs/puppet/environments/production/manifests/site.pp.bak':
    ensure  => file,
    source  => '/etc/puppetlabs/puppet/environments/production/manifests/site.pp',
  }

  file_line {'add include':
    line => "node 'centos64a','centos64b','centos64c' { 
    include profile::tomcat 
    include profile::app::jenkins 
    include puppet_vim_env }",
    path    => '/etc/puppetlabs/puppet/environments/production/manifests/site.pp',
    require => File['/etc/puppetlabs/puppet/environments/production/manifests/site.pp.bak'],
  }
  
  exec {'mco':
    command => 'sudo -i -u peadmin mco puppet runonce -I centos64a -I centos64b -I centos59a',
    path    => ['/usr/bin','/opt/puppet/bin'],
    require => File_line['add include'],
  }

  file {'revert':
    ensure  => file,
    path    => '/etc/puppetlabs/puppet/environments/production/manifests/site.pp',
    source  => '/etc/puppetlabs/puppet/environments/production/manifests/site.pp.bak',
  }

}
