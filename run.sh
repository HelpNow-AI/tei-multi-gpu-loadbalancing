#!/bin/bash

# 공통 변수 설정
volume=$PWD/data
revision=main

# 실행 시 첫 번째 매개변수로 GPU 타입 입력 (기본값: T4)
gpu_type=${1:-T4}

# GPU 타입에 따른 이미지 선택
if [[ $gpu_type == "T4" ]]; then
  image=ghcr.io/huggingface/text-embeddings-inference:turing-1.3
elif [[ $gpu_type == "L4" ]]; then
  image=ghcr.io/huggingface/text-embeddings-inference:89-1.5
elif [[ $gpu_type == "A100" ]]; then
  image=ghcr.io/huggingface/text-embeddings-inference:1.5
else
  echo "Invalid GPU type. Please specify 'T4', 'L4', 'A100'."
  exit 1
fi

# Create docker network if not exists
docker network create tei-net || true

# Define execute function
run_docker() {
  local model=$1
  local port=$2
  local service_name=$3
  local config_file=$4  

  # 모델 컨테이너 실행
  for i in $(seq 0 1); do
    docker run --runtime=nvidia -d --gpus '"device='$i'"' \
      --network tei-net --name ${service_name}-$i \
      -v $volume:/data --pull always $image \
      --model-id $model --revision $revision --auto-truncate
  done

  # Nginx 컨테이너 실행 (서비스별로 다른 config 사용)
  docker run -d --network tei-net --name nginx-${service_name}-lb \
    -v $PWD/${config_file}:/etc/nginx/conf.d/default.conf:ro \
    -p $port:80 nginx:latest
}

# model run 
run_docker "bespin-global/klue-sroberta-base-continue-learning-by-mnr" 8000 "nlu-embedder-tei" "nginx-nlu.conf"
run_docker "BAAI/bge-m3" 8001 "bge-embedder-tei" "nginx-embedder.conf"
run_docker "BAAI/bge-reranker-v2-m3" 8002 "bge-reranker-tei" "nginx-reranker.conf"