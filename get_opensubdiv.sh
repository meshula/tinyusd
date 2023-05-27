cd packages
curl -# -L -o osd.zip https://github.com/PixarAnimationStudios/OpenSubdiv/archive/v3_5_0.zip
unzip osd.zip
cd OpenSubdiv-3_5_0
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=../../ -DNO_EXAMPLES=ON -DNO_TUTORIALS=ON -DNO_REGRESSION=ON -DNO_DOC=ON -DNO_OMP=ON -DNO_CUDA=ON -DNO_OPENCL=ON -DNO_DX=1ON-DNO_TESTS=ON -DNO_GLFW=ON -DNO_GLEW=ON -DNO_PTEX=ON -DNO_TBB=ON
cmake --build . --config Release --target install
cd ../..
