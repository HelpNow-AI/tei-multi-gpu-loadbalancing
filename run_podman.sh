#!/bin/bash

# 공통 변수 설정
volume=$PWD/data
revision=main

# 실행 시 첫 번째 매개변수로 GPU 타입 입력 (기본값: T4)
gpu_type=${1:-T4}

# GPU 타입에 따른 이미지 선택
if [[ $gpu_type == "T4" ]]; then
  image_path=$PWD/tei-images/text-embeddings-inference-turing.tar
  image=ghcr.io/huggingface/text-embeddings-inference:turing-latest
elif [[ $gpu_type == "L4" ]]; then
  image_path=$PWD/tei-images/text-embeddings-inference-adalovelace.tar
  image=ghcr.io/huggingface/text-embeddings-inference:89-latest
elif [[ $gpu_type == "A100" ]]; then
  image_path=$PWD/tei-images/text-embeddings-inference-ampere80.tar
  image=ghcr.io/huggingface/text-embeddings-inference:latest
elif [[ $gpu_type == "H100" ]]; then
  image_path=$PWD/tei-images/text-embeddings-inference-hopper.tar
  image=ghcr.io/huggingface/text-embeddings-inference:hopper-latest
else
  echo "Invalid GPU type. Please specify 'T4', 'L4', 'A100', 'H100'"
  exit 1
fi

# Nginx
nginx_image_path=$PWD/tei-images/nginx.tar
nginx_image=nginx:latest

# Podman 네트워크 생성 (이미 존재하면 무시)
podman network create tei-net || true

# Define execute function
run_podman() {
  local model=$1
  local port=$2
  local service_name=$3
  local config_file=$4  

  # TEI image Load
  podman load < $image_path
  # Nginx image load
  podman load < $nginx_image_path

  # 모델 경로
  model=$PWD/models/$model

  # 모델 컨테이너 실행
  for i in $(seq 0 1); do
    podman run -dt --device nvidia.com/gpu=$i -e NVIDIA_VISIBLE_DEVICES=$i --security-opt=label=disable \
      --network tei-net --name ${service_name}-$i \
      -v $volume:$volume \
      -v $model:$model \
      $image --model-id $model --revision $revision --auto-truncate
  done

  # Nginx 컨테이너 실행 (서비스별로 다른 config 사용)
  podman run -dt --network tei-net --name nginx-${service_name}-lb \
    -v $PWD/${config_file}:/etc/nginx/conf.d/default.conf:ro \
    -p $port:80 \
    $nginx_image
}

# 모델 실행
run_podman "bge-m3" 8001 "bge-embedder-tei" "nginx-embedder.conf"
run_podman "bge-reranker-v2-m3" 8002 "bge-reranker-tei" "nginx-reranker.conf"