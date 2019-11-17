#############################
#                           #
# Terraform variables file  #
# For DigitalOcean provider #
#                           #
#############################

# The commented variables are here associated to their default values

# The DigitalOcean region you'd like to deploy the cluster in
# Possible values : nyc1 sgp1 lon1 nyc3 ams3 fra1 tor1 sfo2 blr1 
# do_region = "ams3"

# The name of your Kubernetes cluster
# cluster_name = "homykub"

# The version of Kubernetes to install the cluster
# Possible values : 1.16.2-do.0 1.15.5-do.1 1.14.8-do.1
# cluster_version = "1.16.2-do.0"

# A list of optional tags to add to the cluster
# cluster_tags = []

# The size of the droplets in the default node pool in the cluster
# Possible values : s-1vcpu-2gb s-1vcpu-3gb s-2vcpu-2gb s-2vcpu-4gb s-4vcpu-8gb s-6vcpu-16gb
# cluster_default_node_size = "s-1vcpu-2gb"

# The number of nodes in the default node pool in the cluster
# cluster_default_node_count = 3

# Specific tags for the node pool in the cluster - the tags from the cluster are also applied automatically
# cluster_default_node_tags = []

# The path to save the kubeconfig to
# kubeconfig_path = "~/.kube/config"
