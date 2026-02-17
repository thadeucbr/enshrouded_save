#!/bin/bash

echo "--- Iniciando Instalação do Servidor Enshrouded ---"

# 1. Atualizar o sistema e instalar o Docker (se não tiver)
if ! command -v docker &> /dev/null; then
    echo "Docker não encontrado. Instalando..."
    sudo apt update
    sudo apt install -y docker.io docker-compose-v2
    sudo usermod -aG docker $USER
    echo "Docker instalado! (Talvez precise relogar para funcionar sem sudo)"
else
    echo "Docker já está instalado."
fi

# 2. Criar a estrutura de pastas correta (O Segredo do sucesso)
echo "Organizando pastas..."
mkdir -p server/savegame
mkdir -p server/logs
mkdir -p server/backup

# 3. Ajustar permissões (Evita erro de acesso)
echo "Ajustando permissões..."
sudo chown -R 1000:1000 server
chmod -R 755 server

# 4. Mensagem final
echo "--- Tudo pronto! ---"
echo "Para ligar o servidor, rode: docker compose up -d"
echo "Para ver os logs, rode: docker logs -f enshrouded"
