# Basic /etc/cloud/cloud.cfg
if [ -f /tmp/cloud.cfg ] && [ -d /etc/cloud ]; then
    /bin/cp -f /tmp/cloud.cfg /etc/cloud/cloud.cfg
    chown root:root /etc/cloud/cloud.cfg
    chmod 664 /etc/cloud/cloud.cfg
    rm -f /tmp/cloud.cfg
fi

# Logging
# if [ -f /tmp/05-logging.cfg ] && [ -d /etc/cloud/cloud.cfg.d ]; then
#     /bin/cp -f /tmp/05-logging.cfg /etc/cloud/cloud.cfg.d/05-logging.cfg
#     chown root:root /etc/cloud/cloud.cfg.d/05-logging.cfg
#     chmod 644 /etc/cloud/cloud.cfg.d/05-logging.cfg
#     rm -f /tmp/05-logging.cfg
# fi
#
# # Growpart will expand the root vol automagically
# if [ -f /tmp/10-growpart.cfg ] && [ -d /etc/cloud/cloud.cfg.d ]; then
#     /bin/cp -f /tmp/10-growpart.cfg /etc/cloud/cloud.cfg.d/10-growpart.cfg
#     chown root:root /etc/cloud/cloud.cfg.d/10-growpart.cfg
#     chmod 644 /etc/cloud/cloud.cfg.d/10-growpart.cfg
#     rm -f /tmp/10-growpart.cfg
# fi
