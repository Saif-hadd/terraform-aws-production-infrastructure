variable "name" {
  description = "Name used for the VPC and discovery tags."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "az_count" {
  description = "Number of availability zones to use when availability_zones is not set."
  type        = number
  default     = 3
}

variable "availability_zones" {
  description = "Explicit availability zones. Leave null to use the first az_count available zones."
  type        = list(string)
  default     = null
}

variable "private_subnet_newbits" {
  description = "New bits for private subnet CIDR calculation."
  type        = number
  default     = 4
}

variable "public_subnet_newbits" {
  description = "New bits for public subnet CIDR calculation."
  type        = number
  default     = 8
}

variable "intra_subnet_newbits" {
  description = "New bits for intra subnet CIDR calculation."
  type        = number
  default     = 8
}

variable "public_subnet_offset" {
  description = "Netnum offset used for public subnets."
  type        = number
  default     = 48
}

variable "intra_subnet_offset" {
  description = "Netnum offset used for intra subnets."
  type        = number
  default     = 52
}

variable "enable_nat_gateway" {
  description = "Whether to create NAT gateways."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Whether to use a single shared NAT gateway."
  type        = bool
  default     = true
}

variable "public_subnet_tags" {
  description = "Additional public subnet tags."
  type        = map(string)
  default     = {}
}

variable "private_subnet_tags" {
  description = "Additional private subnet tags."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
