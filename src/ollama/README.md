# ollama

```sh
sudo apt-get install -y nvidia-container-toolkit mlocate
curl -fsSL https://ollama.com/install.sh | sh
curl -L https://ollama.com/download/ollama-linux-amd64-rocm.tgz -o /tmp/ollama-linux-amd64-rocm.tgz # if you have amd GPU
sudo tar -C /usr -xzf /tmp/ollama-linux-amd64-rocm.tgz # if you have AMD GPU
sudo useradd -r -s /bin/false -U -m -d /usr/share/ollama ollama
sudo usermod -a -G ollama $(whoami)
sudo cp ollama.service /etc/systemd/system
nvidia-smi
journalctl -e -u ollama
ollama show --modelfile llama3.2
ollama create franklin-test -f Modelfile
journalctl -u ollama | grep -i "library=cuda"
```

## Multimodal Input

Use multimodal input by wrapping multiline text in triple quotes (""") and specifying image paths directly in the prompt.

## REST API Examples

Generate a Response, use the command:

```sh
# curl http://localhost:11434/api/generate -d '{"model": "<model_name>", "prompt": "<prompt>"}'`
curl http://localhost:11434/api/generate -d '{ "model": "llama2-uncensored", "prompt": "What is water made of?" }'
```

Chat with a Model: Use the command:

```sh
bash curl http://thelio.lab.bitsmasher.net:11434/api/chat -d '{"model": "llama2-uncensored", "messages": [{I"role": "user", "content": "<message>"}]}'`
```

## container

simple test

```sh
podman run -d --gpus=all -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama
```

open web ui:

```sh
podman qrun -d -p 3000:8080 --add-host=host.docker.internal:10.10.8.1 \
-v open-webui:/app/backend/data --name open-webui \
--restart always ghcr.io/open-webui/open-webui:main
```

## Raspi

```sh
curl -L https://ollama.com/download/ollama-linux-arm64.tgz -o ollama-linux-arm64.tgz
sudo tar -C /usr -xzf ollama-linux-arm64.tgz
```