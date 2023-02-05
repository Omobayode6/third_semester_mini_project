output "lb_target_group_arn" {
  value = aws_lb_target_group.mini_project_tg.arn
}
output "lb_dns_name" {
  value = aws_lb.mini_project_lb.dns_name
}
output "lb_zone_id" {
  value = aws_lb.mini_project_lb.zone_id
}
