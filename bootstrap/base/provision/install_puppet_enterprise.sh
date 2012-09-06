if [ -f /opt/puppet/bin/puppet ]; then
  echo "Puppet Enterprise already present, version $(/opt/puppet/bin/puppet --version)"
  echo "Skipping installation."
else
  <%= @installer_cmd %>
fi
