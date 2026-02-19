#!/usr/bin/env bash
set -euo pipefail

echo "==> OpenClaw 一键安装开始"

USER_HOME="${HOME:-/root}"
BASHRC="${USER_HOME}/.bashrc"
NVM_DIR="${USER_HOME}/.nvm"
FIX_OS_JS="/root/fix_os.js"

# 1) 切换清华源
echo "==> 写入 APT 源到 /etc/apt/sources.list"
cat > /etc/apt/sources.list <<'EOF'
deb [signed-by=/usr/share/keyrings/ubuntu-archive-keyring.gpg] https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports questing main universe multiverse
deb [signed-by=/usr/share/keyrings/ubuntu-archive-keyring.gpg] https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports questing-updates main universe multiverse
deb [signed-by=/usr/share/keyrings/ubuntu-archive-keyring.gpg] https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports questing-security main universe multiverse
EOF

echo "==> apt update / upgrade"
export DEBIAN_FRONTEND=noninteractive
apt update
apt upgrade -y

# 2) 基础依赖（不检测，直接装）
echo "==> 安装基础依赖"
apt install -y curl ca-certificates bash git

# 3) 安装 nvm（不检测，直接执行）
echo "==> 安装 nvm v0.39.7"
curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# 4) 写入 nvm 配置（避免重复追加）
grep -qxF 'export NVM_DIR="$HOME/.nvm"' "${BASHRC}" 2>/dev/null || \
  echo 'export NVM_DIR="$HOME/.nvm"' >> "${BASHRC}"
grep -qxF '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"' "${BASHRC}" 2>/dev/null || \
  echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"' >> "${BASHRC}"

# 当前会话加载 nvm
export NVM_DIR="${NVM_DIR}"
# shellcheck disable=SC1090
[ -s "${NVM_DIR}/nvm.sh" ] && . "${NVM_DIR}/nvm.sh"

# 5) 仅检测 Node 是否为 22
echo "==> 检测 Node 主版本是否为 22"
NODE_MAJOR="$(node -v 2>/dev/null | sed -E 's/^v([0-9]+).*/\1/' || true)"

if [[ "${NODE_MAJOR}" == "22" ]]; then
  echo "  [OK] 当前 Node 已是 22，跳过安装"
else
  echo "  [INSTALL] 当前 Node 不是 22（当前: ${NODE_MAJOR:-未安装}），安装 Node 22"
  nvm install 22
fi

nvm use 22
nvm alias default 22

echo "Node 版本: $(node -v)"
echo "npm 版本 : $(npm -v)"

# 6) 安装 OpenClaw（不检测，直接装）
echo "==> 安装 OpenClaw 最新版"
npm install -g openclaw@latest
echo "OpenClaw 版本: $(openclaw --version || true)"

# 7) 写入网络修复 patch
echo "==> 写入 ${FIX_OS_JS}"
cat > "${FIX_OS_JS}" << 'EOFPATCH'
const Module = require('module');
const originalLoad = Module._load;

Module._load = function (request, parent, isMain) {
    const module = originalLoad.apply(this, arguments);

    if (request === 'os') {
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

# 8) 设置 alias（避免重复追加）
ALIAS_LINE='alias openclaw="NODE_OPTIONS=\"--require /root/fix_os.js\" openclaw"'
grep -qxF "${ALIAS_LINE}" "${BASHRC}" 2>/dev/null || echo "${ALIAS_LINE}" >> "${BASHRC}"

echo
echo "✅ 安装完成"
echo "请执行：source ${BASHRC}"
echo "然后验证：openclaw --version"
