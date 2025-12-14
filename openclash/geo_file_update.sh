#!/bin/sh

# ============================================
# immortalwrt OpenClash 配置更新脚本
# 功能：更新Geo规则数据和主配置文件，并自动重启服务
# ============================================

# 定义颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 定义URL和路径变量
GEOIP_URL="https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geoip-lite.dat"
GEOSITE_URL="https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geosite.dat"
OPENCLASH_CONFIG_URL="https://gh-proxy.org/https://raw.githubusercontent.com/JackieWuu/mihomo_config/refs/heads/main/openclash/openclash"

# 备用URL
GEOIP_ALT_URL="https://cdn.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geoip-lite.dat"
GEOSITE_ALT_URL="https://cdn.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geosite.dat"

OPENCLASH_DIR="/etc/openclash"
CONFIG_DIR="/etc/config"
TEMP_DIR="/tmp/openclash_update"
LOG_FILE="/tmp/openclash_update.log"

# 创建临时目录
mkdir -p "$TEMP_DIR"

# 函数：打印状态信息
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
    echo "[INFO] $1" >> "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    echo "[WARN] $1" >> "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    echo "[ERROR] $1" >> "$LOG_FILE"
}

log_progress() {
    echo -e "${BLUE}[PROGRESS]${NC} $1"
    echo "[PROGRESS] $1" >> "$LOG_FILE"
}

# 函数：检查命令执行结果
check_result() {
    if [ $? -eq 0 ]; then
        log_info "$1"
        return 0
    else
        log_error "$2"
        return 1
    fi
}

# 函数：简单进度显示下载函数
download_file_simple() {
    local url="$1"
    local output_file="$2"
    local alt_url="$3"
    local file_name="$4"
    local max_attempts=3
    local attempt=1
    local wget_exit=1
    
    while [ $attempt -le $max_attempts ]; do
        log_progress "下载尝试 $attempt/$max_attempts: $file_name"
        
        # 使用简单进度显示
        echo "正在下载 $file_name ..."
        
        # 直接运行wget，不通过管道处理输出
        wget -T 30 -c -O "$output_file" "$url"
        wget_exit=$?
        
        if [ $wget_exit -eq 0 ] && [ -s "$output_file" ]; then
            log_info "下载成功: $file_name"
            
            # 显示文件大小
            if command -v stat >/dev/null 2>&1; then
                file_size=$(stat -c%s "$output_file" 2>/dev/null)
            else
                file_size=$(wc -c < "$output_file" 2>/dev/null)
            fi
            
            # 转换为人类可读格式
            if [ "$file_size" -gt 1048576 ]; then
                # 使用awk进行浮点计算（更兼容）
                size_display=$(awk "BEGIN {printf \"%.2f\", $file_size/1048576}")MB
            elif [ "$file_size" -gt 1024 ]; then
                size_display=$(awk "BEGIN {printf \"%.2f\", $file_size/1024}")KB
            else
                size_display="${file_size}B"
            fi
            
            log_info "文件大小: $size_display ($file_size 字节)"
            return 0
        fi
        
        # 如果提供了备用URL，在第一次失败后尝试
        if [ $attempt -eq 1 ] && [ -n "$alt_url" ]; then
            log_warn "主URL失败，尝试备用URL..."
            url="$alt_url"
        else
            attempt=$((attempt + 1))
            
            # 如果不是最后一次尝试，等待后重试
            if [ $attempt -le $max_attempts ]; then
                log_warn "下载失败，5秒后重试..."
                sleep 5
            fi
        fi
    done
    
    log_error "所有下载尝试均失败: $file_name"
    return 1
}

# 函数：重启OpenClash服务
restart_openclash() {
    log_info "正在重启OpenClash服务..."
    
    # 检查服务是否存在
    if [ ! -f "/etc/init.d/openclash" ]; then
        log_error "OpenClash服务脚本不存在: /etc/init.d/openclash"
        return 1
    fi
    
    # 显示当前服务状态
    log_info "当前服务状态:"
    /etc/init.d/openclash status 2>/dev/null || echo "  无法获取状态"
    
    # 执行重启
    log_info "执行重启命令: /etc/init.d/openclash restart"
    echo "==========================================="
    
    # 执行重启
    if /etc/init.d/openclash restart; then
        log_info "OpenClash服务重启命令执行完成"
        
        # 等待2秒后检查服务状态
        sleep 2
        
        log_info "检查服务运行状态..."
        if /etc/init.d/openclash status 2>/dev/null | grep -q "running"; then
            log_info "✓ OpenClash服务正在运行"
            return 0
        else
            log_warn "⚠ OpenClash服务状态未知，请手动检查"
            return 1
        fi
    else
        log_error "OpenClash服务重启失败"
        return 1
    fi
}

# 函数：清理临时文件
cleanup_temp() {
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
        log_info "已清理临时目录: $TEMP_DIR"
    fi
}

# 主执行函数
main() {
    # 记录开始时间
    local start_time=$(date +%s)
    log_info "脚本开始执行: $(date '+%Y-%m-%d %H:%M:%S')"
    
    # 清理日志文件
    > "$LOG_FILE"
    
    # ============================================
    # 步骤1：删除现有的.dat文件
    # ============================================
    log_info "开始清理OpenClash数据文件..."
    
    if [ -d "$OPENCLASH_DIR" ]; then
        # 查找并显示将要删除的文件
        DAT_FILES=$(find "$OPENCLASH_DIR" -name "*.dat" 2>/dev/null)
        
        if [ -n "$DAT_FILES" ]; then
            log_info "找到以下.dat文件："
            echo "$DAT_FILES"
            
            # 执行删除操作
            rm -f "$OPENCLASH_DIR"/*.dat
            check_result "已删除所有.dat文件" "删除文件时出错"
        else
            log_info "未找到需要删除的.dat文件"
        fi
    else
        log_warn "目录 $OPENCLASH_DIR 不存在，将创建该目录"
        mkdir -p "$OPENCLASH_DIR"
    fi
    
    # ============================================
    # 步骤2：下载GeoIP.dat文件
    # ============================================
    log_info "开始下载GeoIP数据文件..."
    
    download_file_simple "$GEOIP_URL" "$TEMP_DIR/GeoIP.dat" "$GEOIP_ALT_URL" "GeoIP.dat"
    
    if [ $? -eq 0 ]; then
        # 移动文件到目标位置
        mv "$TEMP_DIR/GeoIP.dat" "$OPENCLASH_DIR/GeoIP.dat"
        check_result "GeoIP.dat下载完成并已保存到 $OPENCLASH_DIR" "移动GeoIP文件失败"
    else
        log_error "GeoIP.dat下载失败，跳过此文件"
        rm -f "$TEMP_DIR/GeoIP.dat"
    fi
    
    # ============================================
    # 步骤3：下载GeoSite.dat文件
    # ============================================
    log_info "开始下载GeoSite数据文件..."
    
    download_file_simple "$GEOSITE_URL" "$TEMP_DIR/GeoSite.dat" "$GEOSITE_ALT_URL" "GeoSite.dat"
    
    if [ $? -eq 0 ]; then
        # 移动文件到目标位置
        mv "$TEMP_DIR/GeoSite.dat" "$OPENCLASH_DIR/GeoSite.dat"
        check_result "GeoSite.dat下载完成并已保存到 $OPENCLASH_DIR" "移动GeoSite文件失败"
    else
        log_error "GeoSite.dat下载失败，跳过此文件"
        rm -f "$TEMP_DIR/GeoSite.dat"
    fi
    
    # ============================================
    # 步骤4：下载openclash配置文件
    # ============================================
    log_info "开始下载OpenClash配置文件..."
    
    # 确保配置目录存在
    mkdir -p "$CONFIG_DIR"
    
    download_file_simple "$OPENCLASH_CONFIG_URL" "$TEMP_DIR/openclash" "" "openclash配置文件"
    
    if [ $? -eq 0 ]; then
        # 备份现有配置文件（如果存在）
        if [ -f "$CONFIG_DIR/openclash" ]; then
            BACKUP_FILE="$CONFIG_DIR/openclash.backup.$(date +%Y%m%d_%H%M%S)"
            cp "$CONFIG_DIR/openclash" "$BACKUP_FILE"
            log_info "已备份原配置文件到: $BACKUP_FILE"
        fi
        
        # 移动新配置文件
        mv "$TEMP_DIR/openclash" "$CONFIG_DIR/openclash"
        
        # 设置正确的权限
        chmod 644 "$CONFIG_DIR/openclash"
        
        check_result "OpenClash配置文件已更新到 $CONFIG_DIR" "移动配置文件失败"
        
        # 标记需要重启服务
        local need_restart=1
    else
        log_error "OpenClash配置文件下载失败，保留原配置文件"
        rm -f "$TEMP_DIR/openclash"
        local need_restart=0
    fi
    
    # ============================================
    # 清理临时文件
    # ============================================
    cleanup_temp
    
    # ============================================
    # 验证下载的文件
    # ============================================
    log_info "验证下载的文件..."
    
    echo "==========================================="
    echo "文件验证结果："
    echo "-------------------------------------------"
    
    # 检查文件是否存在并显示详细信息
    check_file() {
        local file_path="$1"
        local file_name="$2"
        
        if [ -f "$file_path" ]; then
            # 使用兼容方式获取文件大小
            if command -v stat >/dev/null 2>&1; then
                file_size=$(stat -c%s "$file_path" 2>/dev/null)
            else
                file_size=$(wc -c < "$file_path" 2>/dev/null)
            fi
            
            # 转换为人类可读格式
            if [ "$file_size" -gt 1048576 ]; then
                size_display=$(awk "BEGIN {printf \"%.2f\", $file_size/1048576}")MB
            elif [ "$file_size" -gt 1024 ]; then
                size_display=$(awk "BEGIN {printf \"%.2f\", $file_size/1024}")KB
            else
                size_display="${file_size}B"
            fi
            
            # 检查文件是否为空
            if [ "$file_size" -eq 0 ]; then
                echo -e "${RED}✗ $file_name${NC} - 文件为空 (0字节)"
                return 1
            else
                echo -e "${GREEN}✓ $file_name${NC} - 大小: $size_display ($file_size 字节)"
                return 0
            fi
        else
            echo -e "${RED}✗ $file_name${NC} - 文件不存在"
            return 1
        fi
    }
    
    check_file "$OPENCLASH_DIR/GeoIP.dat" "GeoIP.dat"
    check_file "$OPENCLASH_DIR/GeoSite.dat" "GeoSite.dat"
    check_file "$CONFIG_DIR/openclash" "openclash配置文件"
    
    echo "==========================================="
    
    # 统计成功下载的文件数量
    success_count=0
    [ -f "$OPENCLASH_DIR/GeoIP.dat" ] && [ -s "$OPENCLASH_DIR/GeoIP.dat" ] && success_count=$((success_count + 1))
    [ -f "$OPENCLASH_DIR/GeoSite.dat" ] && [ -s "$OPENCLASH_DIR/GeoSite.dat" ] && success_count=$((success_count + 1))
    [ -f "$CONFIG_DIR/openclash" ] && [ -s "$CONFIG_DIR/openclash" ] && success_count=$((success_count + 1))
    
    # 计算执行时间
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    log_info "脚本执行完成，耗时: ${duration}秒"
    
    if [ $success_count -eq 3 ]; then
        log_info "所有文件下载成功！"
    elif [ $success_count -ge 1 ]; then
        log_warn "$success_count/3 个文件下载成功"
    else
        log_error "所有文件下载失败，请检查网络连接"
    fi
    
    # ============================================
    # 自动重启OpenClash服务
    # ============================================
    if [ $need_restart -eq 1 ] && [ -f "$CONFIG_DIR/openclash" ] && [ -s "$CONFIG_DIR/openclash" ]; then
        echo ""
        log_info "检测到配置文件已更新，将自动重启OpenClash服务..."
        
        # 自动重启
        restart_openclash
        
        if [ $? -eq 0 ]; then
            log_info "✅ OpenClash服务重启成功"
        else
            log_warn "⚠ OpenClash服务重启可能存在问题，请手动检查"
        fi
    else
        log_warn "配置文件未更新，跳过服务重启"
    fi
    
    # 显示日志文件位置
    echo ""
    log_info "详细日志已保存到: $LOG_FILE"
    log_info "可以使用以下命令查看日志: cat $LOG_FILE"
}

# 执行主函数
main
