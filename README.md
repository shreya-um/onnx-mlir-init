# onnx-mlir-init-test

## Links to get input images and postprocessed image
1. [Unet](https://pytorch.org/hub/mateuszbuda_brain-segmentation-pytorch_unet/)
2. [Alexnet](https://pytorch.org/hub/pytorch_vision_alexnet/)
3. [resnet](https://pytorch.org/hub/pytorch_vision_resnet/)
4. [mobilenet-net](https://pytorch.org/hub/pytorch_vision_mobilenet_v2/)

## Steps to generate and run bin
1. follow instructions from [onnx-mlir-docker](https://github.com/onnx/onnx-mlir/blob/main/docs/Docker.md) to setup `onnx-mlir-docker`
2. create parent folder `automation` in path `containerId:/workdir/`
3. create folder with name `onnx-mlir_files`, llvm-IR_files/raw etc etc (check `get_bin_abs.sh` for list of all folders`
4. use torchhub links to get proper input for all models.
5. Update `<model>.main.cpp` -> static float img_data[] = {<input data as 1D array>} [line 16] and `shape[]` [line 24]
6. if required use [Netron](https://netron.app/) to get input and output dimensions. Update img_data and input img dimension
7. run `cd auto_scripts`
8. run `./get_bin_abs.sh <filename>` to copy files from local to docker and generate llvm IR, asm and then exec bin
9. to regenerate only bin run `./get_bin_abs.sh <filename> bin`
10. this cmd will generate `filename.output.txt` file containing model output as 1D array.

TO-DO
Use output array and get post processed image / data for all 4 models and comapre them.

## Ref for docker folder structure
![image](https://github.com/shreya-um/onnx-mlir-init-test/assets/155458601/22d8e1bc-73ec-4bf7-9ade-d6674ae6cffe)

run `./delete_all_files_con.sh` to delete all **generated** files from docker container
run `./delete_all_files_host.sh` to delete all **generated** files from local
