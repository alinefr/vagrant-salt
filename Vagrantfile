Vagrant.configure("2") do |config|
	config.vm.box = "saucy"
	config.vm.synced_folder "srv/", "/srv/"
	config.vm.provision :salt do |salt|
		salt.minion_config = "srv/minion"
		salt.run_highstate = true
	end
end

Vagrant::Config.run do |config|
  config.vm.forward_port 80, 8000
end

