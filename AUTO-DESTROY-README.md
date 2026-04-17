# Auto-Destroy Feature

## 🔥 Automatic Environment Cleanup

Este script monitorea automáticamente la actividad en el ambiente RHCE Killer y destruye la infraestructura de AWS después de 1 hora de inactividad para ahorrar costos.

## ✨ Características

- ✅ Monitoreo automático cada 5 minutos
- ✅ Detecta usuarios SSH activos
- ✅ Auto-destrucción después de 1 hora sin actividad
- ✅ Reinicia el contador cuando detecta actividad
- ✅ Muestra tiempo restante antes de destrucción
- ✅ Ejecución en segundo plano

## 🚀 Uso

### Iniciar el monitoreo

```bash
./auto-destroy.sh &
```

### Verificar que está corriendo

```bash
ps aux | grep auto-destroy | grep -v grep
```

### Ver el estado actual

```bash
cat /tmp/rhce-last-activity
```

### Detener el monitoreo

```bash
pkill -f auto-destroy.sh
```

## ⚙️ Configuración

Puedes modificar estos valores en el script:

- `INACTIVITY_TIMEOUT=3600` - Tiempo de inactividad en segundos (default: 1 hora)
- `CHECK_INTERVAL=300` - Intervalo de verificación en segundos (default: 5 minutos)

## 📊 Cómo funciona

1. El script verifica cada 5 minutos si hay usuarios conectados vía SSH
2. Si detecta usuarios activos, actualiza el timestamp de última actividad
3. Si NO hay actividad durante 1 hora completa, ejecuta `terraform destroy -auto-approve`
4. Limpia los archivos temporales y termina

## 💡 Consejos

- Ejecuta el script en segundo plano con `&` al final
- El script se ejecuta desde tu máquina local, no en el servidor
- Mientras estés conectado vía SSH, el contador se reinicia
- Si cierras todas las sesiones SSH, comienza la cuenta regresiva de 1 hora

## ⚠️ Importante

- El script debe ejecutarse desde el directorio raíz del proyecto (donde está el Makefile)
- Necesita acceso a la llave SSH `rhce-killer.pem`
- Requiere que Terraform esté configurado correctamente

## 🛑 Desactivar permanentemente

Si no quieres usar esta función, simplemente no ejecutes el script. El ambiente permanecerá activo hasta que lo destruyas manualmente con:

```bash
make down
# o
cd terraform && terraform destroy