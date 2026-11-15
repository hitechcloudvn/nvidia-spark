#!/usr/bin/env bash
# =============================================================================
# download-hf-models.sh — Tải bộ model Hugging Face cho AI HomeLab
#                         Download the Hugging Face model set for the AI HomeLab
#
# EN: Download the curated model catalog (GGUF for llama.cpp, safetensors for
#     vLLM, ComfyUI image/video models, ...) into the local HF cache, then
#     symlink it to /models/huggingface so every config sees the same path.
# VI: Tải danh mục model tuyển chọn (GGUF cho llama.cpp, safetensors cho vLLM,
#     model ảnh/video ComfyUI, ...) vào cache HF cục bộ, rồi symlink về
#     /models/huggingface để mọi cấu hình dùng cùng đường dẫn.
#
# Note / Lưu ý:
#   EN: Requires `hf` (huggingface-cli) — see install-hf.sh. Expect hundreds
#       of GB of disk. This list is the single source of truth for the model
#       catalog documented in README.md.
#   VI: Cần `hf` (huggingface-cli) — xem install-hf.sh. Cần hàng trăm GB ổ
#       đĩa. Danh sách này là nguồn duy nhất cho danh mục model trong README.md.
#
# Repo: https://github.com/hitechcloudvn/nvidia-spark
#       https://gitlab.com/hitechcloudvn/nvidia-spark
# =============================================================================
set -euo pipefail

# CODING MODELS / MODEL LẬP TRÌNH
## for llama.cpp GGUF / cho llama.cpp GGUF
hf download --max-workers="$(nproc)" noctrex/MiniMax-M2-REAP-139B-A10B-MXFP4_MOE-GGUF
hf download --max-workers="$(nproc)" noctrex/Qwen3-Next-80B-A3B-Instruct-1M-MXFP4_MOE-GGUF
hf download --max-workers="$(nproc)" noctrex/GLM-4.6V-MXFP4_MOE-GGUF
hf download --max-workers="$(nproc)" unsloth/Devstral-2-123B-Instruct-2512-GGUF --include "*Q4_K_XL*"
hf download --max-workers="$(nproc)" mradermacher/GLM-4.6-REAP-218B-A32B-Derestricted-i1-GGUF --include "*IQ2_M*"
hf download --max-workers="$(nproc)" bartowski/zai-org_GLM-4.7-GGUF --include "*IQ1_M*"
hf download --max-workers="$(nproc)" AaryanK/MiniMax-M2.1-GGUF --include="*q2_k*"

# just for fun, Russian Chat models / giải trí: model chat tiếng Nga
hf download --max-workers="$(nproc)" ai-sage/GigaChat3-10B-A1.8B-GGUF --include="%q8%"
hf download --max-workers="$(nproc)" t-tech/T-pro-it-2.1-GGUF --include="*Q4_K_M*"

## for vllm safetensors / cho vllm safetensors
hf download --max-workers="$(nproc)" Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8
hf download --max-workers="$(nproc)" unsloth/Qwen3-Next-80B-A3B-Instruct-bnb-4bit
hf download --max-workers="$(nproc)" ig1/Qwen3-Next-80B-A3B-Instruct-NVFP4
hf download --max-workers="$(nproc)" nvidia/NVIDIA-Nemotron-3-Nano-30B-A3B-FP8
hf download --max-workers="$(nproc)" EssentialAI/rnj-1-instruct
hf download --max-workers="$(nproc)" ArliAI/GLM-4.5-Air-Derestricted-GPTQ-Int4-Int8-Mixed

## single GGUF can be used with vLLM + llama.cpp / GGUF dùng chung cho cả hai
hf download --max-workers="$(nproc)" noctrex/Nemotron-3-Nano-30B-A3B-MXFP4_MOE-GGUF
hf download --max-workers="$(nproc)" juanml82/Huihui-Qwen3-Next-80B-A3B-Thinking-abliterated-gguf

## embedding models / model embedding
hf download --max-workers="$(nproc)" endyjasmi/Qwen3-Embedding-8B-Q4_K_M-GGUF

## image models ComfyUI / model ảnh ComfyUI
hf download --max-workers="$(nproc)" Comfy-Org/Qwen-Image-Edit_ComfyUI --include "*2511*" --include "*2509*"
hf download --max-workers="$(nproc)" unsloth/Qwen-Image-Edit-2511-GGUF --include="*Q4_K_M*"
hf download --max-workers="$(nproc)" Comfy-Org/Qwen-Image-Layered_ComfyUI
hf download --max-workers="$(nproc)" Comfy-Org/flux2-dev --exclude "*bf16*"
hf download --max-workers="$(nproc)" lightx2v/Qwen-Image-Edit-2511-Lightning

## video+image models ComfyUI + diffusers custom nodes / model video+ảnh cho ComfyUI + diffusers
hf download --max-workers="$(nproc)" kandinskylab/Kandinsky-5.0-I2V-Pro-distilled-5s-Diffusers
hf download --max-workers="$(nproc)" kandinskylab/Kandinsky-5.0-T2V-Pro-distilled-5s-Diffusers
hf download --max-workers="$(nproc)" kandinskylab/Kandinsky-5.0-I2I-Lite-sft-Diffusers
hf download --max-workers="$(nproc)" kandinskylab/Kandinsky-5.0-T2I-Lite-sft-Diffusers

# animation + video / hoạt hình + video
hf download --max-workers="$(nproc)" Wan-AI/Wan2.2-Animate-14B
hf download --max-workers="$(nproc)" lightx2v/Wan2.2-Lightning

# guard models to avoid inference attacks / model guard chống tấn công inference
hf download --max-workers="$(nproc)" geoffmunn/Qwen3Guard-Stream-8B --include="*Q4_K_M*"

# VLM / mô hình thị giác-ngôn ngữ
hf download --max-workers="$(nproc)" noctrex/Jan-v2-VL-max-MXFP4_MOE-GGUF
hf download --max-workers="$(nproc)" noctrex/Qwen3-VL-30B-A3B-Thinking-1M-MXFP4_MOE-GGUF

# Voice / giọng nói
hf download --max-workers="$(nproc)" onnx-community/chatterbox-multilingual-ONNX

# OCR / nhận dạng ký tự
hf download --max-workers="$(nproc)" deepseek-ai/DeepSeek-OCR

# small LLMs / LLM nhỏ
hf download --max-workers="$(nproc)" LiquidAI/LFM2-2.6B-Exp-GGUF --include="*Q8_0*"

# to have the same /models in all configs / để mọi cấu hình dùng chung /models
sudo mkdir -p /models
sudo ln -sfn "${HOME}/.cache/huggingface" /models/huggingface
sudo chown -R "$(id -un):$(id -gn)" /models
