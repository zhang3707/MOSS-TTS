import os
import sys
import numpy as np
import soundfile as sf
import gradio as gr
import onnxruntime as ort
from transformers import AutoTokenizer

os.environ["TRANSFORMERS_OFFLINE"] = "1"

current_dir = os.path.dirname(os.path.abspath(__file__))
if current_dir not in sys.path:
    sys.path.insert(0, current_dir)

print("🚀 正在初始化 MOSS-TTS 纯离线 ONNX 高速推理引擎...")

MODEL_DIR = "/workspace/model_weights"

tokenizer = AutoTokenizer.from_pretrained(MODEL_DIR, local_files_only=True)

available_providers = ort.get_available_providers()
providers = ['CUDAExecutionProvider'] if 'CUDAExecutionProvider' in available_providers else ['CPUExecutionProvider']
print(f"核心驱动已锁定: {providers}")

onnx_path = os.path.join(MODEL_DIR, "model.onnx")
if os.path.exists(onnx_path):
    session = ort.InferenceSession(onnx_path, providers=providers)
    print("✅ ONNX 核心模型矩阵物理加载成功！")
else:
    session = None
    print("⚠️ 未在挂载目录找到 model.onnx，当前处于沙盒演示模式。")

def tts_predict(text, voice_preset):
    print(f"收到文本: {text}")
    
    if session is None:
        return sf.write("output.wav", np.zeros(24000), 24000) or "output.wav"
        
    inputs = tokenizer(text, return_tensors="np")
    input_ids = inputs["input_ids"].astype(np.int64)
    
    out_names = [o.name for o in session.get_outputs()]
    outputs = session.run(out_names, {"input_ids": input_ids})
    
    audio_data = outputs[0]
    output_path = "output.wav"
    sf.write(output_path, audio_data, 24000)
    return output_path

with gr.Blocks(title="MOSS-TTS 终极定制版") as demo:
    gr.Markdown("# 🎵 MOSS-TTS 纯离线 ONNX 推理服务")
    with gr.Row():
        with gr.Column():
            text_input = gr.Textbox(label="请输入文本", value="你好，这是完全走源码级 ONNX 推理生成的语音。")
            voice_select = gr.Dropdown(label="声音预设", choices=["preset_1"], value="preset_1")
            submit_btn = gr.Button("立即合成", variant="primary")
        with gr.Column():
            audio_output = gr.Audio(label="音频成品", type="filepath")

    submit_btn.click(fn=tts_predict, inputs=[text_input, voice_select], outputs=audio_output)

demo.launch(server_name="0.0.0.0", server_port=7860)
