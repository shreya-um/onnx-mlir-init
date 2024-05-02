import torch
import onnxruntime as ort

def main():
    model = torch.hub.load('mateuszbuda/brain-segmentation-pytorch', 'unet',
        in_channels=3, out_channels=1, init_features=32, pretrained=True)

    print(torch.__config__.show())
    print(model)
    model.eval()
    torch_input = torch.randn(1, 3, 256, 256)
    onnx_program = torch.onnx.export(model, torch_input, "unet.onnx")
    onnx_program.save("unet.onnx")

   

    ort_sess = ort.InferenceSession('unet.onnx')
    outputs = ort_sess.run(None, {'input.1': torch_input.numpy()})
    print(outputs)

main()
