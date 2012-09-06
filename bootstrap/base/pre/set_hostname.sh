hostname <%= @env[:vm].name %>
domainname soupkitchen.internal
echo <%= @env[:vm].name %> > /etc/hostname
