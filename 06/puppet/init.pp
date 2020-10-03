class packt_selinux {
  file { "/usr/share/selinux/custom":
    ensure => directory,
    mode => "0755",
  }

  file { 'selinux_custom_module_test':
    path => "/usr/share/selinux/custom/test.cil",
    ensure => file,
    owner => "root",
    group => "root",
    source => "puppet:///modules/packt_selinux/test.cil",
    require => File["/usr/share/selinux/custom"],
    seltype => "usr_t",
  }

  exec { '/usr/sbin/semodule -i /usr/share/selinux/custom/test.cil':
    require => File['selinux_custom_module_test'],
    unless => '/usr/sbin/semodule -l | grep -q ^test$',
  }

  class { selinux:
    mode => 'enforcing',
    type => 'targeted',
  }

  selboolean { 'httpd_builtin_scripting':
    value => off,
  }

  selinux::fcontext { '/srv/web(/.*)?':
    seltype => 'httpd_sys_content_t',
  }

  selinux::fcontext::equivalence { '/srv/www':
    ensure => 'present',
    target => '/srv/web',
  }

  selinux::port { 'set_ssh_custom_port':
    ensure => 'present',
    seltype => 'ssh_port_t',
    protocol => 'tcp',
    port => 10122,
  }

  selinux::permissive { 'zoneminder_t':
    ensure => 'present',
  }

  #selmodule { 'vlock':
  #  ensure => 'present',
  #  selmoduledir => '/usr/share/selinux/custom',
  #}
}
