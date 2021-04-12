output "my_identifier" {
    value = random_pet.this.id
    description = "All my resources will be created using this prefix, so that I don't conflict with other's resources"
}