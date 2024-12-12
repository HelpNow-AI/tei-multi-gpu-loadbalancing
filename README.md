# Text Embeddings Inference 멀티 GPU 추론
멀티 GPU 환경 내 TEI(Text Embeddings Inference) 컨테이너를 각 GPU별 배포 후, nginx 로드밸런싱을 통해 멀티 GPU 추론 진행

### Diagram
![tei-lb](./tei-lb.png)

### Setting TEI and HF models
1. Download TEI Image and Save to `.tar`
```
# Turing architecture
docker pull ghcr.io/huggingface/text-embeddings-inference:turing-latest
docker save -o ./tei-images/text-embeddings-inference-turing.tar ghcr.io/huggingface/text-embeddings-inference:turing-latest

# Ampere 80 architecture
docker pull ghcr.io/huggingface/text-embeddings-inference:89-latest
docker save -o ./tei-images/text-embeddings-inference-ampere80.tar ghcr.io/huggingface/text-embeddings-inference:89-latest

# Ada Lovelave architecture
docker pull ghcr.io/huggingface/text-embeddings-inference:latest 
docker save -o ./tei-images/text-embeddings-inference-adalovelace.tar ghcr.io/huggingface/text-embeddings-inference:latest
```

2. Download HF Models
```
cd ./models

git clone https://huggingface.co/BAAI/bge-m3 # bge-m3
git clone https://huggingface.co/BAAI/bge-reranker-v2-m3 # bge-reranker-v2-m3
```

### run server
`sh run.sh [GPU]`
- Support GPUs: T4, L4, A100
