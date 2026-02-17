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

## 🌐 Acesso Externo (A "Gambiarra" do Playit.gg)

Como não temos IP Fixo e não abrimos portas no roteador (CGNAT), utilizamos o **Playit.gg** para tunelar o tráfego UDP da internet direto para o Docker.

### 📜 Como Funciona (Arquitetura)
O agente do Playit roda no Linux (host) e cria uma ponte criptografada com os servidores globais do Playit.
* **Fluxo:** `Jogador (Internet)` -> `IP Público Playit` -> `Agente Playit (Seu PC)` -> `Docker (Porta 15636/15637)`

### 🛠️ Configuração dos Túneis (No Site Playit.gg)
Para o Enshrouded funcionar perfeito na lista da Steam, você precisa configurar **dois túneis UDP** no painel do Playit, apontando para as portas locais que definimos no `docker-compose.yml`.

| Tipo do Túnel | Local Address | Local Port | Para que serve? |
| :--- | :--- | :--- | :--- |
| **UDP** | `127.0.0.1` | **15636** | **Game Port:** É por onde os dados do jogo (movimento, combate) passam. |
| **UDP** | `127.0.0.1` | **15637** | **Query Port:** É o que a Steam usa para ver se o servidor está online e mostrar o ping. |

> **Nota:** O Playit vai te dar endereços externos diferentes para cada um (ex: `ip.playit.gg:10001` e `ip.playit.gg:25000`).

### 🎮 Como Conectar (O Pulo do Gato)

A Steam pode ser confusa. Siga esta ordem para adicionar aos Favoritos:

1.  Pegue o endereço gerado para a **Query Port** (a que aponta para 15637).
2.  Na Steam, vá em `Exibir` -> `Servidores de Jogos` -> Aba `Favoritos`.
3.  Clique em `+` e adicione esse endereço.
4.  **Se não aparecer:** Tente adicionar o endereço da **Game Port** (15636). Às vezes a Steam resolve sozinha.

### 🚨 Solução de Problemas do Playit
Se o IP mudar ou o servidor sumir:
1.  Verifique se o agente está rodando:
    ```bash
    ps aux | grep playit
    ```
2.  Confira no site (https://playit.gg/account/agents) se o agente está "Online".
3.  Se precisou reinstalar o Linux, instale o agente novamente:
    ```bash
    # Download e Instalação (Ubuntu/Debian)
    curl -SSL [https://playit-cloud.github.io/ppa/key.gpg](https://playit-cloud.github.io/ppa/key.gpg) | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/playit.gpg
    echo "deb [signed-by=/etc/apt/trusted.gpg.d/playit.gpg] [https://playit-cloud.github.io/ppa/data](https://playit-cloud.github.io/ppa/data) ./" | sudo tee /etc/apt/sources.list.d/playit-cloud.list
    sudo apt update
    sudo apt install playit
    ```
4.  Ao rodar pela primeira vez, ele vai gerar um link de "Claim" para vincular à sua conta antiga.

---

## 📂 Estrutura de Pastas (Docker Volume)

O `docker-compose.yml` mapeia a pasta local `./game-data` para dentro do container em `/opt/enshrouded`.

* `./server/savegame/`: **AQUI FICA O SAVE (Ouro).**
* `./server/logs/`: Arquivos de texto com erros.
* `./server/backup/`: Backups automáticos zipados (lixo, ignorado no git).

```
