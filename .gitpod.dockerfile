# Copyright (c) 2020 Gitpod GmbH. All rights reserved.
# Licensed under the GNU Affero General Public License (AGPL).
# See License-AGPL.txt in the project root for license information.

FROM gitpod/workspace-full-vnc:latest

USER root

### Helm3 ###
RUN mkdir -p /tmp/helm/ \
    && curl -fsSL https://get.helm.sh/helm-v3.8.1-linux-amd64.tar.gz | tar -xzvC /tmp/helm/ --strip-components=1 \
    && cp /tmp/helm/helm /usr/local/bin/helm \
    && ln -s /usr/local/bin/helm /usr/local/bin/helm3 \
    && rm -rf /tmp/helm/ \
    && helm completion bash > /usr/share/bash-completion/completions/helm

### kubernetes ###
RUN mkdir -p /usr/local/kubernetes/ && \
    curl -fsSL https://github.com/kubernetes/kubernetes/releases/download/v1.22.4/kubernetes.tar.gz \
    | tar -xzvC /usr/local/kubernetes/ --strip-components=1 \
    && KUBERNETES_SKIP_CONFIRM=true /usr/local/kubernetes/cluster/get-kube-binaries.sh \
    && chown gitpod:gitpod -R /usr/local/kubernetes

ENV PATH=$PATH:/usr/local/kubernetes/cluster/:/usr/local/kubernetes/client/bin/

### kubectl ###
RUN curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
    # really 'xenial'
    && add-apt-repository -yu "deb https://apt.kubernetes.io/ kubernetes-xenial main" \
    && install-packages kubectl=1.22.4-00 \
    && kubectl completion bash > /usr/share/bash-completion/completions/kubectl

RUN curl -fsSL -o /usr/bin/kubectx https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx && chmod +x /usr/bin/kubectx \
    && curl -fsSL -o /usr/bin/kubens  https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens  && chmod +x /usr/bin/kubens

RUN curl -fsSL https://github.com/kubernetes-sigs/kubebuilder/releases/download/v2.3.2/kubebuilder_2.3.2_linux_amd64.tar.gz | tar -xz -C /tmp/ \
    && sudo mkdir -p /usr/local/kubebuilder \
    && sudo mv /tmp/kubebuilder_2.3.2_linux_amd64/* /usr/local/kubebuilder \
    && rm -rf /tmp/*

# yq - jq for YAML files
# Note: we rely on version 3.x.x in various places, 4.x breaks this!
RUN cd /usr/bin && curl -fsSL https://github.com/mikefarah/yq/releases/download/3.4.1/yq_linux_amd64 > yq && chmod +x yq
# yq4 as separate binary
RUN cd /usr/bin && curl -fsSL https://github.com/mikefarah/yq/releases/download/v4.23.1/yq_linux_amd64 > yq4 && chmod +x yq4



### AWS Cli ###
RUN sudo python3 -m pip install --no-cache-dir awscli

# Install aws-iam-authenticator
RUN sudo curl -fsSL -o aws-iam-authenticator "https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/aws-iam-authenticator" \
    && sudo chmod +x ./aws-iam-authenticator \
    && sudo mkdir -p $HOME/.aws-iam \
    && sudo mv ./aws-iam-authenticator $HOME/.aws-iam/aws-iam-authenticator \
    && sudo chown -R gitpod:gitpod $HOME/.aws-iam

# Install Terraform
ARG RELEASE_URL="https://releases.hashicorp.com/terraform/1.1.7/terraform_1.1.7_linux_amd64.zip"
RUN mkdir -p ~/.terraform \
    && cd ~/.terraform \
    && curl -fsSL -o terraform_linux_amd64.zip ${RELEASE_URL} \
    && unzip *.zip \
    && rm -f *.zip \
    && printf "terraform -install-autocomplete 2> /dev/null\n" >>~/.bashrc

ENV PATH=$PATH:$HOME/.aws-iam:$HOME/.terraform
