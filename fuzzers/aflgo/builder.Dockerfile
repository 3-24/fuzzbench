ARG parent_image
FROM $parent_image

RUN apt-get update && \
    apt-get install -y python3 python3-dev python3-pip &&
    apt-get install -y libboost-all-dev &&
    pip3 install --upgrade pip &&
    pip3 install networkx pydot pydotplus

RUN git clone \
    --depth 1 \
    https://github.com/aflgo/aflgo /afl

RUN cd /afl &&
    make clean all &&
    cd llvm_mode &&
    make clean all &&
    cd ../distance_calculator/ &&
    make -G Ninja ./ &&
    make --build ./

# Use afl_driver.cpp from LLVM as our fuzzing library.
RUN apt-get update && \
    apt-get install wget -y && \
    wget https://raw.githubusercontent.com/llvm/llvm-project/5feb80e748924606531ba28c97fe65145c65372e/compiler-rt/lib/fuzzer/afl/afl_driver.cpp -O /afl/afl_driver.cpp && \
    clang -Wno-pointer-sign -c /afl/llvm_mode/afl-llvm-rt.o.c -I/afl && \
    clang++ -stdlib=libc++ -std=c++11 -O2 -c /afl/afl_driver.cpp && \
    ar r /libAFL.a *.o