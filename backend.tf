
terraform {
  backend "remote" {
    organization = "your-organization"
    
    workspaces {
      name = "azure-openai-chat"
    }
  }
}
