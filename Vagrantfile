Vagrant.configure("2") do |config|
  # ============================================================================
  # BASE CONFIGURATION
  # ============================================================================
  # config.vm.box = "debian/bullseye64"
  config.vm.box = "debian/bookworm64"
  config.vm.hostname = "piscobox"
  
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 2
    vb.name = "PiscoBox-0.2.0-Dev"
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

  config.vm.synced_folder "./provision/cli", "/var/provision/cli",
    create: true

  # ============================================================================
  # MODULAR PROVISIONING
  # ============================================================================
  config.vm.provision "shell", path: "provision/scripts/print-banner.sh"
  config.vm.provision "shell", path: "provision/scripts/base-system.sh"
  config.vm.provision "shell", path: "provision/scripts/motd.sh"
  config.vm.provision "shell", path: "provision/scripts/apache.sh"
  config.vm.provision "shell", path: "provision/scripts/php.sh"
  config.vm.provision "shell", path: "provision/scripts/database.sh"
  config.vm.provision "shell", path: "provision/scripts/phpmyadmin.sh" 
  config.vm.provision "shell", path: "provision/scripts/postgresql.sh"
  config.vm.provision "shell", path: "provision/scripts/xdebug.sh"  

  # ============================================================================
  # POST-INSTALLATION MESSAGE
  # ============================================================================
  config.vm.post_up_message = <<-MESSAGE
  🥂 PISCO BOX - LAMP ENVIRONMENT READY 🎉
  
  Your virtual machine is configured:

  ✅ Base system and repositories
  ✅ PHP 8.3 + PHP-FPM
  ✅ Apache 2.4 + VirtualHost
  ✅ MariaDB
  
  Quick access:  
  • Pisco Box Welcome Site: http://192.168.56.110/
  • PHP INFO:               http://192.168.56.110/info.php
  • SSH access:             vagrant ssh
  
  File structure:
  /path/to/your/piscobox
  ├── doc/                  ← Documentation and collaboration 
  ├── extra_data/           ← Extra data, backups 
  ├── provision/            ← Provisioning scripts 
  ├── public_html/          ← Document root accessible via web 
  ├── utils/                ← Workflow templates and others 
  ├── LICENSE               ← Software License 
  ├── README.md             ← Welcome, basic instructions 
  ├── Vagrantfile           ← Pisco Box configuration 
  └──...

  # Synchronized directory
  /var/www/html             ← Synchronized with public_html/
  
  rebuild:                  vagrant destroy -f && vagrant up
  re-provision:             vagrant provision
  suspend:                  vagrant suspend
  resume:                   vagrant resume
  stop:                     vagrant halt
  MESSAGE

end