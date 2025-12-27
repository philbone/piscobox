Vagrant.configure("2") do |config|
  # ============================================================================
  # CONFIGURACIÓN BASE
  # ============================================================================
  config.vm.box = "debian/bullseye64"
  config.vm.hostname = "piscobox"
  
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 2
    vb.name = "PiscoBox-0.1.0-Dev"
  end

config.vm.network "private_network", ip: "192.168.56.100" 

end