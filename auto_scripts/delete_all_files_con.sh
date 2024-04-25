check_existing_containers() {
    # Check existing containers
    existing_containers=$(sudo docker ps -a)
    # existing_containers=$(sudo docker ps -a)
    first_container_id=$(echo "$existing_containers" | awk 'NR==2{print $1}')
    echo "======================================================================================="
    echo "deleting files..."
    echo "======================================================================================="
    echo "starting container with ID: $first_container_id"
    echo "======================================================================================="
    echo "running container..." 
    sudo docker start $first_container_id
    echo "======================================================================================="
    sudo docker exec -it $first_container_id /bin/bash -c '

    cd onnx-mlir/automation/onnx-mlir_files
        pwd
        ls
        rm -r ./*
        ls
        cd ../llvm-IR_files/raw
        pwd
        ls
        rm -r ./*
        ls
        cd ../O3
        pwd
        ls
        rm -r ./*
        ls
        cd ../opt_lv
        pwd
        ls
        rm -r ./*
        ls
        cd ../../obj_files/O3
        pwd
        ls
        rm -r ./*
        ls
        cd ../O3_lv
        pwd
        ls
        rm -r ./*
        ls
        cd ../../bin
        pwd
        ls
        rm -r ./*
        ls
        cd ../main_files
        ls
        pwd
        ls
        rm -r ./*
        ls
        cd ../inputs
        ls
        pwd
        ls
        rm -r ./*
        ls


        
        cd onnx-mlir/automation/onnx-mlir_files
        pwd
        ls
        
        cd ../llvm-IR_files/raw
        pwd
        ls
        
        cd ../O3
        pwd
        ls
        
        cd ../opt_lv
        pwd
        ls
        
        cd ../../obj_files/O3
        pwd
        ls
        
        cd ../O3_lv
        pwd
        ls
        
        cd ../../bin
        pwd
        ls
    '
}

check_existing_containers