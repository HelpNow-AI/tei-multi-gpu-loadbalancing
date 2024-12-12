# Text Embeddings Inference 멀티 GPU 추론
멀티 GPU 환경 내 TEI(Text Embeddings Inference) 컨테이너를 각 GPU별 배포 후, nginx 로드밸런싱을 통해 멀티 GPU 추론 진행

### Diagram
![tei-lb](./tei-lb.png)

### run server
`bash run.sh [GPU]`
- Support GPUs: T4, L4, A100
