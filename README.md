## 手机termux部署openclaw
 
> 使用 proot-distro 安装 Ubuntu 运行 OpenClaw


## 只提供部署教程


---

## 下载安装zerotermux（termux可也可以）
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


### 一键安装脚本推荐
```
bash <(curl -fsSL -H 'Cache-Control: no-cache' "https://raw.githubusercontent.com/jfjdjdhsj/termux-clawbot-config/main/termux-openclaw.sh?t=$(date +%s)")
```

下面⬇️是手动安装

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

修复成功的版本2026.2.15，后续更新可能失效

### 一键修复命令：

```bash
cd /root && cat > fix_os.js << 'EOFPATCH'
const Module = require('module');
const originalLoad = Module._load;

Module._load = function (request, parent, isMain) {
    const module = originalLoad.apply(this, arguments);
    
    if (request === 'os') {
        const originalNI = module.networkInterfaces;
        module.networkInterfaces = function() {
            return {
                "lo": [{
                    "address": "127.0.0.1",
                    "netmask": "255.0.0.0",
                    "family": "IPv4",
                    "mac": "00:00:00:00:00:00",
                    "internal": true,
                    "cidr": "127.0.0.1/8"
                }]
            };
        };
    }
    
    return module;
};
EOFPATCH
```
```bash
echo 'alias openclaw="NODE_OPTIONS=\"--require /root/fix_os.js\" openclaw"' >> ~/.bashrc
```

```bash
source ~/.bashrc
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
## 十、启动webui，按电源下键，切换会话，新对话
```bash
openclaw  dashboard
```

访问http://127.0.0.1:18789/#token=，复制全部访问
