FROM jenkins/jenkins

USER root

RUN apt-get update && apt-get install -y docker.io && rm -rf /var/lib/apt/lists/*
RUN usermod -aG docker jenkins
RUN curl https://get.helm.sh/helm-v3.15.3-linux-arm64.tar.gz | tar zxf -
RUN cp linux-arm64/helm /usr/local/bin 
RUN rm -rf linux-arm64
RUN apt-get update && apt-get --assume-yes install jq && rm -rf /var/lib/apt/lists/*
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

USER jenkins

COPY config /var/jenkins_home/.kube/config
COPY client.key /var/jenkins_home/.kube/client.key
COPY ca.crt /var/jenkins_home/.kube/ca.crt
COPY client.crt /var/jenkins_home/.kube/client.crt
COPY myapp /var/jenkins_home/.kube/myapp

# COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
# COPY jenkins-configuration.yaml /var/jenkins_home/jenkins-configuration.yaml

# ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
# ENV CASC_JENKINS_CONFIG /var/jenkins_home/jenkins-configuration.yaml
# RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt
