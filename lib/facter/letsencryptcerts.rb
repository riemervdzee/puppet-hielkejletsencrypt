require "digest"
Facter.add(:letsencryptcerts) do
  setcode do
    letsencryptcerts = {}
    baseDir = '/etc/ssl/letsencrypt/conf/'

    Dir.foreach(baseDir) do |item|
      next if item == '.' or item == '..'

      if File.directory?("#{baseDir}#{item}") and
       File.file?("#{baseDir}#{item}/#{item}.crt") and
       File.file?("#{baseDir}#{item}/getssl.cfg")

        age_in_days = (Date.today - File.mtime("#{baseDir}#{item}/#{item}.crt").to_date).to_i

        if age_in_days <= 90
          letsencryptcerts[item] = Digest::SHA2.file("#{baseDir}#{item}/#{item}.crt").hexdigest
        end
      end
    end

    letsencryptcerts
  end
end
