FROM alpine

ARG VERSION=v0.0.1
ARG TERRAFORM_VERSION=1.1.5
ARG TERRAGRUNT_VERSION=v0.36.1

RUN apk update && \
    apk add --no-cache --purge \
        bash \
        # build requirements for azure
        gcc \
        musl-dev \
        python3-dev \
        libffi-dev \
        openssl-dev \
        cargo \
        make \
        # install dependencies
        git \
        curl \
        upx \
        # runtime dependencies
        python3 \
        py3-pip \
        openssh-client

WORKDIR /src

ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin:/usr/local/bin

# Microsoft Azure CLI
RUN pip install azure-cli && \
    az --version

#RUN cd /src && \
#    mkdir azure && \
#    cd azure && \
#    curl -L https://aka.ms/InstallAzureCli | \
#    bash && \
#    rm -rf /src/azure

# Amazon Cloud CLI
RUN pip install awscli && \
    mkdir ~/.aws && \
    touch ~/.aws/credentials && \
    aws --version

#RUN cd /src && \
#    mkdir aws && \
#    cd aws && \
#    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
#    unzip awscliv2.zip && \
#    ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli && \
#    rm -rf /src/aws

# Google Cloud CLI
RUN pip install \
        google-cloud \
        google-api-python-client \
        google-cloud-storage \
    && \
    cd /src && \
    mkdir gcp && \
    cd gcp && \
    curl "https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz" -o "google-cloud-sdk.tar.gz" && \
    mkdir -p /usr/local/gcloud && \
    tar -C /usr/local/gcloud -xvzf ./google-cloud-sdk.tar.gz && \
    /usr/local/gcloud/google-cloud-sdk/install.sh && \
    rm -rf /src/gcp && \
    cd /src && \
    gcloud --version



# Terraform
RUN cd /src && \
    mkdir terraform && \
    cd terraform && \
    curl -L "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o "terraform.zip" && \
    unzip terraform.zip && \
    mv terraform /usr/local/bin/ && \
    chmod +x /usr/local/bin/terraform && \
    rm -rf /src/terraform && \
    cd /src && \
    terraform --version

# Terragrunt
RUN cd /src && \
    mkdir terragrunt && \
    cd terragrunt && \
    curl -L "https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64" -o "terragrunt" && \
    mv terragrunt /usr/local/bin/ && \
    chmod +x /usr/local/bin/terragrunt && \
    rm -rf /src/terragrunt && \
    cd /src && \
    terragrunt --version

# multicloud terraform 
RUN cd /src && \
    git clone --single-branch https://github.com/pjferrell/terraform-kubernetes-multi-cloud.git \
        terraform-kubernetes-multi-cloud/

#RUN cd /src/terraform-kubernetes-multi-cloud && \
#    terragrunt init



WORKDIR /src/terraform-kubernetes-multi-cloud

ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin:/usr/local/bin
