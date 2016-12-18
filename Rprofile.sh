#!/bin/sh
wget https://raw.githubusercontent.com/xr09/rainbow.sh/master/rainbow.sh
source ./rainbow.sh
varUpdate=$(echored "Updating:")
echo "$varUpdate add keys"
wget http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt
rpm -i rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
yum -y groupinstall 'Development Tools'
yum -y install gfortran
yum -y install cmake
yum -y groupinstall "X Window System"
yum -y install readline-devel tcl tk libX11-devel libXtst-devel xorg-x11-xtrans-devel libpng-devel libXt-devel
echo "$varUpdate Install R"
  
wget http://debian.ustc.edu.cn/CRAN/src/base/R-3/R-3.1.2.tar.gz
tar vxf R-3.1.2.tar.gz
  
cd R-3.1.2
./configure --enable-R-shlib
ncores=`cat /proc/cpuinfo | grep "model name" | wc -l`
make -j $ncores
make check
make install
echo "Post Install:"
touch ~/.Rprofile
# USE USTC mirror
echo "r &lt;- getOption('repos');r['CRAN'] &gt; ~/.Rprofile
R -e "source('http://bioconductor.org/biocLite.R');biocLite()"
R -e "install.packages(c('glmnet','e1071','caret'),dependencies=T)"
cd ..
rm -rf R-3.1*
