# 🏰 Servidor Dedicado Enshrouded - TengaWorld (Survival Mode)

Este repositório contém o backup do save, as configurações e os scripts de automação para subir um servidor dedicado de **Enshrouded** via Docker.

**Status:** Jogo Zerado (Backup Final)
**Dificuldade:** Survival (Hardcore)
**Infraestrutura:** Linux (Ubuntu) + Docker + Playit.gg

---

## 🚀 Como Restaurar e Iniciar (Quick Start)

Se você está em uma máquina nova e quer subir o servidor do zero:

1.  **Clone o repositório:**
    ```bash
    git clone [https://github.com/SEU_USUARIO/backup-enshrouded-server.git](https://github.com/SEU_USUARIO/backup-enshrouded-server.git)
    cd backup-enshrouded-server
    ```

2.  **Execute o script de instalação:**
    (Ele instala o Docker, cria as pastas `savegame/logs/backup` e ajusta as permissões 1000:1000).
    ```bash
    chmod +x install.sh
    ./install.sh
    ```

3.  **Recrie o arquivo de configuração (Vital):**
    O arquivo de senhas não está no Git por segurança. Crie-o manualmente:
    ```bash
    nano server/enshrouded_server.json
    ```
    *Cole o conteúdo da seção "Configuração JSON" abaixo.*

4.  **Inicie o servidor:**
    ```bash
    docker compose up -d
    ```

---

## ⚙️ Configuração JSON (O Coração do Server)

**Arquivo:** `./server/enshrouded_server.json`
**Nota:** Se este arquivo não existir ou tiver erros de sintaxe (chaves faltando), o servidor vai carregar o padrão "Default" e ignorar suas preferências.

```json
{
  "name": "TengaWorld",
  "gameSettingsPreset": "Survival",
  "slotCount": 6,
  "ip": "0.0.0.0",
  "queryPort": 15637,
  "userGroups": [
    {
      "name": "Admin",
      "password": "SUA_SENHA_DE_ADMIN_AQUI",
      "roles": [
        "admin"
      ]
    },
    {
      "name": "Jogadores",
      "password": "SUA_SENHA_DE_JOGO_AQUI",
      "canKickBan": false,
      "canAccessInventories": true,
      "canEditBase": true,
      "canExtendBase": true
    }
  ]
}

```

### Explicação das Permissões

* **Survival:** Fome/sede ativados, inimigos mais fortes, penalidade de morte total (dropa tudo).
* **Jogadores (Group):**
* `canKickBan: false`: Jogadores não podem expulsar ninguém.
* `canEditBase: true`: Permite construir, destruir terreno e usar fábricas.
* `canExtendBase: true`: Permite colocar novos Altares de Chama.
* `canAccessInventories: true`: Permite abrir baús.



---

## 🛠️ Comandos Úteis (Manutenção)

### Ver Logs (Monitorar inicialização)

```bash
docker logs -f enshrouded

```

*Procure por: `[Session] 'HostOnline' (up)!*`

### Atualizar o Jogo

Se o botão "Atualizar" aparecer na Steam, o servidor está com versão antiga.

1. Derrube o container (para limpar portas presas):
```bash
docker compose down

```


2. Suba novamente (ele atualiza no boot):
```bash
docker compose up -d

```



### Verificar Uso de Recursos

```bash
htop

```

*Se a CPU estiver batendo 100% em um núcleo, veja a seção de Performance abaixo.*

---

## ⚡ Otimização para CPU Xeon (Performance Mode)

Este servidor roda em um **Xeon (E5-2670 v3)**. Como o clock base é baixo, é **obrigatório** forçar o modo de performance no Linux para evitar lags no jogo.

1. **Instalar ferramenta:**
```bash
sudo apt install cpufrequtils -y

```


2. **Configurar:**
Edite `/etc/default/cpufrequtils` e adicione:
```text
GOVERNOR="performance"

```


3. **Aplicar:**
```bash
sudo systemctl restart cpufrequtils

```



---

## 🌐 Acesso Externo (Playit.gg)

Este servidor usa o **Playit.gg** para criar o túnel sem abrir portas no roteador.

* Se o servidor não aparecer na lista da Steam, verifique se o agente do playit está rodando no Linux:
```bash
ps aux | grep playit

```


* Confira no painel (https://playit.gg) se o IP/Porta mudou.

---

## 📂 Estrutura de Pastas (Docker Volume)

O `docker-compose.yml` mapeia a pasta local `./game-data` para dentro do container em `/opt/enshrouded`.

* `./server/savegame/`: **AQUI FICA O SAVE (Ouro).**
* `./server/logs/`: Arquivos de texto com erros.
* `./server/backup/`: Backups automáticos zipados (lixo, ignorado no git).

```
