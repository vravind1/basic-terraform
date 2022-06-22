module "tfplan-functions" {
  source = "common-functions/tfplan-functions/tfplan-functions.sentinel"
}
  
policy "restrict-ec2-instance-type" {
  enforcement_level = "hard-mandatory"
}
