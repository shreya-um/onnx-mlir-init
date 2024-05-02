# Read image from file

file unet_read_file.main.cpp_d1 contains sample code to read image from file

1. copy and paste lib files "stb_image.h" and "stb_image_write.h" in main_funcs folder
2. create a folder "inputs" in host and paste input image in path `/inputs/"$filename".png`, $filename is same as model name
3. uncomment line in `win_bin_abs_v2.sh`
```  #   docker cp ../inputs/"$filename".png  $container_id:/workdir/onnx-mlir/automation/main_files
    #   docker cp ../main_funcs/stb_image_write.h  $container_id:/workdir/onnx-mlir/automation/main_files
    #   docker cp ../main_funcs/stb_image.h  $container_id:/workdir/onnx-mlir/automation/main_files
```
4. `stbi_load` method is used to read the image
5. My doubts -   Im not sure if we need to convert the image from uint8_t to float or not.
    ```
    //check if Convert uint8_t to float is required or not... 
    for (int i = 0; i < tensor_size; ++i) {
        rgb_data_tensor[i] = static_cast<float>(rgb_image[i]); // Normalize to [0, 1]
        std::cout << rgb_data_tensor[i] << " \n";
    }
    ```
   