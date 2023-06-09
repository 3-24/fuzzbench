ARG parent_image
FROM $parent_image

RUN apt-get update && \
    apt-get install -y python3 python3-dev python3-pip &&
    apt-get install -y libboost-all-dev &&
    pip3 install --upgrade pip &&
    pip3 install networkx pydot pydotplus

RUN git clone https://github.com/aflgo/aflgo /aflgo

RUN cd /aflgo &&
    make clean all &&
    cd llvm_mode &&
    make clean all &&
    cd ../distance_calculator/ &&
    make -G Ninja ./ &&
    make --build ./
