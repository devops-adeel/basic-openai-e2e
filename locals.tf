# Local Values

locals {
  common_tags = merge(
    var.tags,
    {
      Environment  = var.environment
      Project      = "OpenAI-Chat"
      Provisioner  = "Terraform"
    }
  )
}
