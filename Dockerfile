# Use official Erlang image instead of building from source
FROM erlang:27 AS builder

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    pkg-config \
    libssl-dev \
    curl \
    ca-certificates \
    autoconf \
    automake \
    libtool \
    wget \
    libc6-dev \
    libpthread-stubs0-dev

# Install rebar3
RUN git clone https://github.com/erlang/rebar3.git && \
    cd rebar3 && \
    ./bootstrap && \
    mv rebar3 /usr/local/bin/

# install node 22 (used by genesis_wasm profile)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    node --version

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Disable Spectre mitigations for WAMR build (not supported by GCC 12.2)
ENV CFLAGS="-O2"
ENV CXXFLAGS="-O2"

WORKDIR /opt

COPY . .

# compile the project with provided profiles
RUN rebar3 clean && rebar3 get-deps && rebar3 as genesis_wasm release

FROM ubuntu:22.04 AS runner

WORKDIR /opt

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    libssl3 \
    libncurses6

# Install Erlang runtime (minimal)
COPY --from=builder /usr/local/lib/erlang /usr/local/lib/erlang
ENV PATH="/usr/local/lib/erlang/bin:${PATH}"

# node 22 is still needed for genesis_wasm profile
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    node --version

# copy the build artifacts from the builder stage
COPY --from=builder /opt/_build/ /opt/_build/

# bin bash here to start the container
ENTRYPOINT ["/opt/_build/genesis_wasm/rel/hb/bin/hb"]