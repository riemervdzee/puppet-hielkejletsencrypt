class hielkejletsencrypt (
  Stdlib::Absolutepath $base_dir,
  Boolean $use_production_ca,
  Stdlib::Httpsurl $production_ca,
  Stdlib::Httpsurl $staging_ca,
  Boolean $manage_cron,
  String $account_mail,

  Integer $key_length,
  String $private_key_alg,
  Boolean $reuse_private_key,
  Integer $renew_allow,
  String $server_type,
  Boolean $check_remote,
  Stdlib::Absolutepath $ssl_conf,
) {

  # Select correct CA
  if $use_production_ca {
    $ca = $production_ca
  } else {
    $ca = $staging_ca
  }

  # Create Base Directories
  file { $base_dir:
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => '0755',
  }
  file { "${base_dir}/conf":
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => '0755',
  }
  file { "${base_dir}/getssl":
    ensure => file,
    force  => true,
    owner  => root,
    group  => root,
    mode   => '0700',
    source => 'puppet:///modules/hielkejletsencrypt/getssl',
  }

  file { "${base_dir}/conf/getssl.cfg":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => epp('hielkejletsencrypt/global_getssl.cfg.epp', {
      'ca'                 => $ca,
      'account_mail'       => $account_mail,
      'account_key_length' => $key_length,
      'base_dir'           => $base_dir,
      'private_key_alg'    => $private_key_alg,
      'reuse_private_key'  => $reuse_private_key,
      'renew_allow'        => $renew_allow,
      'server_type'        => $server_type,
      'check_remote'       => $check_remote,
      'ssl_conf'           => $ssl_conf,
    }),
  }

  if $manage_cron and (size($facts['letsencryptcerts']) > 0) {
    cron { 'getssl_renew':
      ensure  => present,
      command => "${base_dir}/getssl -w ${base_dir}/conf -a -q -U",
      user    => 'root',
      hour    => '23',
      minute  => '5',
    }
  }
}
