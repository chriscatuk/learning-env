locals {
  default_template_path = "${path.module}/default-user_data.tpl"
  template_path         = var.template_path != "" ? var.template_path : local.default_template_path

  default_template_vars = {
    hostname = var.hostname
    keypubic = var.keypublic
    username = var.username
  }

  #will work in 0.12, until then "conditional operator cannot be used with map value"
  template_vars = var.template_path != "" ? var.template_vars : local.default_template_vars

  #default value impossible until 0.12
  # template_vars = var.template_vars
}

