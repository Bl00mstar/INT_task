##### UTILS ######
### RG LOC SID ##### 
#################
variable "subscriptionID" {
  type        = string
  description = "Authentication variable"
}
variable "resourceGroupName" {
  type        = string
  description = "project group"
}
variable "location" {
  type        = string
  description = "Resource group location"
  default     = "West Europe"
}
variable "privConn" {
  type        = string
  description = "SSH conn ip / iprange"
}
variable "vm1user" {
  type        = string
  description = "front vm1 username"
}
variable "vm1password" {
  type        = string
  description = "front vm1 password"
}
variable "vm2user" {
  type        = string
  description = "front vm2 username"
}
variable "vm2password" {
  type        = string
  description = "front vm2 password"
}
#################
###  vNet 1 ##### 
################# 
variable "vNet1Name" {
  type        = string
  description = "vNet1 name"
  default     = "vnet1app"
}
variable "vNet1addressspace" {
  type        = list(any)
  description = "vNet2 address space"
  default     = ["10.0.0.0/16"]
}
#################
# vNet 1 SUBNETS 
#################
variable "SubnetvNet1FrontendName" {
  type        = string
  description = "vNet1 subnet1 name"
  default     = "frontsub"
}
variable "SubnetvNet1FrontendRange" {
  type        = string
  description = "vNet1 subnet addresses"
  default     = "10.0.0.0/24"
}
variable "SubnetvNet1BackendName" {
  type        = string
  description = "vNet1 subnet2 name"
  default     = "BackendSubnet"
}
variable "SubnetvNet1BackendRange" {
  type        = string
  description = "vNet1 subnet addresses"
  default     = "10.0.1.0/24"
}
#################
###  vNet 2 ##### 
#################
variable "vNet2Name" {
  type        = string
  description = "vNet2 name"
  default     = "vnet2db"
}
variable "vNet2addressspace" {
  type        = list(any)
  description = "vNet2 address space"
  default     = ["192.168.0.0/16"]
}
#################
# vNet 2 SUBNETS 
#################
variable "SubnetvNet2dbName" {
  type        = string
  description = "vNet2 subnet addresses"
  default     = "DBSubnet"
}
variable "SubnetvNet2dbRange" {
  type        = string
  description = "vNet2 subnet addresses"
  default     = "192.168.0.0/24"
}
#################
# Peering Names 
#################
variable "vNet1to2conn" {
  type        = string
  description = "vNets peering 1=>2"
  default     = "vNet1tovNet2conn"
}
variable "vNet2to1conn" {
  type        = string
  description = "vNets peering 2=>1"
  default     = "vNet2tovNet1conn"
}
#################
# NSG NAMES ##### 
#################
variable "nsgNames" {
  type        = list(any)
  description = "nsg Frontend name"
  default     = ["Frontend-nsg", "Backend-nsg", "DB-nsg"]
}
#################
#VN PEERING NAME # 
#################
variable "netPeering" {
  type        = list(any)
  description = "Virtual Network Peering Names"
  default     = ["peer1to2", "peer2to1"]
}
#################
#NETWORKING VM #### 
#################
variable "publicIpName" {
  type        = string
  description = "public ip name"
  default     = "publicIp"
}
variable "networkInterfaceFrontend" {
  type        = string
  description = "network interface 1 name"
  default     = "netInterfaceFront"
}
variable "networkInterfaceDatabase" {
  type        = string
  description = "network interface 2 name"
  default     = "netInterfaceDB"
}
#################
#VM CONFIG #### 
#################
variable "vm1name" {
  type        = string
  description = "virtual machine name"
  default     = "frontendvm"
}
variable "vm1hostname" {
  type        = string
  description = "virtual machine host"
  default     = "front"
}
variable "vm1size" {
  type        = string
  description = "virtual machine size"
  default     = "Standard_DS1_v2"
}
variable "vm2name" {
  type        = string
  description = "virtual machine name"
  default     = "dbvm"
}
variable "vm2hostname" {
  type        = string
  description = "virtual machine host"
  default     = "db"
}
variable "vm2size" {
  type        = string
  description = "virtual machine size"
  default     = "Standard_DS1_v2"
}