#!/bin/bash
#set -e

echo "=========================================="
echo "🚀 Iniciando instalación del Bot (Binario)"
echo "=========================================="

apt update
apt install -y wget curl

# Crear directorios
mkdir -p /root/bot_files
mkdir -p /root/bot_files/storage
mkdir -p /root/storage
mkdir -p /root/bot_files/logs
mkdir -p /root/bot_files/screenshots
cd /root/bot_files

# ========== INSTALAR GOOGLE CHROME ==========
echo "📦 Instalando Google Chrome..."
wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

# Intentar instalar Chrome
if ! dpkg -i google-chrome-stable_current_amd64.deb 2>/dev/null; then
    echo "⚠️ Instalando dependencias faltantes de Chrome..."
    apt -f install -y
    if ! dpkg -i google-chrome-stable_current_amd64.deb; then
        echo "❌ Error: No se pudo instalar Chrome"
        exit 1
    fi
fi

# Verificar instalación
echo "✅ Google Chrome $(google-chrome --version) instalado"

# Instalar Xvfb individualmente para evitar que un error detenga todo
echo "Instalando Xvfb y librerías gráficas..."
apt install -y xvfb || echo "⚠️ Xvfb instalado con advertencias"

# ========== INSTALAR LIBRERÍAS GRÁFICAS ==========
apt install -y \
    libxss1 \
    libappindicator1 \
    libindicator7 \
    libgbm1 \
    libasound2 \
    fonts-liberation \
    libu2f-udev \
    libvulkan1 \
    xdg-utils \
    libxtst6 \
    libnss3 \
    libnspr4 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libxshmfence1 || echo "⚠️ Algunas librerías ya estaban instaladas"

# Configurar zona horaria
timedatectl set-timezone America/Bogota

# ========== CONFIGURAR DISPLAY VIRTUAL ==========
echo "Configurando Xvfb como servicio systemd..."

cat > /etc/systemd/system/xvfb.service << 'EOF'
[Unit]
Description=X Virtual Frame Buffer Service
After=network.target
Before=betting-bot.service

[Service]
ExecStart=/usr/bin/Xvfb :99 -screen 0 1280x1024x24 -ac +extension GLX +render -noreset
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# Habilitar e iniciar Xvfb
systemctl daemon-reload
systemctl enable xvfb.service
systemctl start xvfb.service

# Esperar a que Xvfb esté listo
sleep 2

# ========== CONFIGURAR LOGROTATE ==========
echo "⚙️ Configurando logrotate para el Bot..."

# Asegurar que la herramienta logrotate esté instalada
apt install -y logrotate

cat > /etc/logrotate.d/betting-bot << 'EOF'
/var/log/betting-bot.log
/var/log/betting-bot-error.log
{
    rotate 7
    daily
    maxsize 100M
    dateext
    compress
    delaycompress
    missingok
    notifempty
    create 0640 root root
    postrotate
        systemctl reload betting-bot.service > /dev/null 2>&1 || true
    endscript
}
EOF

# Ajustar permisos correctos para el archivo de configuración
chmod 644 /etc/logrotate.d/betting-bot

echo "=========================================="
echo "✅ Instalación base completada"
echo "=========================================="