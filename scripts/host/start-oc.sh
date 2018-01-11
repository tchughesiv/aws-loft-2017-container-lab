# STARTUP
metadata_endpoint="http://169.254.169.254/latest/meta-data"
public_hostname="$( curl -s "${metadata_endpoint}/public-hostname" )"
public_ip="$( curl -s "${metadata_endpoint}/public-ipv4" )"
oc cluster up --service-catalog=true --public-hostname="${public_hostname}" --routing-suffix="${public_ip}.nip.io"
