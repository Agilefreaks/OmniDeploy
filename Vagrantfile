# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = 'ubuntu/trusty64'
  config.ssh.forward_agent = true

  config.vm.provider :digital_ocean do |digital, override|
    override.vm.box = 'digital_ocean'
    override.ssh.private_key_path = "~/.ssh/id_rsa"

    digital.token                = ENV['DIGITAL_OCEAN_TOKEN']
    digital.image                = "Ubuntu-14.04-x64"
    digital.region               = "ams3"
    digital.size                 = "512MB"
    digital.private_networking   = "true"
    digital.ssh_key_name         = ENV['DIGITAL_SSH_KEY_NAME']
    digital.domain               = 'omnipasteapp.com'
  end

  config.trigger.after [ :up, :resume, :provision ], :stdout => true, :vm => /^((?!mongo|redis|sidekiq).)*$/ do
    info 'Update infrastructure'
    run "scripts/update_infra #{@machine.name} up"
    info 'Reinitialize LBs'
    run 'scripts/reinitialize_lbs'
  end

  config.trigger.before [ :destroy, :suspend, :halt ], :stdout => true, :vm => /^lb/ do
    info 'Update infrastructure'
    run "scripts/update_infra #{@machine.name} down"
  end

  config.trigger.before [ :destroy, :suspend, :halt ], :stdout => true, :vm => /^((?!mongo|lb|redis|sidekiq).)*$/ do
    info 'Update infrastructure'
    run "scripts/update_infra #{@machine.name} down"
    info 'Reinitialize LBs'
    run 'scripts/reinitialize_lbs'
  end

  define_machine = ->(name) { config.vm.define(name) { |machine| machine.vm.hostname = name } }

  2.times { |i| define_machine.call("lb0#{i + 1}") }

  2.times do |i|
    name = "webproduction0#{i + 1}"
    config.vm.define(name) do |machine|
      machine.vm.hostname = name
      machine.vm.provider :digital_ocean do |digital|      
        digital.size = '1GB'
      end
    end
  end

  2.times { |i| define_machine.call("apiproduction0#{i + 1}") }

  2.times { |i| define_machine.call("syncproduction0#{i + 1}") }
  
  1.times { |i| define_machine.call("apistaging0#{i + 1}") }

  1.times { |i| define_machine.call("webstaging0#{i + 1}") }

  1.times { |i| define_machine.call("syncstaging0#{i + 1}") }

  3.times { |i| define_machine.call("mongo#{i}") }

  1.times { |i| define_machine.call("redis#{i}") }

  1.times { |i| define_machine.call("sidekiqproduction#{i}") }

  1.times { |i| define_machine.call("sidekiqstaging#{i}") }

  config.vm.define 'admin' do |machine|
    machine.vm.hostname = 'admin'
  end

  config.vm.provision :shell, path: "scripts/puppet.sh" 

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = 'puppet/manifests'
    puppet.module_path = 'puppet/modules'
    puppet.manifest_file  = 'site.pp'
    puppet.options = '--verbose'
    puppet.facter = { 
    	newrelic_license_key: ENV['NEWRELIC_LICENSE_KEY'], 
    	required_ruby_version: '2.2.0', 
      required_rvm_version: '1.26.9',
      required_redis_version: '2.8.4',
    	authorized_keys: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFil+rudpl92tedkYrDrJuwDjDySkgPsbEy1dGk300H4u+7/0tjTr/f6iOuMKsJOLzS/zyVSIsyOAB2E99b8oe4D0oqAdBASmW6LOOYVvgEcsE5YEfiexgfYnwxnt39OYkEeD9V+t5EiVqyRgWrppzfqDQZo0c+ps9nEDJ1EV5dIczH4L4emlXabhxrMLboTLRHR7Qj1R78TPculiif7QD7gqhsGxeNhcNIMdIC3V3flkp2aB4Lfuns5Y50JIracQqHeo3rYtyWxvc7CPI1DEfpDdfYnbUA5bVVPWexZlr2DAgmZbc4w1h7wsD6YY2edvyrn9bI20/Ynj7fpeoE+F/ calinoiu.alexandru@agilefreaks.com
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAykqB2SSUuBnUeSBXncOpk9Ca8RHYCNwEHw4YY+GLwFN5LqoJAbSBoSiKK1w++OKdIj9fHUAtkgEPOT9fUi73DWKqqC9IYUXMFFU31jOKkhkkS4chvcVo7ObMROx89hgOCYEoowKP743mdCBhKvlNSmDwMLmXH890PaYqbS0F8XVrkbi+RdYpGi2jXDBOYnlyZCxcmVnVsed1qr6pxSxt6qNT5fSIcGxwhSVfrpQgZiaUNsPmkxppBPd9kim9Kitmzhs4rBDyInTrpg9V/V6jPOpYSli4LDCdsHudfvCTzkJn2RYR92rd1Iy6uptAOoguqxGxV6+qN/cQm3+59AUIcw==
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCwXtGbj57aLJVqHb2kA9B4mC7AgCYTu8L1vTXbhgPzHf20bkqyCmwNIW7+Ua+fFx4qmuHQS1CLA22fvP9pjFRIhcX2vKSoSoVcmJKdAmWJrv379mLilucXJG0uEsdfieM/BFEdY5ED+ifDcTxyUNHMA9C7yaV6AoDu24QaZGRrnrvGko4qVxl5XdH5VZJcfPTQhHgiklt/9qWamQuq4VjGzTF3C4vODmMzo7rz2F9QOVZeAe23A8BpO4Skalty59nkTV6oVaLL8oxC9nGJsUFW2wEAP/G/No0uNQO9lt/O4UbPBj+VAnDzLk/znTCJMf/jQ29zwQSfCVGSM4Bfo6on' }
  end
end
