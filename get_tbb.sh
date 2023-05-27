echo "Getting TBB - note that this script builds only arm64"
cd packages
curl -# -L -o tbb_2019_U6.zip https://github.com/oneapi-src/oneTBB/archive/refs/tags/2019_U6.zip
unzip tbb_2019_U6.zip
cp ../flotsam/tbb/macos.clang.inc oneTBB-2019_U6/build/
cd oneTBB-2019_U6
make -j4 arch=arm64
cp build/*_release/libtbb*.* ../lib/
cp -r include/serial/ ../include/serial
cp -r include/tbb/ ../include/tbb
cd ..
