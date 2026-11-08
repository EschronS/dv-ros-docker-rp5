FROM ros:noetic-ros-base

# ── system deps ──────────────────────────────────────────────────────────────
# software-properties-common: needed for add-apt-repository
# libboost-all-dev: lockfree queue etc. used by capture node
# libfmt-dev: fmt logging library
# libusb-1.0-0: USB camera access from inside the container
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    curl gnupg \
    libboost-all-dev \
    libfmt-dev \
    libusb-1.0-0 \
    python3-catkin \
    python3-catkin-tools \
    python3-catkin-tools \
    ros-noetic-catkin \
    ros-noetic-camera-info-manager \
    ros-noetic-image-view \
    ros-noetic-tf2 \
    ros-noetic-tf2-ros \
    ros-noetic-tf2-sensor-msgs \
    ros-noetic-sensor-msgs \
    ros-noetic-cv-bridge \
    tmux \
    vim \
    jq \
    clangd-18 \
    clang \
    && rm -rf /var/lib/apt/lists/*

# GUI only for testing, throw out if headless
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-noetic-rqt \
    ros-noetic-rqt-common-plugins \
    && rm -rf /var/lib/apt/lists/*

# ── inivation PPA ─────────────────────────────────────────────────────────────


# The PPA ships dv-processing for focal arm64.
# ubuntu-toolchain-r/test is required first (their dep).
RUN add-apt-repository ppa:ubuntu-toolchain-r/test -y
# RUN curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x1E9377A2BA9EF27F" \
#         | gpg --dearmor -o /usr/share/keyrings/ubuntu-toolchain-r.gpg && \
#     echo "deb [signed-by=/usr/share/keyrings/ubuntu-toolchain-r.gpg] https://ppa.launchpadcontent.net/ubuntu-toolchain-r/test/ubuntu focal main" \
#         > /etc/apt/sources.list.d/ubuntu-toolchain-r.list 
RUN add-apt-repository ppa:inivation-ppa/inivation -y
# COPY inivation.gpg /usr/share/keyrings/inivation.gpg
# RUN echo "deb [signed-by=/usr/share/keyrings/inivation.gpg] https://ppa.launchpadcontent.net/inivation-ppa/inivation/ubuntu focal main" \
#     > /etc/apt/sources.list.d/inivation.list

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    dv-processing=2.0.4-1~focal \
    dv-runtime-dev \
    gcc-13 g++-13 && \
    rm -rf /var/lib/apt/lists/*

COPY camera_input_base.patch /tmp/
RUN patch -d / -p1 < /tmp/camera_input_base.patch

# install git
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*

# install vrpn client deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-noetic-geometry-msgs \
    ros-noetic-roscpp \
    ros-noetic-tf2-ros \
    ros-noetic-vrpn \
    ros-noetic-roslint \
    ros-noetic-roslaunch \
    netbase \
    fzf \
    wget \
    libtool \
    autoconf \
    automake \	
    python3-vcstool \
    liblapack-dev \
    libblas-dev \
    ros-noetic-tf \
    ros-noetic-tf2 \
    ros-noetic-tf2-ros \
    ros-noetic-tf-conversions \
    && rm -rf /var/lib/apt/lists/*

# user
ARG UID=1000
ARG GID=1000
ARG USERNAME=myuser

RUN groupadd -g ${GID} mygroup && \
    useradd -u ${UID} -g ${GID} -m ${USERNAME}
    # usermod -aG plugdev ${USERNAME}

USER ${USERNAME}

# ── catkin workspace ──────────────────────────────────────────────────────────
WORKDIR /home/${USERNAME}

COPY Dockerfile /home/${USERNAME}
COPY capture_sess.sh /home/${USERNAME}

# create ~/.config so we can mount singular config folders without messing up ownership
RUN mkdir -p /home/${USERNAME}/.config
RUN echo 'set-option -g default-shell /bin/bash \n \
    set-option -g default-command "bash --login"' >> /home/${USERNAME}/.tmux.conf

RUN echo 'alias builddv="cd /home/$(whoami)/event_ws && source /opt/ros/noetic/setup.bash && \
    catkin build catkin_simple dvs_renderer dv_ros_msgs dv_ros_capture vrpn_client_ros \
    --cmake-args -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER=gcc-13 -DCMAKE_CXX_COMPILER=g++-13 \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && \
    jq -s 'add' build/*/compile_commands.json > src/dv-ros/compile_commands.json"' >> /home/${USERNAME}/.bashrc
#
# # Source the workspace on every shell in the container
RUN echo "source /opt/ros/noetic/setup.bash" >> /home/${USERNAME}/.bashrc
RUN echo "source /home/${USERNAME}/event_ws/devel/setup.bash" >> /home/${USERNAME}/.bashrc
RUN echo "export ARM_ARCHITECTURE=1" >> ~/.bashrc
RUN echo "cd /home/${USERNAME}/event_ws" >> /home/${USERNAME}/ros_entrypoint.sh
RUN echo 'alias sr="source /opt/ros/noetic/setup.bash && source /home/$(whoami)/event_ws/devel/setup.bash"' >> /home/${USERNAME}/.bashrc


CMD ["/bin/bash"]

