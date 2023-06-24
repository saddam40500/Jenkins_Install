#!/bin/bash

# Function to check and install wget if necessary
check_wget() {
    if ! command -v wget &> /dev/null; then
        echo "wget is not installed."
        echo "Installing wget..."
        if [ "$package_manager" = "yum" ]; then
            sudo yum update
            sudo yum install -y wget
        elif [ "$package_manager" = "apt-get" ]; then
            sudo apt-get update
            sudo apt-get install -y wget
        fi
    fi
}

# Function to check and set Java environment variables
setup_java_env() {
    if [ -z "$JAVA_HOME" ]; then
        echo "Java environment variables are not set."
        read -p "Enter the Java installation directory (e.g., /usr/java/jdk/): " java_install_dir
        # Set Java environment variables
        echo "Setting Java environment variables..."
        echo "export JAVA_HOME=$java_install_dir" >> ~/.bashrc
        echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> ~/.bashrc
	source ~/.bashrc
	source ~/.bashrc
	echo "JAVA_HOME: $JAVA_HOME"
	echo "PATH: $PATH"
        echo "Java environment variables set successfully."
    else
        echo "Java environment variables are already set."
	echo "JAVA_HOME: $JAVA_HOME"
        echo "PATH: $PATH"
        return
    fi
}

# Function to Check if Java is installed
check_java() {
    if ! rpm -qa | grep -i -E "java|jdk" &> /dev/null; then
	echo "Java is not installed."
        # Install Java
        echo "Installing Java..."
        if [ "$package_manager" = "yum" ]; then
            sudo yum install -y java-11-openjdk-devel
        elif [ "$package_manager" = "apt-get" ]; then
            sudo apt-get install -y java-11-openjdk-devel
        fi

        echo "Java Installed successfully..."
	# Validating/setting up the java path
	echo "setting the java path in environment variables"
	setup_java_env

    else
        echo "Java is already Installed."
	echo "Validating the java path in environemnt path"
	setup_java_env
    fi
}

# Function to install Jenkins
install_jenkins() {
    echo "Installing Jenkins..."

    # Check if Jenkins is already installed
    if command -v jenkins &> /dev/null; then
        echo "Jenkins is already installed."
        return
    else
        read -p "Enter the Jenkins repository link: " jenkins_repo
        read -p "Enter the Jenkins GPG key link: " jenkins_gpg_key

        # Add Jenkins repository
        sudo wget -O /etc/yum.repos.d/jenkins.repo $jenkins_repo
        sudo rpm --import $jenkins_gpg_key

        # Install Jenkins
        echo "Installing Jenkins..."
        if [ "$package_manager" = "yum" ]; then
            sudo yum update
            sudo yum install -y jenkins
        elif [ "$package_manager" = "apt-get" ]; then
            sudo apt-get update
            sudo apt-get install -y jenkins
        fi

        # Start Jenkins service
        sudo systemctl start jenkins

        # Enable Jenkins service on system boot
        sudo systemctl enable jenkins

        echo "Jenkins installed successfully."

        # Retrieve the default Jenkins password
        sleep 10 # Wait for Jenkins to initialize
        jenkins_password=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
        echo "Default Jenkins password: $jenkins_password"
    fi
}

# Determine package manager based on the operating system
if command -v yum &> /dev/null; then
    package_manager="yum"
elif command -v apt-get &> /dev/null; then
    package_manager="apt-get"
else
    echo "Unsupported operating system. This script supports yum and apt-get package managers."
    exit 1
fi

# Check and install wget if necessary
check_wget

# Main menu
while true; do
    echo "----------------------------------------"
    echo "           Jenkins Installation         "
    echo "----------------------------------------"
    echo "1. Install Jenkins"
    echo "2. Exit"
    echo "----------------------------------------"

    read -p "Enter your choice (1-2): " choice

    case $choice in
        1)
            check_java
            install_jenkins
            ;;
        2)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac
done

