# Agentarium — releases

Binarios de [Agentarium](https://github.com/Javiervinus/agentarium) (repo privado): un
terrario pixel-art para ver en tiempo real qué hacen tus agentes de IA locales (Claude
Code, Codex, OpenCode, OpenClaw). Este repo solo tiene el instalador y los releases.

## Instalar (macOS y Linux, una línea)

```sh
curl -fsSL https://raw.githubusercontent.com/Javiervinus/agentarium-releases/main/install.sh | sh
```

Descarga el binario de tu plataforma, verifica el checksum, lo instala en
`~/.local/bin/agentarium`, lo deja arrancando con tu sesión, instala los hooks de Claude
Code (estado al instante) y abre `http://127.0.0.1:4517`. Sin sudo, sin dependencias.

Windows: descarga `agentarium-windows-x64.exe` del último release y ejecútalo
(experimental).

## Después

| Quiero… | Comando |
|---|---|
| Actualizar | `agentarium update` (la web también avisa cuando hay versión nueva) |
| Ver mis gateways OpenClaw de otras máquinas | crea `~/.agentarium/openclaw-gateways.json` — ver abajo |
| Que no arranque solo | `agentarium uninstall-service` |
| Quitar los hooks | `agentarium uninstall-hooks` |
| Desinstalar todo | `agentarium uninstall-service; agentarium uninstall-hooks; rm ~/.local/bin/agentarium; rm -rf ~/.agentarium` |

Gateways OpenClaw remotos (Docker, otra máquina, tailnet) — el puerto del gateway debe
ser alcanzable y el token es el `gateway.auth.token` de su `openclaw.json`:

```json
{ "gateways": [ { "name": "softwerista", "url": "ws://192.168.1.20:18789", "token": "…" } ] }
```

## Qué toca en tu máquina

Solo lee los procesos y archivos de sesión de tus agentes. Escribe únicamente en
`~/.agentarium/` (config, hooks, logs), el servicio de arranque (`~/Library/LaunchAgents`
o `~/.config/systemd/user`) y, si instalas los hooks, entradas aditivas en
`~/.claude/settings.json` (con backup, reversibles).
