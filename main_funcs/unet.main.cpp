#include <iostream>
#include <vector>
#include <cstdint>

#include "OnnxMlirRuntime.h"

// Declare the inference entry point.
extern "C" OMTensorList *run_main_graph(OMTensorList *);

static float rgb_data_tensor[] = {...};

int main() {
  // Create an input tensor list of 1 tensor.
  int inputNum = 1;
  OMTensor *inputTensors[inputNum];
  // The first input is of tensor<1x1x28x28xf32>.
  int64_t rank = 4;
  int64_t shape[] = {3, 256, 256};

  // Create a tensor using omTensorCreateWithOwnership (returns a pointer to the OMTensor).
  // When the parameter, owning is set to "true", the OMTensor will free the data
  // pointer (img_data) upon destruction. If owning is set to false, the data pointer will
  // not be freed upon destruction.
  OMTensor *tensor = omTensorCreateWithOwnership(rgb_data_tensor, shape, rank, ONNX_TYPE_FLOAT, /*owning=*/true);

  // Create a tensor list using omTensorListCreate (returns a pointer to the OMTensorList).
  inputTensors[0] = tensor;
  OMTensorList *tensorListIn = omTensorListCreate(inputTensors, inputNum);

  // Compute outputs.
  OMTensorList *tensorListOut = run_main_graph(tensorListIn);

  // Extract the output. The model defines one output of type tensor<1x10xf32>.
  OMTensor *y = omTensorListGetOmtByIndex(tensorListOut, 0);
  float *prediction = (float *)omTensorGetDataPtr(y);

  // // Analyze the output.
  // int digit = -1;
  // float prob = 0.;
  // for (int i = 0; i < 256*256; i++) {
  //   printf("prediction[%d] = %f\n", i, prediction[i]);
  // }

  for (int i = 0; i < 256; ++i) {
        for (int j = 0; j < 256; ++j) {
            printf("%f\n", prediction[i * 256 + j]);
        }
  }
  // The OMTensorListDestroy will free all tensors in the OMTensorList
  // upon destruction. It is important to note, that every tensor will
  // be destroyed. To free the OMTensorList data structure but leave the
  // tensors as is, use OMTensorListDestroyShallow instead.
  // omTensorListDestroy(tensorListOut);
 //  omTensorListDestroy(tensorListIn);

  // printf("The digit is %d\n", digit);
  return 0;
}
