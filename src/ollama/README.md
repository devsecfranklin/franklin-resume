# ollama

```sh
sudo apt-get install -y nvidia-container-toolkit mlocate
curl -fsSL https://ollama.com/install.sh | sh
ollama show --modelfile llama3.2
ollama create franklin-test -f Modelfile
journalctl -u ollama | grep -i "library=cuda"
```

## Multimodal Input

Use multimodal input by wrapping multiline text in triple quotes (""") and specifying image paths directly in the prompt.

## REST API Examples

Generate a Response, use the command:

`curl http://localhost:11434/api/generate -d '{"model": "<model_name>", "prompt": "<prompt>"}'`

Chat with a Model: Use the command:

`bash curl http://localhost:11434/api/chat -d '{"model": "<model_name>", "messages": [{I"role": "user", "content": "<message>"}]}'`

## docker

```sh
docker run -d --gpus=all -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama
```
