if [ $# -lt 1 ]; then
    echo "Usage: $0 <filename>"
    exit 1
fi

filename=$1
skipTill=$2

if [ ! -f "../onnx/$filename.onnx" ]; then
    echo "File '$filename' not found."
    exit 1
fi

set_onnx-mlir_env_vars() {
    cd onnx-mlir
    echo "exporting env varibales"
    export ONNX_MLIR_ROOT=$(pwd)
    export ONNX_MLIR_BIN=$ONNX_MLIR_ROOT/build/Debug/bin
    export ONNX_MLIR_INCLUDE=$ONNX_MLIR_ROOT/include
    export PATH=$ONNX_MLIR_ROOT/build/Debug/bin:$PATH
    export ONNX_MLIR_RUNTIME_DIR=./build/Debug/lib
    echo "done"
    echo "======================================================================================="

    # mkdir extra_lib
}

generate_onnx-mlir() {
    filename="$1"

    cd automation/onnx-mlir_files &&
    onnx-mlir -O3 --EmitLLVMIR ../onnx_files/$filename.onnx -o ../onnx-mlir_files/$filename  &&
    echo "generated $filename.onnx.mlir"
}

generate_llvm_IR() {
    filename="$1"

    cd /workdir/onnx-mlir/automation/llvm-IR_files/raw &&
    mlir-translate ../../onnx-mlir_files/$filename.onnx.mlir --mlir-to-llvmir -o $filename.ll &&
    echo "generated llvm IR for $filename"
    ls
}

run_opt_llvm_IR() {
    filename="$1"

    cd /workdir/onnx-mlir/automation/llvm-IR_files/O3 &&
    opt -O3 -S -o "$filename"_O3.ll ../raw/$filename.ll &&
    cd ../opt_lv
    opt -passes=loop-vectorize -S -o "$filename"_O3_lv.ll ../O3/"$filename"_O3.ll
    echo "ran opt passess -O3 and lv on llvm IR for $filename"
    ls
}

generate_asm() {
    filename="$1"

    cd /workdir/onnx-mlir/automation/obj_files/O3
    ls /workdir/onnx-mlir/automation/llvm-IR_files/O3

    llc -O3 --filetype=asm -o "$filename"_O3.s /workdir/onnx-mlir/automation/llvm-IR_files/O3/"$filename"_O3.ll &&
    cd ../O3_lv &&
    llc -O3 --filetype=asm -o "$filename"_O3_lv.s /workdir/onnx-mlir/automation/llvm-IR_files/opt_lv/"$filename"_O3_lv.ll &&
    echo "generated asm for $filename"
    ls
}

generate_bin() {
    filename="$1"
    echo "in gen bin"
    # ls /workdir/onnx-mlir/automation/main_files/

    cd /workdir/onnx-mlir/automation/bin &&
    onnx-mlir -O3 ../onnx-mlir_files/"$filename".onnx.mlir
    ls
    g++ --std=c++11 -O3 ../main_files/$filename.main.cpp ./$filename.onnx.so -o $filename.so.bin -I $ONNX_MLIR_INCLUDE
    clang++ --std=c++11 -static -O3 ../main_files/$filename.main.cpp ../obj_files/O3_lv/"$filename"_O3_lv.s ../../build/Debug/lib/libcruntime.a -o "$filename"_O3_lv -I $ONNX_MLIR_INCLUDE -I ../main_files/
    clang++ --std=c++11 -static -O3 ../main_files/$filename.main.cpp ../obj_files/O3/"$filename"_O3.s ../../build/Debug/lib/libcruntime.a -o "$filename"_O3 -I $ONNX_MLIR_INCLUDE -I ../main_files/
    echo "generated exec bin for $filename..."
    ls
}

gen_bin_conatiner() {
    filename="$1"
    skip_till="$2"
    set_onnx-mlir_env_vars

    skip_asm=true
    skip_bin=true

    if [ -z "$skip_till" ]; then
        skip_asm=false
        generate_onnx-mlir "$filename"
        generate_llvm_IR "$filename"
        run_opt_llvm_IR "$filename"
    fi

    if [[ "$skip_asm"  == false || "$skip_till" == "asm" ]]; then
        skip_bin=false
        generate_asm "$filename"
    fi

    if [[ "$skip_bin"  == false || "$skip_till" == "bin" ]]; then
        generate_bin "$filename"
    fi

    echo "======================================================================================="
}

run_bin() {
    filename="$1"

    echo "running bin $filename"
    cd ../bin
    ./"$filename"_O3 > $filename.output.txt
    ./"$filename".so.bin > $filename.so.bin.output.txt
    # ./"$filename"_O3_lv
    echo "======================================================================================="
    echo "completed"
}

copy_files_to_host() {
    filename="$1"
    first_container_id="$2"

    echo "copying files from conatiner to host"

    sudo docker cp $first_container_id:/workdir/onnx-mlir/automation/onnx-mlir_files/"$filename".onnx.mlir ../LLVM_Dialect/

    sudo docker cp $first_container_id:/workdir/onnx-mlir/automation/llvm-IR_files/raw/"$filename".ll ../LLVM_IR/raw
    sudo docker cp $first_container_id:/workdir/onnx-mlir/automation/llvm-IR_files/O3/"$filename"_O3.ll ../LLVM_IR/O3
    sudo docker cp $first_container_id:/workdir/onnx-mlir/automation/llvm-IR_files/opt_lv/"$filename"_O3_lv.ll ../LLVM_IR/opt_lv

    sudo docker cp $first_container_id:/workdir/onnx-mlir/automation/bin/"$filename"_O3 ../bin/
    sudo docker cp $first_container_id:/workdir/onnx-mlir/automation/bin/"$filename"_O3_lv ../bin/
    sudo docker cp $first_container_id:/workdir/onnx-mlir/automation/bin/"$filename".so.bin ../bin/
    echo "======================================================================================="

    # sudo docker cp $first_container_id:/workdir/onnx-mlir/automation/bin/"$filename"_output.png ../bin/
}

get_container_info() {
    existing_containers=$(sudo docker ps -a)
    first_container_id=$(echo "$existing_containers" | awk 'NR==2{print $1}')
    echo "First Container ID: $first_container_id"
}

copy_files_to_container() {
    filename="$1"
    container_id="$2"
    echo "======================================================================================="
    echo "Copying files to container..."
    sudo docker cp ../main_funcs/"$filename".main.cpp "$container_id":/workdir/onnx-mlir/automation/main_files
    sudo docker cp ../onnx/"$filename".onnx "$container_id":/workdir/onnx-mlir/automation/onnx_files
    echo "Files copied to container."
    echo "======================================================================================="
    # sudo docker cp ../inputs/"$filename".png  $container_id:/workdir/onnx-mlir/automation/main_files
    # sudo docker cp ../extra_lib/stb_image_write.h  $container_id:/workdir/onnx-mlir/automation/main_files
    # sudo docker cp ../extra_lib/stb_image.h  $container_id:/workdir/onnx-mlir/automation/main_files
}

start_container_get_bin() {
    container_id="$1"
    echo "Starting container with ID: $container_id"
    echo "======================================================================================="
    sudo docker start "$container_id"
    echo "======================================================================================="
    sudo docker exec -it $first_container_id /bin/bash -c "$(declare -f gen_bin_conatiner set_onnx-mlir_env_vars generate_onnx-mlir generate_llvm_IR run_opt_llvm_IR generate_asm generate_bin); gen_bin_conatiner '"$filename"' '"$skipTill"'" 
}

get_and_run_bin() {
    get_container_info
    copy_files_to_container $filename $first_container_id
    start_container_get_bin $first_container_id $skipTill
    copy_files_to_host $filename $first_container_id
    run_bin $filename
}

get_and_run_bin