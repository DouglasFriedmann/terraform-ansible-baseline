output "instance_id" {
  value = aws_instance.ubuntu.id
}

output "public_ip" {
  value = aws_instance.ubuntu.public_ip
}

output "private_ip" {
  value = aws_instance.ubuntu.private_ip
}

output "instance_name" {
  value = aws_instance.ubuntu.tags.Name
}
