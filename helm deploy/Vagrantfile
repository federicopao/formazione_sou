Vagrant.configure("2") do |config|

  config.vm.box = "bento/ubuntu-20.04"
  config.vm.provider "vmware_desktop" do |vb|
    vb.gui = true
  end
  
  N = 1
  (1..N).each do |i|

    config.vm.define "node#{i}" do |node|
      node.vm.hostname = "node#{i}"
      node.vm.network "private_network", ip: "192.168.56.#{20+i}"

      # Only execute once the Ansible provisioner,
      # when all the machines are up and ready.
      if i == N
        node.vm.provision "ansible" do |ansible|
          # Disable default limit to connect to all the machines
          ansible.limit = "all"
          ansible.playbook = "playbook.yml"
          ansible.become = true
          ansible.compatibility_mode = "2.0"
        end
      end

    end

  end

end

