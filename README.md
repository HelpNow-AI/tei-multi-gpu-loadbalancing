# Text Embeddings Inference 멀티 GPU 추론
멀티 GPU 환경 내 TEI(Text Embeddings Inference) 컨테이너를 각 GPU별 배포 후, nginx 로드밸런싱을 통해 멀티 GPU 추론 진행

### Diagram
![tei-lb](./tei-lb.png)

### Setting TEI and HF models
1. Clone Repo
```
git clone -b feature/closed-network https://github.com/HelpNow-AI/tei-multi-gpu-loadbalancing.git
```

2. Downdload Nginx image and Save to. `.tar`
```
docker pull nginx:latest
docker save -o ./tei-images/nginx.tar nginx:latest
```

3. Download TEI Image based on your GPU architecture and Save to `.tar`
```
# Option 1: Turing architecture (T4, RTX 2000 series, …)
docker pull ghcr.io/huggingface/text-embeddings-inference:turing-latest
docker save -o ./tei-images/text-embeddings-inference-turing.tar ghcr.io/huggingface/text-embeddings-inference:turing-latest
```
```
# Option 2: Ampere 80 architecture (A100, A30)
docker pull ghcr.io/huggingface/text-embeddings-inference:89-latest
docker save -o ./tei-images/text-embeddings-inference-ampere80.tar ghcr.io/huggingface/text-embeddings-inference:89-latest
```
```
# Option 3: Ada Lovelave architecture (RTX 4000 series, …)
docker pull ghcr.io/huggingface/text-embeddings-inference:latest 
docker save -o ./tei-images/text-embeddings-inference-adalovelace.tar ghcr.io/huggingface/text-embeddings-inference:latest
```
```
# Option 4: Hopper architecture (H100)
docker pull ghcr.io/huggingface/text-embeddings-inference:hopper-latest
docker save -o ./tei-images/text-embeddings-inference-hopper.tar ghcr.io/huggingface/text-embeddings-inference:hopper-latest
```

4. Download HF Models (prerequisite: Git LFS install)
```
mkdir models
cd ./models

git clone https://huggingface.co/BAAI/bge-m3 # bge-m3
git clone https://huggingface.co/BAAI/bge-reranker-v2-m3 # bge-reranker-v2-m3
```

### run server
`bash run.sh [GPU]`
- Support GPUs: T4, L4, A100, H100
