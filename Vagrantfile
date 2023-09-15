Vagrant.configure("2") do |config|
  config.vm.box = "nvkmv/rockylinux9"
  config.vm.synced_folder "./data", "/home/vagrant/data"
  config.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "~/.ssh/me.pub"
  config.vm.provision "shell", inline: <<-SHELL
    cat /home/vagrant/.ssh/me.pub >> /home/vagrant/.ssh/authorized_keys
    mkdir /root/.ssh
    cat /home/vagrant/.ssh/me.pub >> /root/.ssh/authorized_keys
    SHELL
  #config.vm.provider "virtualbox" do |vb|
  #  vb.memory = "1024"
  #  vb.cpus = 1
  #end

  config.vm.define "replica" do |replica|
    replica.vm.network "private_network", ip: "192.168.56.109"
    replica.vm.hostname = "replica"
    replica.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
    end  
  end

  config.vm.define "db" do |db|
    db.vm.network "private_network", ip: "192.168.56.110"
    db.vm.hostname = "db"
    db.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
    end  
  end

  config.vm.define "app" do |app|
    app.vm.network "private_network", ip: "192.168.56.111"
    app.vm.network "forwarded_port", guest: 80, host: 8080
    app.vm.hostname = "app"
    app.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
    end  
  end
  
  config.vm.define "app2" do |app2|
    app2.vm.network "private_network", ip: "192.168.56.112"
    app2.vm.network "forwarded_port", guest: 80, host: 8090
    app2.vm.hostname = "app2"
    app2.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
    end  
  end

end
