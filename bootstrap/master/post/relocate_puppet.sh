# Update puppet.conf to add the manifestdir directive to point to the
# /manifests mount, if the directive isn't already present.
sed -i '
2 {
/manifest/ !i\
    manifestdir = /manifests
}
' /etc/puppetlabs/puppet/puppet.conf

# Update puppet.conf to add the modulepath directive to point to the
# /module mount, if it hasn't already been set.
sed -i '
/modulepath/ {
/vagrant/ !s,$,:/modules,
}
' /etc/puppetlabs/puppet/puppet.conf

# Rewrite the olde site.pp config since it's not used, and warn people
# about this.
echo '# /etc/puppetlabs/puppet/manifests is not used; see /manifests.' > /etc/puppetlabs/puppet/manifests/site.pp

# Enable autosigning on the master
echo '*' > /etc/puppetlabs/puppet/autosign.conf
