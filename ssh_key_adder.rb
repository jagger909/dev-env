#!/usr/bin/ruby

ENV_KEY = "AUTHORIZED_GH_USERS"

begin
  `mkdir /root/.ssh`
  `touch /root/.ssh/authorized_keys`
  ENV[ENV_KEY].split(",").map(&:strip).each do |username|
    output = `gh-auth add --users=#{username} --command="/bin/zsh"`
    if output.include?("Adding 0 key")
      puts <<-EOS
        The user '#{username}' either does not exist on GitHub or does not have
        any SSH keys uploaded!
      EOS
      exit 1
    end

    puts "Authorized SSH key(s) for #{username}..."
  end
rescue
  puts <<-EOS
    You need to specify an #{ENV_KEY} environment variables as a
    comma-separated list of GitHub users whose SSH keys should be authorized to
    connect to this machine!
  EOS
  exit 1
end
