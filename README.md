# termux-clawbot-config
 
> 使用 proot-distro 安装 Ubuntu 运行 OpenClaw

---
## 下载安装termux
https://github.com/hanxinhao000/ZeroTermux/releases


## 一、安装 proot-distro

```bash
pkg update -y
pkg upgrade -y
pkg install -y proot-distro
```

---

## 二、安装 Ubuntu

```bash
proot-distro install ubuntu
```

---

## 三、登录 Ubuntu

```bash
proot-distro login ubuntu
```

> 后续操作均在 Ubuntu 环境中进行

---

## 四、切换清华源

```bash
tee /etc/apt/sources.list > /dev/null <<'EOF'
deb [signed-by=/usr/share/keyrings/ubuntu-archive-keyring.gpg] https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports questing main universe multiverse
deb [signed-by=/usr/share/keyrings/ubuntu-archive-keyring.gpg] https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports questing-updates main universe multiverse
deb [signed-by=/usr/share/keyrings/ubuntu-archive-keyring.gpg] https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports questing-security main universe multiverse
EOF
```

更新软件源：

```bash
apt update
apt upgrade -y
```

---

## 五、安装 Node.js（使用 nvm）

### 1️⃣ 安装基础依赖

```bash
apt install -y curl ca-certificates bash git
```

### 2️⃣ 安装 nvm

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
```

### 3️⃣ nvm 设置

```bash
echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"' >> ~/.bashrc
source ~/.bashrc
```

### 4️⃣ 安装 Node 22

```bash
nvm install 22
nvm use 22
nvm alias default 22
```

验证：

```bash
node -v
npm -v
```

---

## 六、安装 OpenClaw

```bash
npm install -g openclaw@latest
```

验证安装：

```bash
openclaw --version
```

---

## 七、修复 Termux 网络接口报错

在 proot 环境中，`os.networkInterfaces()` 可能返回异常，导致 OpenClaw 启动报错。

### 一键修复命令：

```bash
cd /root && \
echo '{"lo":[{"address":"127.0.0.1","netmask":"255.0.0.0","family":"IPv4","mac":"00:00:00:00:00:00","internal":true,"cidr":"127.0.0.1/8"}]}' > ni.json && \
find /root/.nvm/versions/node/*/lib/node_modules/openclaw/dist -type f -name "*.js" -exec sed -i 's/os\.networkInterfaces()/{\"lo\":[{\"address\":\"127.0.0.1\",\"netmask\":\"255.0.0.0\",\"family\":\"IPv4\",\"mac\":\"00:00:00:00:00:00\",\"internal\":true,\"cidr\":\"127.0.0.1\/8\"}]}/g' {} \; 2>/dev/null && \
find /usr/local/lib/node_modules/openclaw/dist -type f -name "*.js" -exec sed -i 's/os\.networkInterfaces()/{\"lo\":[{\"address\":\"127.0.0.1\",\"netmask\":\"255.0.0.0\",\"family\":\"IPv4\",\"mac\":\"00:00:00:00:00:00\",\"internal\":true,\"cidr\":\"127.0.0.1\/8\"}]}/g' {} \; 2>/dev/null && \
echo "✓ 修复完成！"
```

---

## 八、启动 OpenClaw 进行配置

```bash
openclaw onboard
```

---

## 九、启动服务

```bash
openclaw gateway
```

