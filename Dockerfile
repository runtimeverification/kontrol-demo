FROM ghcr.io/foundry-rs/foundry:nightly-aeba75e4799f1e11e3daba98d967b83e286b0c4a as FOUNDRY

FROM ubuntu:jammy

ENV TZ America/Chicago
ENV DEBIAN_FRONTEND=noninteractive

RUN    apt-get update           \
    && apt-get upgrade --yes    \
    && apt-get install --yes    \
            curl                \
            sudo

COPY --from=FOUNDRY /usr/local/bin/forge /usr/local/bin/forge
COPY --from=FOUNDRY /usr/local/bin/anvil /usr/local/bin/anvil
COPY --from=FOUNDRY /usr/local/bin/cast /usr/local/bin/cast

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ARG USER=user
ARG GROUP=${USER}
ARG USER_ID=1000
ARG GROUP_ID=${USER_ID}
RUN    groupadd -g ${GROUP_ID} ${USER} \
    && useradd -m -u ${USER_ID} -s /bin/sh -g ${GROUP} -G sudo ${USER}

RUN echo "${USER} ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers

USER user:user
WORKDIR /home/user
