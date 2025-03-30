Fluent Bit Config 3.2.4

curl https://raw.githubusercontent.com/fluent/fluent-bit/master/install.sh | sh

# Enable Fluent Bit service to start on boot
sudo /bin/systemctl daemon-reload && sudo /bin/systemctl enable fluent-bit.service
sudo systemctl start fluent-bit
sudo systemctl status fluent-bit.service --no-pager
