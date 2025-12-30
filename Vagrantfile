Vagrant.configure("2") do |config|
  # ============================================================================
  # BASE CONFIGURATION
  # ============================================================================
  config.vm.box = "debian/bullseye64"
  config.vm.hostname = "piscobox"
  
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 2
    vb.name = "PiscoBox-0.1.0-Dev"
  end

  config.vm.network "private_network", ip: "192.168.56.110"
  config.vm.network "forwarded_port", guest: 80, host: 8080

  # ============================================================================
  # FOLDER SYNCHRONIZATION
  # ============================================================================
  config.vm.synced_folder "./public_html", "/var/www/html",
    owner: "www-data", group: "www-data",
    mount_options: ["dmode=755", "fmode=644"]

  config.vm.synced_folder "./extra_data", "/var/extra_data",
    owner: "www-data", group: "www-data",
    mount_options: ["dmode=770", "fmode=660"],
    create: true

  config.vm.synced_folder "./provision/files", "/var/provision/files",
    create: true

  # ============================================================================
  # MODULAR PROVISIONING
  # ============================================================================
  config.vm.provision "shell", path: "provision/scripts/print-banner.sh"
  config.vm.provision "shell", path: "provision/scripts/base-system.sh"
  config.vm.provision "shell", path: "provision/scripts/apache.sh"

end