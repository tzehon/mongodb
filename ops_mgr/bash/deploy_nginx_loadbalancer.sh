#!/bin/bash

# Set the IP addresses
OM_1="YOUR OM IP"
OM_2="YOUR OM IP"
LB_IP="YOUR LB IP"

# Update package list and install Nginx
sudo apt update
sudo apt install -y nginx

# Create a backup of the original nginx.conf file
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup

# Create the new nginx.conf file with our configuration
sudo tee /etc/nginx/nginx.conf > /dev/null <<EOL
http {
    upstream backend {
        server ${OM_1};
        server ${OM_2};
    }

    server {
        listen 80;
        server_name ${LB_IP};

        location / {
            proxy_pass http://backend;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
    }
}

events {
    worker_connections 1024;
}
EOL

# Test the Nginx configuration
sudo nginx -t

# If the test is successful, reload Nginx to apply the new configuration
if [ $? -eq 0 ]; then
    sudo systemctl reload nginx
    echo "Nginx has been installed and configured successfully."
else
    echo "There was an error in the Nginx configuration. Please check and try again."
fi