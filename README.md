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

Corre en segundo plano como servicio de tu sesión; abre `http://127.0.0.1:4517` cuando
quieras mirar (`?view=list` para la vista de lista).

| Quiero… | Comando |
|---|---|
| Saber cómo está | `agentarium status` |
| Apagarlo sin desinstalar / encenderlo / reiniciarlo | `agentarium stop` / `agentarium start` / `agentarium restart` |
| Actualizar | Solo: el daemon revisa cada hora, se actualiza y reinicia (la web muestra la versión y se recarga). Con prisa: `agentarium update`. Para decidir tú: `agentarium install-service --no-auto-update` |
| Ver mis gateways OpenClaw de otras máquinas | crea `~/.agentarium/openclaw-gateways.json` — ver abajo |
| Abrirlo desde el teléfono (tailnet propia) | `agentarium install-service --host tailscale` → `http://<ip-tailscale>:4517` |
| Que no arranque con la sesión | `agentarium uninstall-service` (vuelve con `install-service`) |
| Quitar los hooks | `agentarium uninstall-hooks` |
| Desinstalar | `agentarium uninstall` — quita servicio, hooks y binario; **nunca** borra `~/.agentarium/` (tu decoración y config sobreviven a una reinstalación). Borrarla es manual y opcional: `rm -rf ~/.agentarium` |

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
