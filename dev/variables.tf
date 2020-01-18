variable "createInstanceLinux" {
  description = "If set to true, create Linux image"
  type        = bool
  default       = false
}

variable "createInstanceWin" {
  description = "If set to true, create windows image"
  type        = bool
  default       =false
}

variable "createS3_public" {
  description = "If set to true, enable Public Access"
  type        = bool
  default       = false
}

variable "createS3_private" {
  description = "If set to true, enable private Access"
  type        = bool
  default       = false
}
