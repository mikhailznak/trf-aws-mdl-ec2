variable "tags" {
  description = "Tags"
  type        = map(string)
  default     = {}
}

##################################
# EC2
##################################
variable "ec2_name" {
  description = "Instance Name"
  type        = string
  default     = ""
}
variable "ami" {
  description = "AMI"
  type        = string
  default     = ""
}
variable "instance_type" {
  description = "Instance Type"
  type        = string
  default     = ""
}
variable "availability_zone" {
  description = "Availability Zone"
  type        = string
  default     = null
}
variable "associate_public_ip_address" {
  description = "Enable Public IP address on instance in VPC"
  type        = bool
  default     = null
}
variable "subnet_id" {
  description = "Subnet ID"
  type        = string
  default     = null
}
variable "private_ip" {
  description = "Assosiate Private IP address on instance in VPC"
  type        = string
  default     = null
}
variable "secondary_private_ips" {
  description = "A list of secondary private IPv4 addresses to assign to the instance's primary network interface (eth0) in a VPC. Can only be assigned to the primary network interface (eth0) attached at instance creation, not a pre-existing network interface i.e. referenced in a network_interface block"
  type        = list(string)
  default     = null
}
variable "vpc_security_group_ids" {
  description = "A list of security group IDs to associate with"
  type        = list(string)
  default     = null
}
#variable "cpu_core_count" {
#  description = "Sets the number of CPU cores for an instance. This option is only supported on creation of instance type that support CPU Options"
#  type        = number
#  default     = null
#}
#variable "cpu_threads_per_core" {
#  description = "(has no effect unless cpu_core_count is also set) If set to to 1, hyperthreading is disabled on the launched instance. Defaults to 2 if not set"
#  type        = number
#  default     = null
#}
variable "disable_api_stop" {
  description = "If true, enables EC2 Instance Stop Protection"
  type        = bool
  default     = null
}
variable "disable_api_termination" {
  description = "If true, enables EC2 Instance Termination Protection"
  type        = bool
  default     = null
}
#variable "hibernation" {
#  description = "If true, the launched EC2 instance will support hibernation"
#  type        = bool
#  default     = null
#}
#variable "instance_initiated_shutdown_behavior" {
#  description = "Shutdown behavior for the instance. Amazon defaults this to stop for EBS-backed instances and terminate for instance-store instances. Cannot be set on instance-store instances"
#  type        = string
#  default     = null
#}
#variable "tenancy" {
#  description = "Tenancy of the instance (if the instance is running in a VPC). An instance with a tenancy of dedicated runs on single-tenant hardware. The host tenancy is not supported for the import-instance command"
#  type        = string
#  default     = null
#}
variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized. Note that if this is not set on an instance type that is optimized by default then this will show as disabled but if the instance type is optimized by default then there is no need to set this and there is no effect to disabling it"
  type        = bool
  default     = null
}
#variable "enclave_options_enabled" {
#  description = "Enable Nitro Enclaves on launched instances. Defaults to false"
#  type        = bool
#  default     = null
#}
variable "get_password_data" {
  description = "If true, wait for password data to become available and retrieve it. Useful for getting the administrator password for instances running Microsoft Windows"
  type        = bool
  default     = null
}
variable "monitoring" {
  description = "If true, the launched EC2 instance will have detailed monitoring enabled"
  type        = bool
  default     = false
}
variable "iam_instance_profile" {
  description = "IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile"
  type        = string
  default     = null
}
variable "root_block_device" {
  description = "Configuration block to customize details about the root block device of the instance"
  type        = list(any)
  default     = []
}
variable "ebs_block_device" {
  description = "One or more configuration blocks with additional EBS block devices to attach to the instance. Block device configurations only apply on resource creation"
  type        = list(any)
  default     = []
}
variable "metadata_options" {
  description = "Customize the metadata options of the instance"
  type        = list(map(string))
  default     = []
}
variable "user_data" {
  description = "User data to provide when launching the instance. Do not pass gzip-compressed data via this argument; see user_data_base64 instead. Updates to this field will trigger a stop/start of the EC2 instance by default. If the user_data_replace_on_change is set then updates to this field will trigger a destroy and recreate"
  type        = string
  default     = null
}
variable "user_data_base64" {
  description = "Can be used instead of user_data to pass base64-encoded binary data directly. Use this instead of user_data whenever the value is not a valid UTF-8 string. For example, gzip-encoded user data must be base64-encoded and passed via this argument to avoid corruption. Updates to this field will trigger a stop/start of the EC2 instance by default. If the user_data_replace_on_change is set then updates to this field will trigger a destroy and recreate"
  type        = string
  default     = null
}
variable "user_data_replace_on_change" {
  description = "When used in combination with user_data or user_data_base64 will trigger a destroy and recreate when set to true. Defaults to false if not set"
  type        = bool
  default     = false
}

##################################
# Network Interface
##################################
variable "network_interface" {
  description = "Customize network interfaces"
  type        = list(map(string))
  default     = []
}

##################################
# Key Pair
##################################
variable "create_new_key" {
  description = "Create new ssh key pair"
  type        = bool
  default     = false
}
variable "key_name" {
  description = "Key name of the Key Pair to use for the instance"
  type        = string
  default     = null
}

##################################
# External EBS
##################################
variable "external_disks" {
  description = "Attach external disk to instance"
  type        = list(map(string))
  default     = []
}