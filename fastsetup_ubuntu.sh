#!/bin/bash
# This script is designed to setup a fast and efficient development environment on Ubuntu.
# It installs essential packages, configures system settings, and sets up a develepment environment.

# Variables
USER_HOME="$HOME"
LINUX_CONFIG="$USER_HOME/.config"
DOWNLOAD_DIR="$HOME/Downloads/fastsetup"

ZSH_HOME="$USER_HOME/.zsh"
ZSH_CONFIG="$ZSH_HOME/config"
ZSH_PLUGINS="$ZSH_HOME/plugins"
ZSH_PERSONAL_CONFIG_URL="https://github.com/mgrb/fastsetup_ubuntu/releases/download/0.0.1-a0/zsh_base_config.zip"

FONT_URLS=(
    "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/FiraCode.zip"
    "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.zip"
    "https://github.com/kencrocken/FiraCodeiScript/archive/refs/heads/master.zip"
    "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/Meslo.zip"
)

# print bunner
print_bunner() {
    echo '
============================================================== \033[1m\033[32m
      _________   ___________   _____ ______________  ______
     / ____/   | / ___/_  __/  / ___// ____/_  __/ / / / __ \
    / /_  / /| | \__ \ / /     \__ \/ __/   / / / / / / /_/ /
   / __/ / ___ |___/ // /     ___/ / /___  / / / /_/ / ____/
  /_/   /_/  |_/____//_/     /____/_____/ /_/  \____/_/ \033[0m
-------------------------------------------------------------- \033[34m
  Too for a fast setup for Ubuntu.
  By @mgrb \033[0m
--------------------------------------------------------------
'
}

# Check if the script is run as root
check_root_user() {
    if [ "$(id -u)" != 0 ]; then
        echo 'Please run the script as root!'
        echo 'We need to do administrative tasks'
        exit
    fi
}

# Function to create directories
create_directories() {
    mkdir -p $DOWNLOAD_DIR
    mkdir -p $ZSH_HOME
    mkdir -p $ZSH_CONFIG
    mkdir -p $ZSH_PLUGINS
    mkdir -p $LINUX_CONFIG
    mkdir -p $USER_HOME/Applications/JetBrains
}

# Function to check update and upgrade the system
check_update_upgrade() {
    echo 'Updating and upgrading the system...'
    apt update && apt upgrade -y
}

# install Docker
install_docker(){
    if ! command -v docker &> /dev/null; then
        echo "Instalando Docker Engine..."
        echo "uninstall all conflicting packages with Docker Engine"
        for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove -y $pkg; done

        # Add Docker's official GPG key:
        echo "Set up Docker's apt repository"
        sudo apt-get update
        sudo apt-get install -y ca-certificates curl
        sudo install -m 0755 -d /etc/apt/keyrings
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc

        # Add the repository to Apt sources:
        echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update

        echo "Install the Docker packages"
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

        echo "Linux post-installation for Docker Engine"
        sudo usermod -aG docker $USER
        newgrp docker
        echo "Docker instalado e configurado."
    else
        echo "Docker já está instalado."
    fi
}

# Install Gnome apps
install_gnome_apps(){
    # Instalar Flameshot
    if ! command -v flameshot &> /dev/null; then
        echo "Instalando flameshot..."
        sudo apt install -y flameshot
        echo "Flameshot instalado e configurado."
    else
        echo "Flameshot já está instalado."
    fi

    # Instalar Pomodoro
    if ! command -v gnome-pomodoro &> /dev/null; then
        echo "Instalando Pomodoro..."
        sudo apt install -y gnome-shell-pomodoro
        echo "Pomodoro instalado e configurado."
    else
        echo "Pomodoro já está instalado."
    fi

    # install Warp
    if ! command -v warp &> /dev/null; then
        echo "Instalando Warp..."
        wget -O $DOWNLOAD_DIR/warp.deb https://app.warp.dev/download?package=deb
        sudo dpkg -i $DOWNLOAD_DIR/warp.deb
        echo "Warp instalado e configurado."
    else
        echo "Warp já está instalado."
    fi

    # install Google Chrome
    if ! command -v google-chrome &> /dev/null; then
        echo "Instalando Google Chrome..."
        wget -O $DOWNLOAD_DIR/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        sudo dpkg -i $DOWNLOAD_DIR/google-chrome.deb
        echo "Google Chrome instalado e configurado."
    else
        echo "Google Chrome já está instalado."
    fi

    # Install Microsoft Edge
    if ! command -v microsoft-edge &> /dev/null; then
        echo "Instalando Microsoft Edge..."
        wget -O $DOWNLOAD_DIR/microsoft-edge.deb https://go.microsoft.com/fwlink?linkid=2149051&brand=M102
        sudo dpkg -i $DOWNLOAD_DIR/microsoft-edge.deb
        echo "Microsoft Edge instalado e configurado."
    else
        echo "Microsoft Edge já está instalado."
    fi

}

install_base_IDEs(){
    # Instalar Sublime Text
    if ! command -v subl &> /dev/null; then
        wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
        echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
        sudo apt-get update
        sudo apt-get install -y sublime-text
    else
        echo "Sublime Text já está instalado."
    fi

    # install VSCode
    if ! command -v code &> /dev/null; then
        echo "Instalando VSCode..."
        wget -O $DOWNLOAD_DIR/vscode.deb https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64
        sudo dpkg -i $DOWNLOAD_DIR/vscode.deb
        echo "VSCode instalado e configurado."
    else
        echo "VSCode já está instalado."
    fi

}

install_jetbrains_IDEs(){
    # Instalar DataGrip
    if [ ! -d "$HOME/Applications/JetBrains/DataGrip" ]; then
        echo "Instalando DataGrip..."
        wget -O $DOWNLOAD_DIR/datagrip.tar.gz https://download.jetbrains.com/datagrip/datagrip-2025.1.tar.gz
        tar -xzf $DOWNLOAD_DIR/datagrip.tar.gz -C $HOME/Applications/JetBrains/
        echo "DataGrip instalado e configurado."
    else
        echo "DataGrip já está instalado."
    fi

    # Instalar PyCharm
    if [ ! -d "$HOME/Applications/JetBrains/PyCharm" ]; then
        echo "Instalando PyCharm..."
        wget -O $DOWNLOAD_DIR/pycharm.tar.gz https://download.jetbrains.com/python/pycharm-2025.1.tar.gz
        tar -xzf $DOWNLOAD_DIR/pycharm.tar.gz -C $HOME/Applications/JetBrains/
        echo "PyCharm instalado e configurado."
    else
        echo "PyCharm já está instalado."
    fi

    # Instalar WebStorm
    if [ ! -d "$HOME/Applications/JetBrains/WebStorm" ]; then
        echo "Instalando WebStorm..."
        wget -O $DOWNLOAD_DIR/webstorm.tar.gz https://download.jetbrains.com/webstorm/WebStorm-2025.1.tar.gz
        tar -xzf $DOWNLOAD_DIR/webstorm.tar.gz -C $HOME/Applications/JetBrains/
        echo "WebStorm instalado e configurado."
    else
        echo "WebStorm já está instalado."
    fi

    # Instalar IntelliJ IDEA
    if [ ! -d "$HOME/Applications/JetBrains/IntelliJ IDEA" ]; then
        echo "Instalando IntelliJ IDEA..."
        wget -O $DOWNLOAD_DIR/idea.tar.gz https://download.jetbrains.com/idea/ideaIU-2025.1.tar.gz
        tar -xzf $DOWNLOAD_DIR/idea.tar.gz -C $HOME/Applications/JetBrains/
        echo "IntelliJ IDEA instalado e configurado."
    else
        echo "IntelliJ IDEA já está instalado."
    fi
}

# Function to install termonal apps
install_terminal_apps() {
    # install wget
    if ! command -v wget &> /dev/null; then
        echo "Instalando wget..."
        sudo apt install -y wget
        echo "wget instalado."
    else
        echo "wget já está instalado."
    fi
    # Instalar curl
    if ! command -v curl &> /dev/null; then
        echo "Instalando curl..."
        sudo apt install -y curl
        echo "curl instalado."
    else
        echo "curl já está instalado."
    fi

    # Instalar Git
    if ! command -v git &> /dev/null; then
        echo "Instalando Git..."
        sudo apt update && sudo apt install -y git
        echo "Git instalado."
    else
        echo "Git já está instalado."
    fi

    # Instalar ZSH e definir como shell padrão
    if ! command -v zsh &> /dev/null; then
        echo "Instalando ZSH..."
        sudo apt update && sudo apt install -y zsh
        chsh -s $(which zsh)
        echo "ZSH instalado e definido como padrão."
    else
        echo "ZSH já está instalado."
    fi

    # Instalar EZA
    if ! command -v eza &> /dev/null; then
        echo "Instalando EZA..."
        sudo apt install -y eza
        echo "EZA instalado."
    else
        echo "EZA já está instalado."
    fi

    # Instalar SDKMAN
    if [ ! -d "$USER_HOME/.sdkman" ]; then
        echo "Instalando SDKMAN..."
        curl -s "https://get.sdkman.io" | bash
        echo "SDKMAN instalado."
    else
        echo "SDKMAN já está instalado."
    fi

    # Instalar FNM
    if ! command -v fnm &> /dev/null; then
        echo "Instalando FNM..."
        curl -fsSL https://fnm.vercel.app/install | bash
        echo "FNM instalado."
    else
        echo "FNM já está instalado."
    fi

    # Instalar UV
    if ! command -v uv &> /dev/null; then
        echo "Instalando UV..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        echo "UV instalado."
    else
        echo "UV já está instalado."
    fi

    # Instalar Starship
    if ! command -v starship &> /dev/null; then
        echo "Instalando Starship..."
        curl -sS https://starship.rs/install.sh | sh
        # echo 'eval "$(starship init zsh)"' >> ~/.zshrc
        echo "Starship instalado e configurado."
    else
        echo "Starship já está instalado."
    fi

    # Instalar Nala
    if ! command -v nala &> /dev/null; then
        echo "Instalando Nala..."
        sudo apt install -y nala
        echo "Nala instalado e configurado."
    else
        echo "Nala já está instalado."
    fi

    # Instalar PIPX
    if ! command -v pipx &> /dev/null; then
        echo "Instalando PIPX..."
        sudo apt update
        sudo apt install -y pipx
        pipx ensurepath
        sudo pipx ensurepath --global # optional to allow pipx actions with --global argument
    else
        echo "PIPX já está instalado."
    fi

    # instalar Zoxide
    if ! command -v zoxide &> /dev/null; then
        echo "Instalando Zoxide..."
        curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
        echo "Zoxide instalado."
    else
        echo "Zoxide já está instalado."
    fi

    # instalar Bat
    if ! command -v bat &> /dev/null; then
        echo "Instalando Bat..."
        sudo apt install -y bat
        echo "Bat instalado."
    else
        echo "Bat já está instalado."
    fi

    # instalar LazyDocker
    if ! command -v lazydocker &> /dev/null; then
        echo "Instalando LazyDocker..."
        curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
        echo "LazyDocker instalado."
    else
        echo "LazyDocker já está instalado."
    fi
}

unzip_personal_zsh_base_config(){
    # Check if the directory already exists
    if [ ! -d "$ZSH_HOME" ]; then
        echo "Unzipping ZSH base config..."
        unzip $DOWNLOAD_DIR/zsh_base_config.zip -d $USER_HOME
    else
        echo "ZSH base config already unzipped."
    fi
}

install_zsh_plugins(){
    repos=(
        "https://github.com/z-shell/F-Sy-H.git $USER_HOME/.zsh/plugins/f-sy-h"
        "https://github.com/unixorn/fzf-zsh-plugin.git $USER_HOME/.zsh/plugins/fzf-zsh-plugin"
        "https://github.com/zsh-users/zsh-autosuggestions.git $USER_HOME/.zsh/plugins/zsh-autosuggestions"
    )

    for repo in "${repos[@]}"; do
    url=$(echo $repo | awk '{print $1}')
    dest=$(echo $repo | awk '{print $2}')

    if [ -d "$dest" ]; then
        echo "Atualizando $dest..."
        git -C "$dest" pull
    else
        echo "Clonando $url em $dest..."
        git clone "$url" "$dest"
    fi
    done
}

install_nerd_fonts(){
    FONTS_DIR="/usr/local/share/fonts"
    if [ ! -d "$FONTS_DIR" ]; then
        echo "Criando diretório de fontes em $FONTS_DIR..."
        sudo mkdir -p "$FONTS_DIR"
    else
        echo "Diretório de fontes já existe em $FONTS_DIR."
    fi

    for url in "${FONT_URLS[@]}"; do
        filename=$(basename "$url")
        temp_zip="/tmp/$filename"

        echo "Baixando $url..."
        curl -L "$url" -o "$temp_zip"

        if [[ "$filename" == *.zip ]]; then
            echo "Descompactando $filename em $FONTS_DIR..."
            sudo unzip -o "$temp_zip" -d "$FONTS_DIR"
            rm "$temp_zip"
        fi
    done

    # Atualizar cache de fontes
    fc-cache -f -v

}

# Função para solicitar inputs do usuário
prompt_user_inputs() {
    echo "Por favor, insira as informações solicitadas:"

    read -p "Digite o nome do usuário do Git (GIT_USER_NAME): " git_user_name
    if [[ -z "$git_user_name" ]]; then
        echo "Erro: O nome do usuário não pode ser vazio."
        exit 1
    fi

    read -p "Digite o e-mail do Git (GIT_USER_MAIL): " git_user_mail
    if [[ -z "$git_user_mail" ]]; then
        echo "Erro: O e-mail não pode ser vazio."
        exit 1
    fi

    read -p "Digite a chave de assinatura do Git (GIT_SIGNIN_KEY): " git_signin_key
    if [[ -z "$git_signin_key" ]]; then
        echo "Erro: A chave de assinatura não pode ser vazia."
        exit 1
    fi
}


install_personal_zsh_base_config() {

    local file="$ZSH_CONFIG/aliases.zsh"

    # Check if .zip exist in DOWNLOAD_DIR
    if [ ! -f "$DOWNLOAD_DIR/zsh_base_config.zip" ]; then
        echo "Downloading ZSH base config..."
        wget -O "$DOWNLOAD_DIR/zsh_base_config.zip" "$ZSH_PERSONAL_CONFIG_URL"
        echo "ZSH base config downloaded."
        unzip "$DOWNLOAD_DIR/zsh_base_config.zip" -d "$USER_HOME"
        echo "ZSH base config unzipped."

        # Verifica se o arquivo existe
        if [[ ! -f "$file" ]]; then
            echo "Erro: Arquivo $file não encontrado."
            exit 1
        if

        # Substitui as strings usando sed
        sed -i "s/GIT_USER_NAME/$git_user_name/g" "$file"
        sed -i "s/GIT_USER_MAIL/$git_user_mail/g" "$file"
        sed -i "s/GIT_SIGNIN_KEY/$git_signin_key/g" "$file"

        echo "Substituições realizadas com sucesso no arquivo $file."

        echo "Git configurado com nome: $git_user_name, email: $git_user_mail, GPG key: $git_signin_key"
    else
        echo "ZSH base config already downloaded."
    fi
}

main() {
    # Print the banner
    print_bunner

    # Check if the script is run as root
    check_root_user

    # Prompt user for inputs
    prompt_user_inputs

    # Create necessary directories
    create_directories

    # Check for updates and upgrade the system
    check_update_upgrade

    # Install terminal apps
    install_terminal_apps

    # Install Docker
    install_docker

    # Install Gnome apps
    install_gnome_apps

    # Install base IDEs
    install_base_IDEs

    # Install JetBrains IDEs
    install_jetbrains_IDEs

    # Download and unzip personal ZSH base config
    install_personal_zsh_base_config
}

(return 2> /dev/null) || main
