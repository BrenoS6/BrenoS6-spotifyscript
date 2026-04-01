# BS Spotify - FiveM

Player de música estilo Spotify para FiveM com:

- NUI moderna
- busca de músicas
- favoritos
- histórico
- painel admin
- integração com `oxmysql`

## Estrutura
```text
.
├─ fxmanifest.lua
├─ config.lua
├─ music.sql
├─ client/
│  └─ main.lua
├─ server/
│  └─ main.lua
└─ html/
   ├─ index.html
   ├─ style.css
   └─ app.js
```

## Requisitos
- FiveM
- `oxmysql`
- banco MySQL/MariaDB

## Instalação

### 1. Coloque o resource na pasta de resources
Recomendado usar o nome da pasta:
`bs_spotify`

### 2. Importe o SQL
Importe o arquivo `music.sql` no seu banco de dados.

### 3. Configure o admin
Edite o `config.lua` e coloque seu `license:` em:

```lua
Config.AdminIdentifiers = {
    'license:SEU_IDENTIFIER_AQUI'
}
```

### 4. Adicione no `server.cfg`
```cfg
ensure oxmysql
ensure bs_spotify
```

## Comandos
- `/music` → abre o player
- `/musicadmin` → abre o painel admin

## Como funciona
- o jogador abre o painel
- pesquisa por música
- toca direto pelo catálogo
- favorita músicas
- histórico é salvo no banco
- admin pode cadastrar novas músicas

## Banco de dados
O script usa estas tabelas:
- `music_tracks`
- `music_favorites`
- `music_history`

## Observação importante
Atualmente:
- o jogador **não precisa colar link**
- mas o admin ainda cadastra a música com `audio_url`

## Possíveis melhorias futuras
- upload de arquivos locais
- playlists reais
- remover/editar músicas
- notificações visuais
- suporte a som 3D
- integração com boombox/veículo

## Aviso
Este resource foi montado como base funcional e pode precisar de ajustes conforme:
- sua versão do FiveM
- restrições do host
- políticas de reprodução do áudio remoto
- configuração do `oxmysql`

Se encontrar erro, revise:
- console do servidor
- F8 do cliente
- SQL importado corretamente
- `license:` configurado

## Licença 
Uso livre para estudo e adaptação!
