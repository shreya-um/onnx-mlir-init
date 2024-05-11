#include <iostream>
#include <vector>
#include <cstdint>
// #include "cnpy.h"

#include "OnnxMlirRuntime.h"

// Declare the inference entry point.
extern "C" OMTensorList *run_main_graph(OMTensorList *);

static float rgb_data_tensor[3 * 224 * 224];

int main() {
  // Create an input tensor list of 1 tensor.
  int inputNum = 1;
  OMTensor *inputTensors[inputNum];
  // The first input is of tensor<1x1x28x28xf32>.
  int64_t rank = 4;
  int64_t shape[] = {3, 224, 224};
    float p[150528]; // Assuming you have an array of 5 doubles
    FILE* fp = fopen("alexnet.bin", "rb");
    if (fp == NULL) {
        // printf("Error: Unable to open file.\n");
        return 1;
    }

    // Read the array of doubles
    size_t num_elements_read = fread(rgb_data_tensor, sizeof(float), 150528, fp);
    fclose(fp);

    if (num_elements_read != 150528) {
        // printf("Error: Failed to read all elements from the file.\n");
        return 1;
    }

    // Dump the elements
// for (float val : rgb_data_tensor) {
//         std::cout << val << std::endl;
//     }
  

  //  cnpy::NpyArray arr = cnpy::npy_load("tensor_data.npy");

  //   // Check if the loaded data matches the expected shape
  //   if (arr.shape.size() != 3 || arr.shape[0] != 3 || arr.shape[1] != 256 || arr.shape[2] != 256) {
  //       std::cerr << "Error: Unexpected shape of loaded tensor data" << std::endl;
  //       return 1;
  //   }

  //   // Copy the loaded data into the rgb_data_tensor array
  //   std::copy(arr.data<float>(), arr.data<float>() + (3 * 256 * 256), rgb_data_tensor);


  // Create a tensor using omTensorCreateWithOwnership (returns a pointer to the OMTensor).
  // When the parameter, owning is set to "true", the OMTensor will free the data
  // pointer (img_data) upon destruction. If owning is set to false, the data pointer will
  // not be freed upon destruction.
  OMTensor *tensor = omTensorCreateWithOwnership(rgb_data_tensor, shape, rank, ONNX_TYPE_FLOAT, /*owning=*/true);

  // printf("line 58 \n");

 // Create a tensor list using omTensorListCreate (returns a pointer to the OMTensorList).
  inputTensors[0] = tensor;
  OMTensorList *tensorListIn = omTensorListCreate(inputTensors, inputNum);
  // printf("line 63 \n");

  // Compute outputs.
  OMTensorList *tensorListOut = run_main_graph(tensorListIn);

  // printf("line 68 \n");

  // Extract the output. The model defines one output of type tensor<1x10xf32>.
  OMTensor *y = omTensorListGetOmtByIndex(tensorListOut, 0);
  float *prediction = (float *)omTensorGetDataPtr(y);

  // // Analyze the output.
  // int digit = -1;
  // float prob = 0.;
  // for (int i = 0; i < 256*256; i++) {
  //   printf("prediction[%d] = %f\n", i, prediction[i]);
  // }
printf("[");
  for (int i = 0; i < 1000; ++i) {
    printf("%f,", prediction[i]);
  }
printf("]");

  // The OMTensorListDestroy will free all tensors in the OMTensorList
  // upon destruction. It is important to note, that every tensor will
  // be destroyed. To free the OMTensorList data structure but leave the
  // tensors as is, use OMTensorListDestroyShallow instead.
  // omTensorListDestroy(tensorListOut);
 //  omTensorListDestroy(tensorListIn);

  // printf("The digit is %d\n", digit);
  return 0;
}
