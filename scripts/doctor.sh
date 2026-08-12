#!/bin/bash
# FluxMount · doctor.sh  (健康检查入口, 转调 install.sh --doctor)
# 作者: 张昌宇 (Changyu Zhang)
exec "$(dirname "$0")/install.sh" --doctor
