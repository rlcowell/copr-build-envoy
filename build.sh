export BAZEL_VERSION=0.28.1
export ENVOY_VERSION=envoy
sudo yum -y install wget

#Enable EPEL Repository
sudo yum -y install epel-release

#install The Software Collections ( SCL ) Repository
sudo yum -y install centos-release-scl
sudo yum -y install java-11-openjdk-devel java-11-openjdk zlib-devel pkgconfig findutils gcc-c++ which zip
sudo yum -y install devtoolset-4 rpm-devel pcre-devel cmake3 ninja-build
sudo yum -y install go gperftools gperf yaml-cpp nghttp2 luajit c-ares
sudo yum -y install curl-devel expat-devel gettext-devel openssl-devel zlib-devel perl-devel perl-CPAN
sudo yum -y install devtoolset-4
sudo yum -y install rpm-devel pcre-devel
sudo yum -y install epel-release centos-release-scl
sudo yum -y install fedpkg sudo make which cmake3 rh-git218 automake autoconf autogen libtool ninja-build llvm-toolset-7 devtoolset-7-libatomic-devel

echo 'export PATH=/usr/local/bin:$PATH' | sudo tee -a /etc/bashrc
echo 'export PATH=/usr/local/git/bin:$PATH' | sudo tee -a /etc/bashrc
source /etc/bashrc

#sudo yum -y install git
cd /usr/src
sudo wget https://www.kernel.org/pub/software/scm/git/git-2.9.5.tar.gz
sudo tar xzf git-2.9.5.tar.gz
cd git-2.9.5
sudo make prefix=/usr/local/git all
sudo make prefix=/usr/local/git install

sudo ln -s /usr/bin/cmake3 /usr/bin/cmake
sudo ln -s /usr/bin/ninja-build /usr/bin/ninja

rm -rf ~/bazelbuild
mkdir ~/bazelbuild
wget https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-dist.zip -O ~/bazelbuild/bazel-${BAZEL_VERSION}-dist.zip
cd ~/bazelbuild; unzip bazel-${BAZEL_VERSION}-dist.zip

export EXTRA_BAZEL_ARGS="${EXTRA_BAZEL_ARGS} --host_force_python=PY2"
export SOURCE_DATE_EPOCH="$(date -d $(head -1 CHANGELOG.md | grep -Eo '\b[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}\b' ) +%s)"
export EMBED_LABEL=${BAZEL_VERSION}
export CC=gcc
export CXX=g++
export EXTRA_BAZEL_ARGS="${EXTRA_BAZEL_ARGS} --host_javabase=@local_jdk//:jdk --verbose_failures"
./compile.sh

sudo cp output/bazel /usr/local/bin

# scl enable devtoolset-4 bash
# source /opt/rh/devtoolset-4/enable
mkdir -p ~/git
git clone https://github.com/rlcowell/copr-build-envoy.git ~/git/copr-build-envoy/
cd ~/git/copr-build-envoy/
#
# sed -i 's/5d25f466c3410c0dfa735d7d4358beb76b2da507/bf169f9d3c8f4c682650c5390c088a4898940913/' envoy.spec
# sed -i 's/1\.8\.0\.\%/1\.11\.0\.\%/' envoy.spec
#
# #This takes at least 20 mins to complete
make rpm
#
# ls -la /home/centos/git/copr-build-envoy/x86_64/envoy-1.11.1.0mak.git.e95ef6b-1.el7.centos.x86_64.rpm
