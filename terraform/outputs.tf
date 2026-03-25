output "ssh_command" {
  value = "ssh -i ../${var.project_name}.pem rocky@${aws_instance.control.public_ip}"
}
output "control_public_ip" {
  value = aws_instance.control.public_ip
}
output "bootstrap_log" {
  value = "To debug bootstrap: ssh in, then: sudo tail -f /var/log/rhce-bootstrap.log"
}
output "cost_reminder" {
  value = "~$0.07/hr — remember: make destroy when done!"
}
