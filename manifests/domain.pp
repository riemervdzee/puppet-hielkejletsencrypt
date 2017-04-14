define hielkejletsencrypt::domain (
  String $domain                   = $title,
  Optional[Array] $subdomains      = [],

  Stdlib::Absolutepath $acl        = '/var/www/acme-challenge/',
  Boolean $use_single_acl          = true,

  Stdlib::Absolutepath $base_dir   = '/etc/ssl/letsencrypt',

  String $server_type              = 'https',
  Boolean $check_remote            = true,
  Optional[String] $restartService = '',
) {

  if $restartService != '' and $facts['letsencryptcerts'][$domain] {
    file { "${base_dir}/conf/${domain}/certhash.txt":
      ensure  => file,
      owner   => root,
      group   => root,
      mode    => '0600',
      content => $facts['letsencryptcerts'][$domain],
      notify  => Service[$restartService]
    }
    $notify = Service[$restartService]
  }

  file { "${base_dir}/conf/${domain}":
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => '0644',
  }

  $getssl_exec = "${base_dir}/getssl -U -w ${base_dir}/conf -q ${domain}"

  file { "${base_dir}/conf/${domain}/getssl.cfg":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => epp('hielkejletsencrypt/domain_getssl.cfg.epp', {
      'domain'         => $domain,
      'sub_domains'    => $subdomains,
      'acl'            => $acl,
      'use_single_acl' => $use_single_acl,
      'server_type'    => $server_type,
      'check_remote'   => $check_remote,
    }),
    notify  => [ Exec[$getssl_exec] ],
  }

  exec { $getssl_exec:
    path        => ['/bin', '/usr/bin', '/usr/sbin', $base_dir],
    refreshonly => true,
  }
}
