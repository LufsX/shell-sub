#!/bin/sh
initValue() {
    ################
    # 不能修改的配置
    ################
    # list.txt
    list='./list.txt'
    [ ! -f $list ] && echo "\033[31m Please create list.txt \033[0m" && exit 0
    # 行数
    const=$(awk '{print NR}' $list | tail -n1)
    #################
    # 以下是可修改的配置
    #################
    # 自动生成配置文件选项
    configGenerate="true"                                                                                      # 配置文件自动生成 'ture' -> 开; 'flase' -> 关
    templateFileURL="https://gist.githubusercontent.com/LufsX/a522b340a8e62e008c049c39a82951a0/raw/clash.yaml" # 默认示例配置文件地址, 仅支持直链
    link="https://lufsx.github.io/shell-sub/"                                                                  # HTTP 订阅地址, 若文件部署在网络上
    templateFilePath="./Template.yaml"                                                                         # 模板文件地址, 一般不用动
    ## 需要被替换的 URL
    ## 一般不需要改( 前提是用我的配置文件 🤣
    replaceKey="https://url"            # 修改范围是整个文件, 需要唯一字符
    replaceSEKey="https://se.url"       # 港澳台, 修改范围是整个文件, 需要唯一字符
    replaceTGKey="https://telegram.url" # Telegram, 修改范围是整个文件, 需要唯一字符
    ## 各 ProxyList 路径
    ## 一般不需要改( 前提是用我的配置文件 🤣
    replacePath="List.yaml"            # 修改范围是整个文件, 需要唯一字符
    replaceSEPath="List-SE.yaml"       # 修改范围是整个文件, 需要唯一字符
    replaceTGPath="List-Telegram.yaml" # 修改范围是整个文件, 需要唯一字符
}

makeDir() {
    # 清理文件
    echo "Clean up file"
    rm -rf ./public/Proxy
    rm -rf ./public/ProxyList
    rm $templateFilePath >/dev/null 2>&1
    # 创建文件夹
    echo "Create folder"
    mkdir ./public >/dev/null 2>&1
    mkdir ./public/Proxy
    mkdir ./public/ProxyList
    mkdir ./public/ProxyList/SE
    mkdir ./public/ProxyList/Telegram
    mkdir ./public/links >/dev/null 2>&1
    echo "------------------------------"
}

clearFile() {
    rm $templateFilePath
    rm -rf ./public/Proxy
}

getYaml() {
    for n in $(seq ${const}); do
        # 获取 list.txt 中的 URL -> $profileURL
        profileURL=$(sed -n "${n}p" "$list" | cut -f 1 -d " ")
        # 生成新的文件路径 -> $filePath
        filePath=./public/Proxy/$(sed -n "${n}p" "$list" | cut -f 2 -d " ").yaml
        echo 'Getting the' $n 'file'
        # 以指定 user agent 配置文件
        wget --user-agent="clash" $profileURL -O $filePath >/dev/null 2>&1
    done
}

getFileNum() {
    for n in $(seq ${const}); do
        echo "\033[33mStart Get $n file num\033[0m"
        # 获取文件配置文件路径
        primaryPath=./public/Proxy/$(sed -n "${n}p" "$list" | cut -f 2 -d " ").yaml
        # 检测 'proxies:' 所在行数
        startNum=$(awk '/proxies:/{print NR}' $primaryPath | sed -n 1p)
        # 检测 'proxy-groups:' 所在行数
        endNum=$(expr $(awk '/proxy-groups:/{print NR}' $primaryPath | sed -n 1p) - 1)
        numStatus="persist"
        [ "$endNum" = "" ] && numStatus="delete"
        [ "$startNum" = "" ] && numStatus="delete"
        # 如果 $startNum 大于 $endNum 那就没法玩了
        [ "$startNum" -gt "$endNum" ] && numStatus="delete" && echo "\033[31m File num error \033[0m"
        echo 'Start num is' $startNum ', end num is' $endNum ', filepath is' $primaryPath
        echo 'Status:' $numStatus
        echo "\033[32m Get file num success \033[0m"
        # 传递参数到下一个 Function
        initNodeList $startNum $endNum $primaryPath $n $numStatus
    done
}

initNodeList() {
    if [ "$5" = "delete" ]; then
        echo "\033[31m Num error \033[0m"
    else
        # $1 -> $startNum, $2 -> $endNum, $3 -> $primaryPath, $4 -> $n
        nodeList=./public/ProxyList/$(sed -n "$4"p "$list" | cut -f 2 -d " ")\.yaml
        sed -n "$1","$2"p "$3" >$nodeList
    fi
    echo "\033[33mDone\033[0m"
    echo "------------------------------"
}

seGourpGrep() {
    for n in $(seq ${const}); do
        echo "\033[33m Start grep se gourp\033[0m"
        profileName=$(sed -n "${n}"p "$list" | cut -f 2 -d " ")
        # 变量绑定文件相对路径
        nodeList=./public/ProxyList/$profileName\.yaml
        outputSE=./public/ProxyList/SE/$profileName\.yaml
        echo proxies\: >$outputSE
        # 过滤带关键字的节点
        grep -E '(HK|TW|Hongkong|Taiwan|HongKong|TaiWan|港|台)' $nodeList >>$outputSE
        outputCheck=$(awk '{print NR}' $outputSE | tail -n1)
        echo " The profile has" "$(expr $outputCheck - 1)" "TW/HK proxie(s)"
        [ "$outputCheck" = "1" ] && echo '\033[31m File:' $nodeList 'has no proxie with TW/HK \033[0m'
        [ "$outputCheck" != "1" ] && echo "\033[32m Grep TW/HK proxies success \033[0m"
        echo "------------------------------"
    done
}

telegramGourpGrep() {
    for n in $(seq ${const}); do
        echo "\033[33m Start grep se gourp\033[0m"
        profileName=$(sed -n "${n}"p "$list" | cut -f 2 -d " ")
        # 变量绑定文件相对路径
        nodeList=./public/ProxyList/$profileName\.yaml
        outputTelegram=./public/ProxyList/Telegram/$profileName\.yaml
        echo proxies\: >$outputTelegram
        # 过滤带关键字的节点
        grep -E '(SG|US|NL|Singapore|United|Netherland|新加坡|荷兰|美国)' $nodeList >>$outputTelegram
        outputCheck=$(awk '{print NR}' $outputTelegram | tail -n1)
        echo " The profile has" "$(expr $outputCheck - 1)" "TW/HK proxie(s)"
        [ "$outputCheck" = "1" ] && echo '\033[31m File:' $nodeList 'has no proxie with SG/US/NL \033[0m'
        [ "$outputCheck" != "1" ] && echo "\033[32m Grep SG/US/NL proxies success \033[0m"
        echo "------------------------------"
    done
}

getTemplate() {
    echo " Start get template configuration"
    wget -q -O - $templateFileURL | grep -o '^[^#]*' | sed '/^[ ]*$/d' | sed 's/ *$//' >$templateFilePath
    if [ -s $templateFilePath ]; then
        echo "\033[32m Success \033[0m"
        echo "------------------------------"
    else
        echo "\033[31m Failure \033[0m"
        echo "\033[31m Please check link address \033[0m"
        templateStatus="failure"
        echo "------------------------------"
    fi

}

generateConfig() {
    if [ "$templateStatus" != "failure" ]; then
        for n in $(seq ${const}); do
            echo ' Generate' $n 'configuration'
            # 导入参数
            profileName=$(sed -n "${n}"p "$list" | cut -f 2 -d " ")
            proxiesLink=$link\ProxyList/$profileName\.yaml
            proxiesSELink=$link\ProxyList/SE/$profileName\.yaml
            proxiesTGLink=$link\ProxyList/Telegram/$profileName\.yaml
            # 路径
            configPath="./public/links/$profileName.yaml"
            proxiesName="$profileName.yaml"
            proxiesName="$profileName.yaml"
            cat $templateFilePath | sed "s|${replaceKey}|${proxiesLink}|g" | sed "s|${replaceSEKey}|${proxiesSELink}|g" | sed "s|${replaceTGKey}|${proxiesTGLink}|g" | sed "s|${replacePath}|${proxiesName}|g" | sed "s|${replaceSEPath}|${proxiesName}|g" | sed "s|${replaceTGPath}|${proxiesName}|g" >$configPath
            echo "\033[32m Success \033[0m"
            echo "------------------------------"
        done
    else
        echo " Cancel generate configuration"
    fi
}

initValue
makeDir
getYaml
getFileNum
seGourpGrep
telegramGourpGrep
if [ "$configGenerate" = "true" ]; then
    getTemplate
    generateConfig
elif [ "$configGenerate" = "false" ]; then
    echo 'Config generate option is false'
    echo "Cancel generate configuration"
    echo "------------------------------"
else
    echo "\033[31m Unkown option \033[0m"
    echo "Cancel generate configuration"
    echo "------------------------------"
fi
# clearFile # 清除多余文件
