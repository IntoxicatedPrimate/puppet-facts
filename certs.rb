#!/usr/bin/ruby

require 'facter'
require 'time'
require 'openssl'

pkidir = '/etc/pki/tls/certs'
epoch = Time.now.to_i
epoch2w = epoch + (86400 * 14)

$certs_expired = Array.new
$certs_valid = Array.new
$certs_twoweeksnotice = Array.new

if File.exists?(pkidir)
  Dir.foreach(pkidir) do |file|
    next if file == '.' or file == '..'

    begin
      rawcert = File.read(pkidir + "/" + file)
      notafter =  OpenSSL::X509::Certificate.new(rawcert).not_after
      notafterepoch = Time.at(notafter).to_i

      if epoch > notafterepoch
        $certs_expired.push(file)
      elsif epoch2w > notafterepoch
        $certs_twoweeksnotice.push(file)
      else
        $certs_valid.push(file)
      end
    rescue
      next
    end

  end

  if ! $certs_expired.empty?
    Facter.add('certs_expired') do
      setcode do
        $certs_expired.join(" ")
      end
    end
  end

  if ! $certs_twoweeksnotice.empty?
    Facter.add('certs_twoweeksnotice') do
      setcode do
        $certs_twoweeksnotice.join(" ")
      end
    end
  end

  if ! $certs_valid.empty?
    Facter.add('certs_valid') do
      setcode do
        $certs_valid.join(" ")
      end
    end
  end

end
