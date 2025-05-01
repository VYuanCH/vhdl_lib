# hls_convert.py
import hls4ml
from tensorflow.keras.models import load_model

model = load_model('mnist_model.h5')

# Generate HLS config from the Keras model
config = hls4ml.utils.config_from_keras_model(model, granularity='name')

# Optional: use fixed-point precision
config['Model']['Precision'] = 'ap_fixed<16,6>'
config = hls4ml.utils.config_from_keras_model(model, granularity='name')

config['Model']['Strategy'] = 'Resource'  # minimize hardware
#config['LayerName']['dense'] = {
#    'ReuseFactor': 784,  # Fully serialize the first layer
#}
config['LayerName']['dense'] = {'ReuseFactor': 784}   # Serialize first layer
config['LayerName']['dense_1'] = {'ReuseFactor': 1}

config['LayerName']['input_1'] = {
    'Interface': 'axi_stream',
    'Precision': 'ap_fixed<16,6>',
    'ReuseFactor': 1
}
config['LayerName']['dense_1'] = {
    'Interface': 'axi_stream',
}

# Convert to HLS C++ project
hls_model = hls4ml.converters.convert_from_keras_model(
    model,
    hls_config=config,
    output_dir='hls_project',
    part='xck26-sfvc784-2LV-c',   # update for your FPGA 
    backend='Vitis'           # ✅ tell it to use Vitis HLS
)

hls_model.compile()  # optional test compile
hls_model.build(csim=False, synth=True)  # run Vivado HLS synthesis
